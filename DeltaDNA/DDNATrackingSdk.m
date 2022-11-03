//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#import "DDNATrackingSdk.h"
#import "DDNASDK.h"
#import "DDNAUserManager.h"
#import "DDNASettings.h"
#import "DDNAEvent.h"
#import "DDNAEngagement.h"
#import "DDNALog.h"
#import "DDNAPlayerPrefs.h"
#import "DDNAClientInfo.h"
#import "DDNAUtils.h"
#import "NSString+DeltaDNA.h"
#import "NSDictionary+DeltaDNA.h"
#import <CommonCrypto/CommonDigest.h>

#import "DDNAPersistentEventStore.h"
#import "DDNAVolatileEventStore.h"
#import "DDNAEngageService.h"
#import "DDNAInstanceFactory.h"
#import "DDNACollectService.h"
#import "DDNAEngageFactory.h"
#import "DDNAImageCache.h"
#import "DDNAEventAction.h"
#import "DDNAEventTrigger.h"

#import <UIKit/UIKit.h>

@interface DDNAEngagement(DeltaDNAAds)

@property (nonatomic, copy) NSString *flavour;

@end

@interface DDNATrackingSdk ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, assign) BOOL taskQueueSuspended;

@property (nonatomic, weak) DDNASDK *sdk;
@property (nonatomic, weak) DDNAInstanceFactory *instanceFactory;
@property (nonatomic, strong) id<DDNAEventStoreProtocol> eventStore;
@property (nonatomic, strong) DDNAActionStore *actionStore;
@property (nonatomic, strong) DDNAEngageService *engageService;
@property (nonatomic, strong) DDNACollectService *collectService;
@property (nonatomic, assign) BOOL reset;
@property (nonatomic, strong) NSDate *lastActiveDate;
@property (nonatomic, strong) DDNAEngageFactory *engageFactory;

@property (nonatomic, strong) NSSet<NSString *> *eventWhitelist;
@property (nonatomic, strong) NSSet<NSString *> *decisionPointWhitelist;
@property (nonatomic, strong) NSSet<NSString *> *imageCacheList;
@property (nonatomic, strong) NSOrderedSet<DDNAEventTrigger *> *eventTriggers;

@property (nonatomic, assign, readwrite) BOOL started;
@property (nonatomic, assign, readwrite) BOOL uploading;
@property (nonatomic, assign, readwrite) BOOL sendNewPlayerEvent;
@property (nonatomic, assign, readwrite) BOOL sentDefaultEvents;

@end

static NSString *const EV_KEY_NAME = @"eventName";
static NSString *const EV_KEY_USER_ID = @"userID";
static NSString *const EV_KEY_SESSION_ID = @"sessionID";
static NSString *const EV_KEY_TIMESTAMP = @"eventTimestamp";
static NSString *const EV_KEY_PARAMS = @"eventParams";

static NSString *const EP_KEY_PLATFORM = @"platform";
static NSString *const EP_KEY_SDK_VERSION = @"sdkVersion";

static NSString *const DD_EVENT_STARTED = @"DDNASDKStarted";
static NSString *const DD_EVENT_NEW_SESSION = @"DDNASDKNewSession";

@implementation DDNATrackingSdk

