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
#import "DDNATransaction.h"

#import <UIKit/UIKit.h>
#import <DeltaDNA/DeltaDNA-Swift.h>

@interface DDNASDK ()

@property (nonatomic, copy, readwrite) NSString *environmentKey;
@property (nonatomic, copy, readwrite) NSString *collectURL;
@property (nonatomic, copy, readwrite) NSString *engageURL;
@property (nonatomic, copy, readwrite) NSString *sessionID;

@property (nonatomic, strong) DDNAEngageFactory *engageFactory;

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
        self.consentTracker = [[DDNAConsentTracker alloc] init];
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
        if (![self.consentTracker hasCheckedForConsent]) {
            NSLog(@"Since version 5.0.0 of the deltaDNA SDK, you are required to check for required user consents before starting the SDK.\
                  Any events recorded will not be sent until user consent is recorded in the SDK.");
        }
            
        self.environmentKey = environmentKey;
        self.collectURL = [DDNAUtils fixURL: collectURL];
        self.engageURL = [DDNAUtils fixURL: engageURL];
        self.engageFactory = [[DDNAEngageFactory alloc] initWithDDNASDK:self];
        // if not set by client...
        if ([NSString stringIsNilOrEmpty:self.platform]) {
            self.platform = [DDNAClientInfo sharedInstance].platform;
        }
        
        self.userManager.userId = userID;
        
        if (self.userManager.doNotTrack || [self.consentTracker isConsentDenied]) {
            self.impl = [[DDNANonTrackingSdk alloc] initWithSdk:self instanceFactory:DDNAInstanceFactory.sharedInstance];
        } else {
            self.impl = [[DDNATrackingSdk alloc] initWithSdk:self instanceFactory:DDNAInstanceFactory.sharedInstance];
        }
        
        [self handleEnvironmentChanges];
        
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

/*
 Detects if the environment has changed since the last app startup. We assume this method is called after the
 environment key on self has been initialised in the start method. This method will clear out the event store and cache
 if the environment changes - this is to ensure that events are not sent to the wrong environment during testing.
 */
- (void) handleEnvironmentChanges
{
    static NSString *previousEnvironmentUserDefaultKey = @"DDNA_PREVIOUS_ENV";
    
    @synchronized (self) {
        NSString *previousEnv = [[NSUserDefaults standardUserDefaults] stringForKey:previousEnvironmentUserDefaultKey];
        if (previousEnv != nil && previousEnv.length != 0 && previousEnv != self.environmentKey) {
            DDNALogDebug(@"Detected an environment configuration change from %@ to %@, clearing out cached events from previous environment.", previousEnv, self.environmentKey);
            [self.impl clearPersistentData];
        }
        [[NSUserDefaults standardUserDefaults] setValue:self.environmentKey forKey:previousEnvironmentUserDefaultKey];
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
- (void) recordSignalTrackingSessionEvent
{
    if (@available(iOS 12.0, *)) {
        if ([_appStoreId length] == 0 || [_appleDeveloperId length] == 0) {
            // Check for existance of required fields. Note that in Objective-C, null is equivalent to 0 length.
            DDNALogWarn(@"Pinpointer events require an app store ID and an Apple developer ID to be registered in the SDK, no event will be sent");
            return;
        }
        DDNAEvent *event = [[DDNAPinpointer shared] createSignalTrackingSessionEvent];
        [self recordEvent:event];
    } else {
        DDNALogWarn(@"Audience pinpointer is not supported on iOS versions older than 12");
    }
}

- (void) recordSignalTrackingInstallEvent
{
    if (@available(iOS 12.0, *)) {
        if ([_appStoreId length] == 0 || [_appleDeveloperId length] == 0) {
            // Check for existance of required fields. Note that in Objective-C, null is equivalent to 0 length.
            DDNALogWarn(@"Pinpointer events require an app store ID and an Apple developer ID to be registered in the SDK, no event will be sent");
            return;
        }
        DDNAEvent *event = [[DDNAPinpointer shared] createSignalTrackingInstallEvent];
        [self recordEvent:event];
    } else {
        DDNALogWarn(@"Audience pinpointer is not supported on iOS versions older than 12");
    }
}

- (void) recordSignalTrackingPurchaseEventWithRealCurrencyAmount
    :(NSNumber *)realCurrencyAmount
    realCurrencyType:(NSString *)realCurrencyType
    transactionID:(NSString *)transactionID
    transactionReceipt:(NSString *)transactionReceipt
{
    if (@available(iOS 12.0, *)) {
        if ([_appStoreId length] == 0 || [_appleDeveloperId length] == 0) {
            // Check for existance of required fields. Note that in Objective-C, null is equivalent to 0 length.
            DDNALogWarn(@"Pinpointer events require an app store ID and an Apple developer ID to be registered in the SDK, no event will be sent");
            return;
        }
        DDNAEvent *event = [DDNAPinpointer.shared createSignalTrackingPurchaseEventWithRealCurrencyAmount:realCurrencyAmount realCurrencyType:realCurrencyType transactionID:transactionID];
        [self recordEvent:event];
        
        if ([DDNASDK sharedInstance].settings.automaticallyGenerateTransactionForAudiencePinpointer) {
            DDNAProduct *placeholderProduct = [DDNAProduct product];
            DDNATransaction *transactionEvent = [DDNATransaction transactionWithName:@"Pinpointer Signal Transaction" type:@"PURCHASE" productsReceived:placeholderProduct productsSpent:placeholderProduct];
            [transactionEvent setReceipt:transactionReceipt];
            [transactionEvent setTransactionId:transactionID];
            [transactionEvent setServer:@"APPLE"];
            [self recordEvent:transactionEvent];
        }
    } else {
        DDNALogWarn(@"Audience pinpointer is not supported on iOS versions older than 12");
    }
}

#pragma mark - PIPL Consent

- (void) isPiplConsentRequired :(void(^)(BOOL, NSError *))callback
{
    [self.consentTracker isPiplConsentRequiredWithCallback:^(BOOL isRequired, NSError *error) {
        if ([self hasStarted] && !isRequired && error == nil) {
            // Earlier configuration requests will have failed, and the refetch in setConsent won't be called,
            // so we need to refresh here to get e.g. engage configs
            [self requestSessionConfiguration];
        }
        callback(isRequired, error);
    }];
}

- (void) setPiplConsentForDataUse :(BOOL)dataUse andDataExport:(BOOL)dataExport
{
    if (!dataUse || !dataExport) {
        [self.impl clearPersistentData];
        [self forgetMe];
    } else {
        if ([self hasStarted]) {
            // Earlier configuration requests will have failed, so we need to refresh here to get e.g. engage configs
            [self requestSessionConfiguration];
        }
    }
    
    [self.consentTracker setPiplUseConsent:dataUse];
    [self.consentTracker setPiplExportConsent:dataExport];
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
