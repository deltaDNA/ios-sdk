//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "DDNASDK.h"
#import "DDNASettings.h"
#import "DDNAPopup.h"
#import "DDNAEvent.h"
#import "DDNAEngagement.h"
#import "DDNALog.h"
#import "DDNAPlayerPrefs.h"
#import "DDNAClientInfo.h"
#import "NSString+DeltaDNA.h"
#import "NSDictionary+DeltaDNA.h"
#import <CommonCrypto/CommonDigest.h>

#import "DDNAPersistentEventStore.h"
#import "DDNAVolatileEventStore.h"
#import "DDNAEngageService.h"
#import "DDNAInstanceFactory.h"
#import "DDNACollectService.h"

@interface DDNASDK ()
{
    dispatch_source_t _timer;
    dispatch_queue_t _taskQueue;
}

@property (nonatomic, strong) id<DDNAEventStoreProtocol> eventStore;
@property (nonatomic, strong) DDNAEngageService *engageService;
@property (nonatomic, strong) DDNACollectService *collectService;
@property (nonatomic, assign) BOOL reset;
@property (nonatomic, copy, readwrite) NSString *environmentKey;
@property (nonatomic, copy, readwrite) NSString *collectURL;
@property (nonatomic, copy, readwrite) NSString *engageURL;
@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy, readwrite) NSString *sessionID;
@property (nonatomic, copy, readwrite) NSString *platform;

- (void)didReceiveNotification:(NSNotification *) notification;

@end

static NSString *const EV_KEY_NAME = @"eventName";
static NSString *const EV_KEY_USER_ID = @"userID";
static NSString *const EV_KEY_SESSION_ID = @"sessionID";
static NSString *const EV_KEY_TIMESTAMP = @"eventTimestamp";
static NSString *const EV_KEY_PARAMS = @"eventParams";

static NSString *const EP_KEY_PLATFORM = @"platform";
static NSString *const EP_KEY_SDK_VERSION = @"sdkVersion";

static NSString *const PP_KEY_FIRST_RUN = @"DDSDK_FIRST_RUN";
static NSString *const PP_KEY_USER_ID = @"DDSDK_USER_ID";
static NSString *const PP_KEY_HASH_SECRET = @"DDSDK_HASH_SECRET";
static NSString *const PP_KEY_CLIENT_VERSION = @"DDSDK_CLIENT_VERSION";
static NSString *const PP_KEY_PUSH_NOTIFICATION_TOKEN = @"DDSDK_PUSH_NOTIFICATION_TOKEN";

static NSString *const DD_EVENT_STARTED = @"DDNASDKStarted";

static NSString *const kUserIdKey = @"DeltaDNA UserId";
static NSString *const kPushNotificationTokenKey = @"DeltaDNA PushNotificationToken";

@implementation DDNASDK

#pragma mark - SingletonAccess

+ (instancetype) sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id) init
{
    if ((self = [super init]))
    {
        _reset = NO;
        _uploading = NO;
        _settings = [[DDNASettings alloc] init];
        
        _taskQueue = dispatch_queue_create("com.deltadna.TaskQueue", NULL);
        dispatch_suspend(_taskQueue);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DD_EVENT_STARTED object:nil];
        
        if (self.settings.useEventStore) {
            DDNALogDebug(@"Using persistent event store for session.");
            NSString *path = [DDNA_EVENT_STORAGE_PATH stringByReplacingOccurrencesOfString:@"{persistent_path}" withString:[DDNASettings getPrivateSettingsDirectoryPath]];
            self.eventStore = [[DDNAPersistentEventStore alloc] initWithPath:path sizeBytes:DDNA_MAX_EVENT_STORE_BYTES clean:self.reset];
        } else {
            DDNALogDebug(@"Using volatile event store for session.");
            self.eventStore = [[DDNAVolatileEventStore alloc] initWithSizeBytes:DDNA_MAX_EVENT_STORE_BYTES];
        }
    }
    return self;
}

#pragma mark - Setup SDK