- (instancetype)initWithSdk:(DDNASDK *)sdk instanceFactory:(DDNAInstanceFactory *)instanceFactory
{
    if ((self = [super init])) {
        self.sdk = sdk;
        self.instanceFactory = instanceFactory;
        
        self.reset = NO;
        self.uploading = NO;
        self.sentDefaultEvents = NO;
        self.sendNewPlayerEvent = NO;
        
        self.taskQueue = dispatch_queue_create("com.deltadna.TaskQueue", NULL);
        dispatch_suspend(self.taskQueue);
        self.taskQueueSuspended = YES;
        self.imageCacheList = [NSSet set];
        
        __weak typeof(self) weakSelf = self;
        NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:DD_EVENT_STARTED object:self.sdk queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            DDNALogDebug(@"Received SDK started notification");
            if (weakSelf.taskQueueSuspended) {
                dispatch_resume(weakSelf.taskQueue);
                weakSelf.taskQueueSuspended = NO;
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        if (self.sdk.settings.useEventStore) {
            DDNALogDebug(@"Using persistent event store for session.");
            NSString *path = [DDNA_EVENT_STORAGE_PATH stringByReplacingOccurrencesOfString:@"{persistent_path}" withString:[DDNASettings getPrivateSettingsDirectoryPath]];
            self.eventStore = [[DDNAPersistentEventStore alloc] initWithPath:path sizeBytes:DDNA_MAX_EVENT_STORE_BYTES clean:self.reset];
        } else {
            DDNALogDebug(@"Using volatile event store for session.");
            self.eventStore = [[DDNAVolatileEventStore alloc] initWithSizeBytes:DDNA_MAX_EVENT_STORE_BYTES];
        }
        NSString *actionStoragePath = [DDNA_ACTION_STORAGE_PATH stringByReplacingOccurrencesOfString:@"{persistent_path}" withString:[DDNASettings getPrivateSettingsDirectoryPath]];
        self.actionStore = [[DDNAActionStore alloc] initWithPath:actionStoragePath];
    }
    return self;
}

- (void)dealloc
{
    if (self.taskQueueSuspended) {
        dispatch_resume(self.taskQueue);    // doesn't like deallocing suspended queues!
        self.taskQueueSuspended = NO;
    }
}

- (void)startWithNewPlayer:(DDNAUserManager *)userManager
{
    self.engageService = [self.instanceFactory buildEngageService];
    self.collectService = [self.instanceFactory buildCollectService];
    
    DDNALogDebug(@"Starting SDK with user id %@", self.sdk.userID);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DD_EVENT_STARTED object:self.sdk];
    self.started = YES;
    if ([self.sdk.delegate respondsToSelector:@selector(didStartSdk)]) {
        [self.sdk.delegate didStartSdk];
    }
    
    if (userManager.isNewPlayer) {
        [self.actionStore clear];
        self.sendNewPlayerEvent = YES;
    }
    
    [self.sdk newSession];
    if (userManager.isNewPlayer) {
        [userManager setFirstSession:[NSDate date]];
    }
    
    userManager.newPlayer = NO;
    
    // Setup automated event uploads in the background.
    if (self.sdk.settings.backgroundEventUpload) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        if (_timer) {
            uint64_t interval = self.sdk.settings.backgroundEventUploadRepeatRateSeconds * NSEC_PER_SEC;
            uint64_t leeway = 1ull * NSEC_PER_SEC;
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
            dispatch_source_set_event_handler(_timer, ^{
                [self upload];
            });
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.sdk.settings.backgroundEventUploadStartDelaySeconds * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                dispatch_resume(weakSelf.timer);
            });
        }
    }
}

- (void) newSession
{
    DDNALogDebug(@"Starting new session %@", self.sdk.sessionID);
    [[NSNotificationCenter defaultCenter] postNotificationName:DD_EVENT_NEW_SESSION object:self];
}

- (void) stop
{
    DDNALogDebug(@"Stopping SDK");
    
    if (self.timer)
    {
        dispatch_source_cancel(self.timer);
    }
    
    [[self recordEvent:[DDNAEvent eventWithName:@"gameEnded"]] run];
    [self upload];
    
    if (!self.taskQueueSuspended) {
        dispatch_suspend(self.taskQueue);
        self.taskQueueSuspended = YES;
    }
    self.started = NO;
    if ([self.sdk.delegate respondsToSelector:@selector(didStopSdk)]) {
        [self.sdk.delegate didStopSdk];
    }
}

