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

#import "DDNAEngageService.h"
#import "DDNANetworkRequest.h"
#import "DDNAInstanceFactory.h"
#import "NSURL+DeltaDNA.h"
#import "NSString+DeltaDNA.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNALog.h"
#import "DDNACache.h"

@interface DDNAEngageRequest ()

@property (nonatomic, copy) NSString *decisionPoint;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *sessionId;

@end

@implementation DDNAEngageRequest

- (instancetype)initWithDecisionPoint:(NSString *)decisionPoint
                               userId:(NSString *)userId
                            sessionId:(NSString *)sessionId
{
    if ((self = [super self])) {
        if (!decisionPoint || !userId || !sessionId) return nil;
        self.decisionPoint = decisionPoint;
        self.userId = userId;
        self.sessionId = sessionId;
        self.flavour = @"engagement";
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[EngageRequest] %@(%@) %@",
            self.decisionPoint,
            self.flavour,
            (self.parameters ? self.parameters : @{})];
}

@end

static NSString *const kEngagementCacheKey = @"Engagement %@(%@)";

@interface DDNAEngageService () <DDNANetworkRequestDelegate>

@property (nonatomic, copy) NSString *engageURL;
@property (nonatomic, copy) NSString *environmentKey;
@property (nonatomic, copy) NSString *hashSecret;
@property (nonatomic, copy) NSString *apiVersion;
@property (nonatomic, copy) NSString *sdkVersion;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *timezoneOffset;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *operatingSystemVersion;
@property (nonatomic, assign) NSInteger timeoutSeconds;
@property (nonatomic, strong) NSMapTable *requests;

@end

@implementation DDNAEngageService

- (instancetype)initWithEnvironmentKey:(NSString *)environmentKey
                             engageURL:(NSString *)engageURL
                            hashSecret:(NSString *)hashSecret
                            apiVersion:(NSString *)apiVersion
                            sdkVersion:(NSString *)sdkVersion
                              platform:(NSString *)platform
                        timezoneOffset:(NSString *)timezoneOffset
                          manufacturer:(NSString *)manufacturer
                operatingSystemVersion:(NSString *)operatingSystemVersion
                        timeoutSeconds:(NSInteger)timeoutSeconds
{
    if ((self = [super self])) {
        self.environmentKey = environmentKey;
        self.engageURL = engageURL;
        self.hashSecret = hashSecret;
        self.apiVersion = apiVersion;
        self.sdkVersion = sdkVersion;
        self.platform = platform;
        self.timezoneOffset = timezoneOffset;
        self.manufacturer = manufacturer;
        self.operatingSystemVersion = operatingSystemVersion;
        self.timeoutSeconds = timeoutSeconds;
        self.requests = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)request:(DDNAEngageRequest *)engageRequest handler:(DDNAEngageResponse)responseHandler
{
    if (!engageRequest || !responseHandler) return;
    
    NSDictionary *request = @{
        @"decisionPoint": engageRequest.decisionPoint,
        @"flavour": engageRequest.flavour,
        @"parameters": engageRequest.parameters ? engageRequest.parameters : @{},
        @"userID": engageRequest.userId,
        @"sessionID": engageRequest.sessionId,
        @"version": self.apiVersion,
        @"sdkVersion": self.sdkVersion,
        @"platform": self.platform,
        @"timezoneOffset": self.timezoneOffset,
        @"manufacturer": self.manufacturer,
        @"operatingSystemVersion": self.operatingSystemVersion
    };
    
    NSString *jsonPayload = [NSString stringWithContentsOfDictionary:request];
    
    NSURL *url = [NSURL URLWithEngageEndpoint:self.engageURL
                               environmentKey:self.environmentKey
                                      payload:jsonPayload
                                   hashSecret:self.hashSecret];
    
    DDNANetworkRequest *networkRequest = [self.factory buildNetworkRequestWithURL:url jsonPayload:jsonPayload delegate:self];
    if (networkRequest) {
        [self.requests setObject:@{ @"request": engageRequest, @"response": responseHandler} forKey:networkRequest];
        networkRequest.timeoutSeconds = self.timeoutSeconds;
        [networkRequest send];
    }
}

#pragma mark - DDNANetworkRequestDelegate;

- (void)request:(DDNANetworkRequest *)request didReceiveResponse:(NSString *)response statusCode:(NSInteger)statusCode
{
    NSDictionary *engagement = [self.requests objectForKey:request];
    if (engagement != nil) {
        DDNAEngageRequest *engageRequest = engagement[@"request"];
        DDNAEngageResponse responseHandler = engagement[@"response"];
        // We don't need to cache based on real-time criteria, better to use the last response that's close enough.
        [[DDNACache sharedCache] setObject:response forKey:[NSString stringWithFormat:kEngagementCacheKey, engageRequest.decisionPoint, engageRequest.flavour]];
        if (responseHandler) responseHandler(response, statusCode, nil);
        [self.requests removeObjectForKey:request];
    } else {
        DDNALogWarn(@"Network request not found!");
    }
}

- (void)request:(DDNANetworkRequest *)request didFailWithResponse: (NSString *)response statusCode:(NSInteger)statusCode error:(NSError *)error
{
    NSDictionary *engagement = [self.requests objectForKey:request];
    if (engagement != nil) {
        DDNAEngageRequest *engageRequest = engagement[@"request"];
        DDNAEngageResponse responseHandler = engagement[@"response"];
        NSString *cachedResponse = [[DDNACache sharedCache] objectForKey:[NSString stringWithFormat:kEngagementCacheKey, engageRequest.decisionPoint, engageRequest.flavour]];
        if (responseHandler != nil) {
            if (cachedResponse != nil) {
                NSMutableDictionary *jsonObj = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithJSONString:cachedResponse]];
                [jsonObj setObject:@YES forKey:@"isCachedResponse"];
                cachedResponse = [NSString stringWithContentsOfDictionary:jsonObj];
            } else {
                cachedResponse = response;
            }
            responseHandler(cachedResponse, statusCode, error);
        }
        [self.requests removeObjectForKey:request];
    } else {
        DDNALogWarn(@"Network request not found!");
    }
}

@end