- (void)startWithEnvironmentKey:(NSString *)environmentKey
                      collectURL:(NSString *)collectURL
                       engageURL:(NSString *)engageURL
{
    [self startWithEnvironmentKey:environmentKey
                       collectURL:collectURL
                        engageURL:engageURL
                           userID:nil];
}

- (void)startWithEnvironmentKey:(NSString *)environmentKey
                     collectURL:(NSString *)collectURL
                      engageURL:(NSString *)engageURL
                         userID:(NSString *)userID
{
    @synchronized(self)
    {
        self.environmentKey = environmentKey;
        self.collectURL = [self mungeUrl: collectURL];
        self.engageURL = [self mungeUrl: engageURL];
        
        BOOL newPlayer = NO;
        if ([NSString stringIsNilOrEmpty:self.userID]) {    // first time!
            newPlayer = YES;
            if ([NSString stringIsNilOrEmpty:userID]) {     // generate a user id
                userID = [DDNASDK generateUserID];
            }
        } else if (![NSString stringIsNilOrEmpty:userID]) {
            if (![self.userID isEqualToString:userID]) {    // started with a different user id
                newPlayer = YES;
            }
        }
        
        self.userID = userID;
        
        DDNALogDebug(@"Starting SDK with user id %@", self.userID);
        
        self.platform = [DDNAClientInfo sharedInstance].platform;
        self.sessionID = [DDNASDK generateSessionID];
        self.engageService = [[DDNAInstanceFactory sharedInstance] buildEngageService];
        self.collectService = [[DDNAInstanceFactory sharedInstance] buildCollectService];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_EVENT_STARTED object:self];
        _started = YES;
        
        // Once we're started, send default events.
        [self triggerDefaultEvents:newPlayer];
        
        // Setup automated event uploads in the background.
        if (_settings.backgroundEventUpload) {
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
            if (_timer) {
                uint64_t interval = self.settings.backgroundEventUploadRepeatRateSeconds * NSEC_PER_SEC;
                uint64_t leeway = 1ull * NSEC_PER_SEC;
                dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
                dispatch_source_set_event_handler(_timer, ^{
                    [self upload];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.settings.backgroundEventUploadStartDelaySeconds * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    dispatch_resume(_timer);
                });
            }
        }
    }
}

- (void) newSession
{
    self.sessionID = [DDNASDK generateSessionID];
}

- (void) stop
{
    DDNALogDebug(@"Stopping SDK");
    
    if (_timer)
    {
        dispatch_source_cancel(_timer);
    }
    
    [self recordEventWithName:@"gameEnded"];
    [self upload];
    
    if (_started) {
        dispatch_suspend(_taskQueue);
    }
    _started = NO;
}

- (void)recordEvent:(DDNAEvent *)event
{
    if (!self.started) {
        @throw([NSException exceptionWithName:@"DDNANotStartedException" reason:@"The deltaDNA SDK must be started before it can record events." userInfo:nil]);
    }
    
    [event setParam:self.platform forKey:@"platform"];
    [event setParam:DDNA_SDK_VERSION forKey:@"sdkVersion"];
    
    NSMutableDictionary *eventSchema = [NSMutableDictionary dictionaryWithDictionary:[event dictionary]];
    [eventSchema setObject:self.userID forKey:@"userID"];
    [eventSchema setObject:self.sessionID forKey:@"sessionID"];
    [eventSchema setObject:[DDNASDK getCurrentTimestamp] forKey:@"eventTimestamp"];
    
    if (![self.eventStore pushEvent:eventSchema]) {
        DDNALogWarn(@"Event store full, dropping event");
    }
}

- (void)recordEventWithName:(NSString *)eventName
{
    [self recordEvent:[DDNAEvent eventWithName:eventName]];
}

- (void)recordEventWithName:(NSString *)eventName eventParams:(NSDictionary *)eventParams
{
    DDNAEvent *event = [DDNAEvent eventWithName:eventName];
    for (NSString *key in eventParams) {
        [event setParam:eventParams[key] forKey:key];
    }
    
    [self recordEvent:event];
}