- (DDNAEventAction *)recordEvent:(DDNAEvent *)event
{
    if (!self.started) {
        @throw([NSException exceptionWithName:@"DDNANotStartedException" reason:@"The deltaDNA SDK must be started before it can record events." userInfo:nil]);
    }
    
    if (self.eventWhitelist && ![self.eventWhitelist containsObject:event.eventName]) {
        DDNALogDebug(@"Ignoring non whitelisted event \"%@\"", event.eventName);
        return [[DDNAEventAction alloc] init];
    }
    
    [event setParam:self.sdk.platform forKey:@"platform"];
    [event setParam:DDNA_SDK_VERSION forKey:@"sdkVersion"];
    
    NSMutableDictionary *eventSchema = [NSMutableDictionary dictionaryWithDictionary:[event dictionary]];
    [eventSchema setObject:self.sdk.userID forKey:@"userID"];
    [eventSchema setObject:self.sdk.sessionID forKey:@"sessionID"];
    [eventSchema setObject:[[NSUUID UUID] UUIDString] forKey:@"eventUUID"];
    [eventSchema setObject:[DDNAUtils getCurrentTimestamp] forKey:@"eventTimestamp"];
        
    [self.eventStore pushEvent:eventSchema];
    
    return [[DDNAEventAction alloc] initWithEventSchema:eventSchema eventTriggers:self.eventTriggers sdk:self store:self.actionStore settings:self.sdk.settings];
}

- (void)requestEngagement:(DDNAEngagement *)engagement completionHandler:(void (^)(NSDictionary *, NSInteger, NSError *))completionHandler
{    
    [self requestEngagement:engagement engagementHandler:^(DDNAEngagement *responseEngagement) {
        if (completionHandler) {
            completionHandler(engagement.json, engagement.statusCode, engagement.error);
        }
    }];
}

