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
#import "DDNAEvent.h"
#import "DDNALog.h"
#import "DDNAClientInfo.h"
#import "DDNAUtils.h"
#import "NSString+DeltaDNA.h"
#import "DDNAEngageFactory.h"
#import "DDNAUserManager.h"
#import "DDNASdkInterface.h"
#import "DDNATrackingSdk.h"
#import "DDNANonTrackingSdk.h"
#import "DDNAInstanceFactory.h"

#import <UIKit/UIKit.h>
#import <DeltaDNA/DeltaDNA-Swift.h>

@interface DDNASDK ()

@property (nonatomic, copy, readwrite) NSString *environmentKey;
@property (nonatomic, copy, readwrite) NSString *collectURL;
@property (nonatomic, copy, readwrite) NSString *engageURL;
@property (nonatomic, copy, readwrite) NSString *sessionID;

@property (nonatomic, strong) DDNAEngageFactory *engageFactory;

@property (nonatomic, strong) DDNAUserManager *userManager;
@property (nonatomic, strong) id<DDNASdkInterface> impl;

@end

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
        self.userManager = [[DDNAUserManager alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
        self.settings = [[DDNASettings alloc] init];
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
    @synchronized(self) {
        self.environmentKey = environmentKey;
        self.collectURL = [DDNAUtils fixURL: collectURL];
        self.engageURL = [DDNAUtils fixURL: engageURL];
        self.engageFactory = [[DDNAEngageFactory alloc] initWithDDNASDK:self];
        // if not set by client...
        if ([NSString stringIsNilOrEmpty:self.platform]) {
            self.platform = [DDNAClientInfo sharedInstance].platform;
        }
        
        self.userManager.userId = userID;
        
        if (self.userManager.doNotTrack) {
            self.impl = [[DDNANonTrackingSdk alloc] initWithSdk:self instanceFactory:DDNAInstanceFactory.sharedInstance];
        } else {
            self.impl = [[DDNATrackingSdk alloc] initWithSdk:self instanceFactory:DDNAInstanceFactory.sharedInstance];
        }
        
        [self.impl startWithNewPlayer:self.userManager];
    }
}

- (void) newSession
{
    @synchronized(self) {
        self.sessionID = [DDNAUtils generateSessionID];
        [self.impl requestSessionConfiguration:self.userManager];
        [self.userManager setLastSession:[NSDate date]];
        [self.impl newSession];
    }
}

- (void) stop
{
    @synchronized(self) {
        [self.impl stop];
    }
}

- (DDNAEventAction *)recordEvent:(DDNAEvent *)event
{
    @synchronized(self) {
        return [self.impl recordEvent:event];
    }
}

- (DDNAEventAction *)recordEventWithName:(NSString *)eventName
{
    return [self recordEvent:[DDNAEvent eventWithName:eventName]];
}

- (DDNAEventAction *)recordEventWithName:(NSString *)eventName eventParams:(NSDictionary *)eventParams
{
    DDNAEvent *event = [DDNAEvent eventWithName:eventName];
    for (NSString *key in eventParams) {
        [event setParam:eventParams[key] forKey:key];
    }
    
    return [self recordEvent:event];
}

- (void)requestEngagement:(DDNAEngagement *)engagement completionHandler:(void (^)(NSDictionary *, NSInteger, NSError *))completionHandler
{
    @synchronized(self) {
        [self.impl requestEngagement:engagement completionHandler:completionHandler];
    }
}

- (void)requestEngagement:(DDNAEngagement *)engagement engagementHandler:(void (^)(DDNAEngagement *))engagementHandler
{
    @synchronized(self) {
        [self.impl requestEngagement:engagement engagementHandler:engagementHandler];
    }
}

- (void) recordPushNotification:(NSDictionary *)pushNotification didLaunch:(BOOL)didLaunch
{
    @synchronized(self) {
        [self.impl recordPushNotification:pushNotification didLaunch:didLaunch];
    }
}

- (void)requestSessionConfiguration
{
    @synchronized(self) {
        [self.impl requestSessionConfiguration:self.userManager];
    }
}

- (void)downloadImageAssets
{
    @synchronized(self) {
        [self.impl downloadImageAssets];
    }
}

- (void) upload
{
    @synchronized(self) {
        [self.impl upload];
    }
}

- (void) clearPersistentData
{
    @synchronized(self) {
        if (self.hasStarted) {
            [self stop];
        }
        [self.userManager clearPersistentData];
        [self.impl clearPersistentData];
    }
}

+ (void)setLogLevel:(DDNALogLevel)logLevel
{
    [DDNALog setLogLevel:logLevel];
}

- (void)forgetMe
{
    if ([self.impl isKindOfClass:[DDNATrackingSdk class]]) {
        DDNALogDebug(@"Switching tracking sdk to non tracking sdk");
        self.userManager.doNotTrack = YES;
        [self.impl stop];
        self.impl = [[DDNANonTrackingSdk alloc] initWithSdk:self instanceFactory:DDNAInstanceFactory.sharedInstance];
        [self.impl startWithNewPlayer:self.userManager];
    }
}

#pragma mark - Audience Pinpointer
- (void) recordSignalTrackingSessionEvent :(NSString *) developerId
{
    DDNAEvent *event = [DDNAPinpointer.shared createSignalTrackingSessionEventWithDeveloperId:developerId];
    [self recordEvent:event];
}

- (void) recordSignalTrackingPurchaseEvent :(NSString *) developerId :(NSNumber *) realCurrencyAmount :(NSString *) realCurrencyType
{
    DDNAEvent *event = [DDNAPinpointer.shared createSignalTrackingPurchaseEventWithRealCurrencyAmount:realCurrencyAmount realCurrencyType:realCurrencyType developerId:developerId];
    [self recordEvent:event];
}

#pragma mark - Client Configuration Properties

- (NSString *) userID
{
    return self.userManager.userId;
}

- (NSString *) crossGameUserId
{
    return self.userManager.crossGameUserId;
}

- (void) setCrossGameUserId:(NSString *)crossGameUserId
{
    [self.userManager setCrossGameUserId:crossGameUserId];
    [self.impl setCrossGameUserId:crossGameUserId];
}

- (void) setPushNotificationToken:(NSString *)pushNotificationToken
{
    _pushNotificationToken = pushNotificationToken;
    [self.impl setPushNotificationToken:pushNotificationToken];
}

-(void) setDeviceToken:(NSData *)deviceToken
{
    _deviceToken = deviceToken;
    [self.impl setDeviceToken:deviceToken];
}

- (BOOL)hasStarted
{
    return [self.impl hasStarted];
}

- (BOOL)isUploading
{
    return [self.impl isUploading];
}

@end