- (void) requestEngagement: (NSString *) decisionPoint
             callbackBlock: (DDNAEngagementResponseBlock) callback
{
    [self requestEngagement:decisionPoint withEngageParams:nil callbackBlock:callback];
}

- (void) requestEngagement: (NSString *) decisionPoint
          withEngageParams: (NSDictionary *) engageParams
             callbackBlock: (DDNAEngagementResponseBlock) callback
{
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    for (NSString *key in engageParams) {
        [engagement setParam:engageParams[key] forKey:key];
    }
    
    [self requestEngagement:engagement completionHandler:^(NSDictionary *parameters, NSInteger statusCode, NSError *error) {
        if (callback) callback(parameters);
    }];
}

- (void)requestEngagement:(DDNAEngagement *)engagement completionHandler:(void (^)(NSDictionary *, NSInteger, NSError *))completionHandler
{
    if (!self.started) {
        @throw([NSException exceptionWithName:@"DDNANotStartedException" reason:@"You must first start the deltaDNA SDK" userInfo:nil]);
    }
    
    if ([NSString stringIsNilOrEmpty:self.engageURL]) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Engage URL not set" userInfo:nil]);
    }
    
    @try {
        
        NSDictionary *dict = [engagement dictionary];
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:dict[@"decisionPoint"]
                                                                                     userId:self.userID
                                                                                  sessionId:self.sessionID];
        engageRequest.flavour = dict[@"flavour"];
        engageRequest.parameters = dict[@"parameters"];
        
        [self.engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *error) {
            if (response && completionHandler) {
                completionHandler([NSDictionary dictionaryWithJSONString:response], statusCode, error);
            } else {
                DDNALogWarn(@"Engagement failed with status code %ld: %@", (long)statusCode, [error localizedDescription]);
            }
        }];
    }
    @catch (NSException *exception) {
        DDNALogWarn(@"Engagement request failed: %@", exception.reason);
    }
}

- (void) requestImageMessage:(NSString *)decisionPoint withEngageParams:(NSDictionary *)engageParams imagePopup:(id <DDNAPopup>)popup
{
    [self requestImageMessage:decisionPoint withEngageParams:engageParams imagePopup:popup callbackBlock:nil];
}

- (void) requestImageMessage:(NSString *)decisionPoint withEngageParams:(NSDictionary *)engageParams imagePopup:(id <DDNAPopup>)popup callbackBlock:(DDNAEngagementResponseBlock)callback
{
    [self requestEngagement:decisionPoint
          withEngageParams:engageParams
             callbackBlock:^(NSDictionary * response) {
                 if (response != nil) {
                     if (response[@"image"]) {
                         [popup prepareWithImage:response[@"image"]];
                     }
                     
                     if (callback != nil) {
                         callback(response);
                     }
                 }
             }
     ];
}

- (void)requestImageMessage:(DDNAEngagement *)engagement popup:(id<DDNAPopup>)popup completionHandler:(void (^)(NSDictionary *, NSInteger, NSError *))completionHandler
{
    [self requestEngagement:engagement completionHandler:^(NSDictionary *parameters, NSInteger statusCode, NSError *error) {
        if (parameters) {
            if (parameters[@"image"]) {
                [popup prepareWithImage:parameters[@"image"]];
            }
        }

        if (completionHandler) {
            completionHandler(parameters, statusCode, error);
        }
    }];
}

- (void) recordPushNotification:(NSDictionary *)pushNotification didLaunch:(BOOL)didLaunch
{
    DDNALogDebug(@"Received push notification: %@", pushNotification);
 
    if (_started) {
        
        NSString *notificationId = pushNotification[@"_ddId"];
        NSString *notificationName = pushNotification[@"_ddName"];
        
        NSMutableDictionary *eventParams = [NSMutableDictionary dictionary];
        if (notificationId) {
            [eventParams setObject:[NSNumber numberWithInteger:[notificationId integerValue]] forKey:@"notificationId"];
        }
        if (notificationName) {
            [eventParams setObject:notificationName forKey:@"notificationName"];
        }
        [eventParams setObject:[NSNumber numberWithBool:didLaunch] forKey:@"notificationLaunch"];
        
        [self recordEventWithName:@"notificationOpened" eventParams:eventParams];
    }
    else {
        // wait until the SDK has been started
        __typeof(self) __weak weakSelf = self;
        dispatch_async(_taskQueue, ^{
            [weakSelf recordPushNotification:pushNotification didLaunch:didLaunch];
        });
    }
}