- (void)requestEngagement:(DDNAEngagement *)engagement engagementHandler:(void (^)(DDNAEngagement *))engagementHandler
{
    if (!self.started) {
        @throw([NSException exceptionWithName:@"DDNANotStartedException" reason:@"You must first start the deltaDNA SDK" userInfo:nil]);
    }
    
    if ([NSString stringIsNilOrEmpty:self.sdk.engageURL]) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Engage URL not set" userInfo:nil]);
    }
    
    if (engagement == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"engagement cannot be nil" userInfo:nil]);
    }
    
    if (engagementHandler == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"engagementHandler cannot be nil" userInfo:nil]);
    }
    
    if (self.decisionPointWhitelist && ![self.decisionPointWhitelist containsObject:[NSString stringWithFormat:@"%@@%@", engagement.decisionPoint, engagement.flavour]]) {
        DDNALogDebug(@"Ignoring non whitelisted decision point \"%@\"", engagement.decisionPoint);
        return;
    }
    
    @try {
        
        NSDictionary *dict = [engagement dictionary];
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:dict[@"decisionPoint"]
                                                                                     userId:self.sdk.userID
                                                                                  sessionId:self.sdk.sessionID];
        engageRequest.flavour = dict[@"flavour"];
        engageRequest.parameters = dict[@"parameters"];
        
        [self.engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *error) {
            if (error || statusCode != 200) {
                DDNALogWarn(@"Engagement for '%@' failed with %ld: %@",
                            engagement.decisionPoint, (long)statusCode, error ? error.localizedDescription : response);
            }
            engagement.raw = response;
            engagement.statusCode = statusCode;
            engagement.error = error;
            
            engagementHandler(engagement);
        }];
    }
    @catch (NSException *exception) {
        DDNALogWarn(@"Engagement for '%@' failed: %@", engagement.decisionPoint, exception.reason);
    }
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
        
        NSString *campaignId = pushNotification[@"_ddCampaign"];
        NSString *cohortId = pushNotification[@"_ddCohort"];
        if (campaignId) {
            [eventParams setObject:[NSNumber numberWithLong:[campaignId longLongValue]] forKey:@"campaignId"];
        }
        if (cohortId) {
            [eventParams setObject:[NSNumber numberWithLong:[cohortId longLongValue]] forKey:@"cohortId"];
        }
        if (campaignId || cohortId) {
            [eventParams setObject:@"APPLE_NOTIFICATION" forKey:@"communicationSender"];
            [eventParams setObject:@"OPEN" forKey:@"communicationState"];
        }
        
        [eventParams setObject:[NSNumber numberWithBool:didLaunch] forKey:@"notificationLaunch"];
        
        [[self.sdk recordEventWithName:@"notificationOpened" eventParams:eventParams] run];
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
                DDNACollectRequest *request = [[DDNACollectRequest alloc] initWithEventList:events timeoutSeconds:self.sdk.settings.httpRequestCollectTimeoutSeconds retries:self.sdk.settings.httpRequestMaxTries retryDelaySeconds:self.sdk.settings.httpRequestRetryDelaySeconds];
                if (!request) {
                    DDNALogWarn(@"Event corruption detected, clearing out queue");
                    [self.eventStore clearOut];
                    self.uploading = NO;
                } else {
                    DDNALogDebug(@"Sending latest events to Collect: %@", request);
                    __weak typeof(self) weakSelf = self;
                    [self.collectService request:request handler:^(NSString *response, NSInteger statusCode, NSString *error) {
                        if (statusCode >= 200 && statusCode < 400) {
                            DDNALogDebug(@"Event upload completed successfully.");
                            [weakSelf.eventStore clearOut];
                        } else if (statusCode == 400) {
                            DDNALogWarn(@"Collect rejected invalid events.");
                            [weakSelf.eventStore clearOut];
                        } else {
                            DDNALogWarn(@"Event upload failed, try again later.");
                        }
                        weakSelf.uploading = NO;
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

- (void) setCrossGameUserId:(NSString *)crossGameUserId
{
    if (_started) {
        if ([crossGameUserId length] == 0) {
            DDNALogWarn(@"crossGameUserId cannot be nil or empty");
        } else if (![self.sdk.crossGameUserId isEqualToString:crossGameUserId]) {
            [[self.sdk recordEventWithName:@"ddnaRegisterCrossGameUserID" eventParams:@{
                                                                                        @"ddnaCrossGameUserID": crossGameUserId
                                                                                        }] run];
        }
    } else {
        __typeof(self) __weak weakSelf = self;
        dispatch_async(_taskQueue, ^{
            [weakSelf setCrossGameUserId:crossGameUserId];
        });
    }
}

- (void) setPushNotificationToken:(NSString *)pushNotificationToken
{
    if (_started) {
        DDNALogDebug(@"DeltaDNA SDK Set PushNotificationToken %@", pushNotificationToken);
    } else {
        __typeof(self) __weak weakSelf = self;
        dispatch_async(_taskQueue, ^{
            [weakSelf setPushNotificationToken:pushNotificationToken];
        });
    }
}
-(void) setDeviceToken:(NSData *)deviceToken{
    
    NSUInteger length = deviceToken.length;
    if (length > 0)
    {
        const unsigned char *buffer = (const unsigned char *) deviceToken.bytes;
        NSMutableString *tokenString =[NSMutableString stringWithCapacity:(length*2)];
        for(int i=0; i<length ; i++)
        {
            [tokenString appendFormat:@"%02x",buffer[i]];
        }
        self.sdk.pushNotificationToken = tokenString;
        NSLog(@"DeltaDNA SDK Set PushNotificationToken %@", tokenString);
        [[self.sdk recordEventWithName:@"notificationServices" eventParams:@{
                                                                             @"pushNotificationToken": tokenString
                                                                             }] run] ;
    }
}

- (void)clearPersistentData
{
    [self.eventStore clearAll];
    [self.actionStore clear];
}

- (void)requestSessionConfiguration:(DDNAUserManager *)userManager
{
    DDNAEngagement *configEngagement = [DDNAEngagement engagementWithDecisionPoint:@"config"];
    configEngagement.flavour = @"internal";
    [configEngagement setParam:[NSNumber numberWithUnsignedInteger:userManager.msSinceFirstSession]  forKey:@"timeSinceFirstSession"];
    [configEngagement setParam:[NSNumber numberWithUnsignedInteger:userManager.msSinceLastSession] forKey:@"timeSinceLastSession"];
    [self requestEngagement:configEngagement completionHandler:^(NSDictionary *response, NSInteger statusCode, NSError *error) {
        if (response && response[@"parameters"]) {
            NSDictionary *parameters = response[@"parameters"];
            self.eventWhitelist = parameters[@"eventsWhitelist"] ? [NSSet setWithArray:parameters[@"eventsWhitelist"]] : nil;
            self.decisionPointWhitelist = parameters[@"dpWhitelist"] ? [NSSet setWithArray:parameters[@"dpWhitelist"]] : nil;
            if (parameters[@"imageCache"]) {
                self.imageCacheList = [NSSet setWithArray:parameters[@"imageCache"]];
            }
            if (parameters[@"triggers"]) {
                NSMutableArray<DDNAEventTrigger *> *triggers = [NSMutableArray<DDNAEventTrigger *> array];
                for (NSDictionary *triggerDict in parameters[@"triggers"]) {
                    DDNAEventTrigger *t = [[DDNAEventTrigger alloc] initWithDictionary:triggerDict];
                    if (t != nil) {
                        [triggers addObject:t];
                        
                        if ([[t response][@"parameters"][@"ddnaIsPersistent"] boolValue]) {
                            [self.actionStore setParameters:[t response][@"parameters"] forTrigger:t];
                        }
                    }
                }
                NSSortDescriptor *sortName = [NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:NO];
                NSSortDescriptor *sortPriority = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
                NSArray<DDNAEventTrigger *> *sorted = [triggers sortedArrayUsingDescriptors:@[sortName, sortPriority]];
                self.eventTriggers = [NSOrderedSet orderedSetWithArray:sorted];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DDNASDKSessionConfig" object:self.sdk userInfo:@{@"config": response}];
            
            if (response[@"isCachedResponse"] && [response[@"isCachedResponse"] boolValue]) {
                DDNALogDebug(@"Updated session configuration from local cache.");
            } else {
                DDNALogDebug(@"Successfully updated session configuration.");
            }
            if ([self.sdk.delegate respondsToSelector:@selector(didConfigureSessionWithCache:)]) {
                [self.sdk.delegate didConfigureSessionWithCache:response[@"isCachedResponse"] && [response[@"isCachedResponse"] boolValue]];
            }
            
            [self downloadImageAssets];
            
        } else {
            DDNALogDebug(@"Failed to retrieve session configuration.");
            // notify caller and let them retry later
            if ([self.sdk.delegate respondsToSelector:@selector(didFailToConfigureSessionWithError:)]) {
                [self.sdk.delegate didFailToConfigureSessionWithError:error];
            }
        }
        
        // Once we're started, & session configuration has been received or failed then send default events.
        [self triggerDefaultEvents:self.sendNewPlayerEvent];
    }];
}

- (void)downloadImageAssets
{
    NSMutableArray<NSURL *> *urls = [NSMutableArray arrayWithCapacity:self.imageCacheList.count];
    for (NSString *urlStr in self.imageCacheList) {
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url != nil) {   // not malformed
            [urls addObject:url];
        }
    }
    
    [[DDNAImageCache sharedInstance] prefechImagesForURLs:urls completionHandler:^(NSInteger downloaded, NSError *error) {
        if (error == nil) {
            DDNALogDebug(@"Successfully populated image cache.");
            if ([self.sdk.delegate respondsToSelector:@selector(didPopulateImageMessageCache)]) {
                [self.sdk.delegate didPopulateImageMessageCache];
            }
        }
        else {
            DDNALogDebug(@"Failed to populate image cache.");
            if ([self.sdk.delegate respondsToSelector:@selector(didFailToPopulateImageMessageCacheWithError:)]) {
                [self.sdk.delegate didFailToPopulateImageMessageCacheWithError:error];
            }
        }
    }];
}

#pragma mark - Private Helpers

- (void) triggerDefaultEvents:(BOOL)newPlayer
{
    if (self.sentDefaultEvents) return;
    
    if (self.sdk.settings.onFirstRunSendNewPlayerEvent && newPlayer)
    {
        DDNALogDebug(@"Sending 'newPlayer' event");
        
        DDNAEvent *newPlayerEvent = [DDNAEvent eventWithName:@"newPlayer"];
        if ([DDNAClientInfo sharedInstance].countryCode!=nil) {
            [newPlayerEvent setParam:[DDNAClientInfo sharedInstance].countryCode forKey:@"userCountry"];
        }
        [[self recordEvent:newPlayerEvent] run];
        
    }
    
    if (self.sdk.settings.onStartSendGameStartedEvent)
    {
        DDNALogDebug(@"Sending 'gameStarted' event");
        
        DDNAEvent *gameStartedEvent = [DDNAEvent eventWithName:@"gameStarted"];
        if (self.sdk.clientVersion != nil) {
            [gameStartedEvent setParam:self.sdk.clientVersion forKey:@"clientVersion"];
        }
        if ([DDNAClientInfo sharedInstance].locale != nil) {
            [gameStartedEvent setParam:[DDNAClientInfo sharedInstance].locale forKey:@"userLocale"];
        }
        
        if (self.sdk.crossGameUserId != nil && [self.sdk.crossGameUserId length] != 0) {
            [gameStartedEvent setParam:self.sdk.crossGameUserId forKey:@"ddnaCrossGameUserID"];
        }
        if (self.sdk.pushNotificationToken != nil) {
            [gameStartedEvent setParam:self.sdk.pushNotificationToken forKey:@"pushNotificationToken"];
        }
        
        [[self recordEvent:gameStartedEvent] run];
    }
    
    if (self.sdk.settings.onStartSendClientDeviceEvent)
    {
        DDNALogDebug(@"Sending 'clientDevice' event");
        
        DDNAEvent *clientDeviceEvent = [DDNAEvent eventWithName:@"clientDevice"];
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].deviceName forKey:@"deviceName"];
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].deviceType forKey:@"deviceType"];
        if ([DDNAClientInfo sharedInstance].hardwareVersion!=nil) {
            [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].hardwareVersion forKey:@"hardwareVersion"];
        }
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].operatingSystem forKey:@"operatingSystem"];
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].operatingSystemVersion forKey:@"operatingSystemVersion"];
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].manufacturer forKey:@"manufacturer"];
        [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].timezoneOffset forKey:@"timezoneOffset"];
        if ([DDNAClientInfo sharedInstance].languageCode!=nil) {
            [clientDeviceEvent setParam:[DDNAClientInfo sharedInstance].languageCode forKey:@"userLanguage"];
        }
        [[self recordEvent:clientDeviceEvent] run];
    }
    
    self.sentDefaultEvents = YES;
}

- (void)appWillResignActive:(NSNotification *)notification
{
    self.lastActiveDate = [NSDate date];
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    if (self.sdk.settings.sessionTimeoutSeconds > 0) {
        NSTimeInterval backgroundSeconds = [[NSDate date] timeIntervalSinceDate:self.lastActiveDate];
        if (backgroundSeconds > self.sdk.settings.sessionTimeoutSeconds) {
            self.lastActiveDate = nil;
            if (self.sdk.started) {
                [self.sdk newSession];
            }
        }
    }
}

@end
