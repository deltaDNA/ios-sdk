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

#import "DDNANonTrackingSdk.h"
#import "DDNASDK.h"
#import "DDNACollectService.h"
#import "DDNASettings.h"
#import "DDNAEvent.h"
#import "DDNAInstanceFactory.h"
#import "DDNAUserManager.h"
#import "NSString+DeltaDNA.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNAUtils.h"
#import "DDNAEngagement.h"

@interface DDNANonTrackingSdk ()

@property (nonatomic, weak) DDNASDK *sdk;
@property (nonatomic, weak) DDNAInstanceFactory *instanceFactory;
@property (nonatomic, assign, readwrite) BOOL started;
@property (nonatomic, strong) DDNACollectService *collectService;

@end

@implementation DDNANonTrackingSdk

- (instancetype)initWithSdk:(DDNASDK *)sdk instanceFactory:(DDNAInstanceFactory *)instanceFactory
{
    if ((self = [super init])) {
        self.sdk = sdk;
        self.instanceFactory = instanceFactory;
    }
    return self;
}

- (void)startWithNewPlayer:(DDNAUserManager *)userManager
{
    // try to send forgetme event
    self.started = YES;
    
    if (userManager.doNotTrack && !userManager.forgotten) {
        DDNAEvent *forgetMe = [DDNAEvent eventWithName:@"ddnaForgetMe"];
        [forgetMe setParam:self.sdk.platform forKey:@"platform"];
        [forgetMe setParam:DDNA_SDK_VERSION forKey:@"sdkVersion"];
        [forgetMe setParam:userManager.advertisingId forKey:@"ddnaAdvertisingId"];
        
        NSMutableDictionary *eventSchema = [NSMutableDictionary dictionaryWithDictionary:[forgetMe dictionary]];
        [eventSchema setObject:self.sdk.userID forKey:@"userID"];
        [eventSchema setObject:self.sdk.sessionID forKey:@"sessionID"];
        [eventSchema setObject:[[NSUUID UUID] UUIDString] forKey:@"eventUUID"];
        [eventSchema setObject:[DDNAUtils getCurrentTimestamp] forKey:@"eventTimestamp"];
        
        NSArray *events = [NSArray arrayWithObject:[NSString stringWithContentsOfDictionary:eventSchema]];
        
        DDNACollectRequest *request = [[DDNACollectRequest alloc] initWithEventList:events timeoutSeconds:self.sdk.settings.httpRequestCollectTimeoutSeconds retries:self.sdk.settings.httpRequestMaxTries retryDelaySeconds:self.sdk.settings.httpRequestRetryDelaySeconds];
        if (request) {
            DDNALogDebug(@"Sending forget me event to Collect: %@", request);
            DDNACollectService *collectService = [self.instanceFactory buildCollectService];
            [collectService request:request handler:^(NSString *response, NSInteger statusCode, NSString *error) {
                if (statusCode >= 200 && statusCode < 400) {
                    DDNALogDebug(@"Forget me event successfully sent.");
                    userManager.forgotten = YES;
                } else if (statusCode == 400) {
                    DDNALogWarn(@"Collect rejected forget me event as invalid.");
                } else {
                    DDNALogWarn(@"Sending forget me event failed.");
                }
            }];
            self.collectService = collectService;
        }
    } else {
        DDNALogDebug(@"Already forgotten this user.");
    }
}

- (void)newSession
{
    // do nothing
}

- (void)stop
{
    self.started = NO;
}

- (DDNAEventAction *)recordEvent:(DDNAEvent *)event
{
    return [[DDNAEventAction alloc] init];
}

- (void)recordEvent:(DDNAEvent *)event actionHandler:(id<DDNAEngageActionHandler>)actionHandler
{
    // do nothing
}

- (void)requestEngagement:(DDNAEngagement *)engagement
        completionHandler:(void(^)(NSDictionary *response, NSInteger statusCode, NSError *error))completionHandler
{
    if (completionHandler) {
        completionHandler(@{@"parameters":@{}}, 200, nil);
    }
}

- (void)requestEngagement:(DDNAEngagement *)engagement engagementHandler:(void(^)(DDNAEngagement *))engagementHandler
{
    engagement.raw = @"{\"parameters\":{}}";
    engagement.statusCode = 200;
    engagement.error = nil;
    
    engagementHandler(engagement);
}

- (void) recordPushNotification: (NSDictionary *) pushNotification
                      didLaunch: (BOOL) didLaunch
{
    // do nothing
}

- (void)upload
{
    // do nothing
}

- (void)clearPersistentData
{
    // do nothing
}

- (void)setPushNotificationToken:(NSString *)token
{
    self.sdk.pushNotificationToken = token;
}

- (void)downloadImageAssets
{
    // do nothing
    if ([self.sdk.delegate respondsToSelector:@selector(didPopulateImageMessageCache)]) {
        [self.sdk.delegate didPopulateImageMessageCache];
    }
}


- (void)requestSessionConfiguration:(DDNAUserManager *)userManager
{
    // do nothing
    if ([self.sdk.delegate respondsToSelector:@selector(didConfigureSessionWithCache:)]) {
        [self.sdk.delegate didConfigureSessionWithCache:NO];
    }
    [self downloadImageAssets];
}


- (BOOL)isUploading
{
    return NO;
}

@end