- (void) upload
{
    @synchronized(self) {
        if (!self.started) {
            NSException *exception = [NSException exceptionWithName:@"DDNANotStartedException" reason:@"You must first start the deltaDNA SDK" userInfo:nil];
            @throw exception;
        }
        
        if (self.uploading) {
            DDNALogWarn(@"Event upload already in progress, try again later.");
            return;
        }
        
        @try {
            self.uploading = YES;
            [self.eventStore swapBuffers];
            
            NSArray *events = [self.eventStore readOut];
            if (events.count > 0) {
                DDNACollectRequest *request = [[DDNACollectRequest alloc] initWithEventList:events timeoutSeconds:self.settings.httpRequestCollectTimeoutSeconds retries:self.settings.httpRequestMaxTries retryDelaySeconds:self.settings.httpRequestRetryDelaySeconds];
                if (!request) {
                    DDNALogWarn(@"Event corruption detected, clearing out queue");
                    [self.eventStore clearOut];
                    self.uploading = NO;
                } else {
                    DDNALogDebug(@"Sending latest events to Collect: %@", request);
                    [self.collectService request:request handler:^(NSString *response, NSInteger statusCode, NSString *error) {
                        if (statusCode >= 200 && statusCode < 400) {
                            DDNALogDebug(@"Event upload completed successfully.");
                            [self.eventStore clearOut];
                        } else if (statusCode == 400) {
                            DDNALogWarn(@"Collect rejected invalid events.");
                            [self.eventStore clearOut];
                        } else {
                            DDNALogWarn(@"Event upload failed, try again later.");
                        }
                        self.uploading = NO;
                    }];
                }
            } else {
                self.uploading = NO;
            }
        }
        @catch (NSException *exception) {
            self.uploading = NO;
            DDNALogWarn(@"Event upload failed: %@", exception.reason);
        }
    }
}

- (void) clearPersistentData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kUserIdKey];
    _reset = YES;
}

#pragma mark - Client Configuration Properties

- (NSString *) userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults stringForKey:kUserIdKey];
    if (userID) return userID;
    
    // read legacy userId
    userID = [DDNAPlayerPrefs getObjectForKey:PP_KEY_USER_ID withDefault:nil];
    [self setUserID:userID];
    return userID;
}

- (void) setUserID:(NSString *)userID
{
    if (![NSString stringIsNilOrEmpty:userID])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userID forKey:kUserIdKey];
    }
}

- (void) setPushNotificationToken:(NSString *)pushNotificationToken
{
    if (_started) {
        NSString *token = [pushNotificationToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self recordEventWithName:@"notificationServices" eventParams:@{
                @"pushNotificationToken": token
            }];
    } else {
        __typeof(self) __weak weakSelf = self;
        dispatch_async(_taskQueue, ^{
            [weakSelf setPushNotificationToken:pushNotificationToken];
        });
    }
}


#pragma mark - Private Helpers

- (NSString *) mungeUrl: (NSString *)url
{
    NSString *lowerCase = [url lowercaseString];
    if (![lowerCase hasPrefix:@"http://"] && ![lowerCase hasPrefix:@"https://"]) {
        return [@"http://" stringByAppendingString:url];
    } else {
        return url;
    }
}

+ (NSString *) getCurrentTimestamp
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:gregorianCalendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *) formatURIWithPattern: (NSString *) pattern
                            forHost: (NSString *) host
                     forEnvironment: (NSString *) environmentKey
{
    return [self formatURIWithPattern:pattern
                              forHost:host
                       forEnvironment:environmentKey
                          withMD5Hash:nil];
}

