//
//  DeltaDNASDK.m
//  DeltaDNASDK
//
//  Created by David White on 18/07/2014.
//  Copyright (c) 2014 deltadna. All rights reserved.
//

#import "DDNASDK.h"
#import "DDNALog.h"
#import "DDNAPlayerPrefs.h"
#import "DDNAClientInfo.h"
#import "DDNAEventBuilder.h"
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
    // Ensure this can only be called once
    @synchronized(self)
    {
        self.environmentKey = environmentKey;
        self.collectURL = [self mungeUrl: collectURL];
        self.engageURL = [self mungeUrl: engageURL];
        
        BOOL newPlayer = NO;
        if ([NSString stringIsNilOrEmpty:userID] && [NSString stringIsNilOrEmpty:self.userID])
        {
            self.userID = [DDNASDK generateUserID];
            newPlayer = YES;
        }
        else
        {
            self.userID = userID;
        }
        
        DDNALogDebug(@"Starting SDK with user id %@", self.userID);
        
        self.platform = [DDNAClientInfo sharedInstance].platform;
        self.sessionID = [DDNASDK generateSessionID];
        self.engageService = [[DDNAInstanceFactory sharedInstance] buildEngageService];
        self.collectService = [[DDNAInstanceFactory sharedInstance] buildCollectService];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DD_EVENT_STARTED object:self];
        _started = YES;
        
        // Once we're started, send default events.
        [self triggerDefaultEvents:newPlayer];
        
        // Setup automated event uploads.
        if (_settings.backgroundEventUpload)
        {
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            
            if (_timer)
            {
                uint64_t interval = _settings.backgroundEventUploadRepeatRateSeconds * NSEC_PER_SEC;
                uint64_t leeway = 1ull * NSEC_PER_SEC;
                dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
                dispatch_source_set_event_handler(_timer, ^{
                    [self upload];
                });
                
                // Trigger after delay
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, _settings.backgroundEventUploadStartDelaySeconds * NSEC_PER_SEC);
                dispatch_after(delay, dispatch_get_main_queue(), ^{
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
    
    [self recordEvent:@"gameEnded"];
    [self upload];
    
    if (_started) {
        dispatch_suspend(_taskQueue);
    }
    _started = NO;
}

- (void) recordEvent: (NSString *) eventName
{
    NSDictionary * eventParams = [NSDictionary dictionary];
    [self recordEvent:eventName withEventDictionary:eventParams];
}

- (void) recordEvent: (NSString *) eventName
     withEventBuilder: (DDNAEventBuilder *) eventBuilder
{
    [self recordEvent:eventName withEventDictionary:[eventBuilder dictionary]];
}

- (void) recordEvent: (NSString *) eventName
  withEventDictionary: (NSDictionary *) eventParams
{
    if (!self.hasStarted)
    {
        NSException * e = [NSException exceptionWithName:@"NotStartedException"
                                                  reason:@"You must first start the DeltaDNA SDK"
                                                userInfo:nil];
        @throw e;
    }
    
    // The header for every event is eventName, userID, sessionID and timestamp.
    NSMutableDictionary * eventRecord = [NSMutableDictionary dictionary];
    [eventRecord setObject:eventName forKey:EV_KEY_NAME];
    [eventRecord setObject:self.userID forKey:EV_KEY_USER_ID];
    [eventRecord setObject:self.sessionID forKey:EV_KEY_SESSION_ID];
    [eventRecord setObject:[DDNASDK getCurrentTimestamp] forKey:EV_KEY_TIMESTAMP];
    
    NSMutableDictionary * mutableEventParams = [NSMutableDictionary dictionaryWithDictionary:eventParams];
    
    // Every template should support sdkVersion and platform in it's event params.
    if (![mutableEventParams objectForKey:EP_KEY_PLATFORM])
    {
        [mutableEventParams setObject:self.platform forKey:EP_KEY_PLATFORM];
    }
    
    if (![mutableEventParams objectForKey:EP_KEY_SDK_VERSION])
    {
        [mutableEventParams setObject:DDNA_SDK_VERSION forKey:EP_KEY_SDK_VERSION];
    }
    
    [eventRecord setObject:mutableEventParams forKey:EV_KEY_PARAMS];
    
    // Push onto the event store.
    
    if (![_eventStore pushEvent:eventRecord])
    {
        DDNALogDebug(@"Event Store full, unable to record event");
    }
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
    if (!self.hasStarted)
    {
        NSException * e = [NSException exceptionWithName:@"NotStartedException"
                                                  reason:@"You must first start the DeltaDNA SDK"
                                                userInfo:nil];
        @throw e;
    }

    if ([NSString stringIsNilOrEmpty:_engageURL])
    {
        DDNALogWarn(@"Engagement request failed: Engage URL not configured.");
        return;
    }
    
    if ([NSString stringIsNilOrEmpty:decisionPoint])
    {
        DDNALogWarn(@"Engagement request failed: No decision point set.");
        return;
    }
    
    @try
    {
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:decisionPoint
                                                                                     userId:self.userID
                                                                                  sessionId:self.sessionID];
        engageRequest.parameters = engageParams;
        
        DDNALogDebug(@"Requesting engagement %@", engageRequest);
        
        [self.engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSString *error) {
            if (response && callback) {
                callback([NSDictionary dictionaryWithJSONString:response]);
            } else {
                DDNALogWarn(@"Engagement failed with status code %ld: %@", statusCode, error);
            }
        }];
    }
    @catch (NSException *exception)
    {
        DDNALogDebug(@"Engagement request failed: %@", exception.reason);
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
        
        [self recordEvent:@"notificationOpened" withEventDictionary:eventParams];
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
            NSException *exception = [NSException exceptionWithName:@"NotStartedException" reason:@"You must first start the deltaDNA SDK" userInfo:nil];
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
        [self recordEvent:@"notificationServices" withEventDictionary:@{
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
        
        [self recordEvent:@"newPlayer" withEventDictionary:eventParams];
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
        
        [self recordEvent:@"gameStarted" withEventDictionary:eventParams];
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
        
        [self recordEvent:@"clientDevice" withEventDictionary:eventParams];
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