+ (NSString *) formatURIWithPattern: (NSString *)pattern
                            forHost: (NSString *)host
                     forEnvironment: (NSString *)environmentKey
                        withMD5Hash: (NSString *)md5Hash
{
    NSString *uri = [pattern stringByReplacingOccurrencesOfString:@"{host}" withString:host];
    uri = [uri stringByReplacingOccurrencesOfString:@"{env_key}" withString:environmentKey];
    if (md5Hash != nil)
    {
        uri = [uri stringByReplacingOccurrencesOfString:@"{hash}" withString:md5Hash];
    }
    return uri;
}

+ (NSString *) generateHashForData: (NSString *) data
                    withHashSecret: (NSString *) hashSecret
{
    NSString *input = [data stringByAppendingString:hashSecret];
    return [input md5];
}

+ (NSString *) generateUserID
{
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *) generateSessionID
{
    return [[NSUUID UUID] UUIDString];
}

- (void) triggerDefaultEvents:(BOOL)newPlayer
{
    if (_settings.onFirstRunSendNewPlayerEvent && newPlayer)
    {
        DDNALogDebug(@"Sending 'newPlayer' event");
        
        NSMutableDictionary *eventParams = [NSMutableDictionary dictionary];
        if ([DDNAClientInfo sharedInstance].countryCode!=nil) {
            [eventParams setObject:[DDNAClientInfo sharedInstance].countryCode forKey:@"userCountry"];
        }
        
        [self recordEventWithName:@"newPlayer" eventParams:eventParams];
    }
    
    if (_settings.onStartSendGameStartedEvent)
    {
        DDNALogDebug(@"Sending 'gameStarted' event");
        
        NSMutableDictionary *eventParams = [NSMutableDictionary dictionary];
        if (self.clientVersion != nil)
        {
            [eventParams setObject:self.clientVersion forKey:@"clientVersion"];
        }
        
        if (self.pushNotificationToken != nil)
        {
            [eventParams setObject:self.pushNotificationToken forKey:@"pushNotificationToken"];
        }
        
        if ([DDNAClientInfo sharedInstance].locale != nil) {
            [eventParams setObject:[DDNAClientInfo sharedInstance].locale forKey:@"userLocale"];
        }
        
        [self recordEventWithName:@"gameStarted" eventParams:eventParams];
    }
    
    if (_settings.onStartSendClientDeviceEvent)
    {
        DDNALogDebug(@"Sending 'clientDevice' event");
        
        NSMutableDictionary *eventParams = [NSMutableDictionary dictionary];
        [eventParams setObject:[DDNAClientInfo sharedInstance].deviceName forKey:@"deviceName"];
        [eventParams setObject:[DDNAClientInfo sharedInstance].deviceType forKey:@"deviceType"];
        if ([DDNAClientInfo sharedInstance].hardwareVersion!=nil) {
            [eventParams setObject:[DDNAClientInfo sharedInstance].hardwareVersion forKey:@"hardwareVersion"];
        }
        [eventParams setObject:[DDNAClientInfo sharedInstance].operatingSystem forKey:@"operatingSystem"];
        [eventParams setObject:[DDNAClientInfo sharedInstance].operatingSystemVersion forKey:@"operatingSystemVersion"];
        [eventParams setObject:[DDNAClientInfo sharedInstance].manufacturer forKey:@"manufacturer"];
        [eventParams setObject:[DDNAClientInfo sharedInstance].timezoneOffset forKey:@"timezoneOffset"];
        if ([DDNAClientInfo sharedInstance].languageCode!=nil) {
            [eventParams setObject:[DDNAClientInfo sharedInstance].languageCode forKey:@"userLanguage"];
        }
        
        [self recordEventWithName:@"clientDevice" eventParams:eventParams];
    }
}

- (void) didReceiveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:DD_EVENT_STARTED])
    {
        DDNALogDebug(@"Received SDK started notification");
        if (!_started) {
            dispatch_resume(_taskQueue);
        }
    }
}

@end
