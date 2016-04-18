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

#import "DDNACollectService.h"
#import "DDNANetworkRequest.h"
#import "DDNAInstanceFactory.h"
#import "DDNALog.h"
#import "NSString+DeltaDNA.h"
#import "NSDictionary+DeltaDNA.h"
#import "NSURL+DeltaDNA.h"

@interface DDNACollectRequest ()

@property (nonatomic, copy) NSString *eventJSON;
@property (nonatomic, assign) NSInteger eventCount;
@property (nonatomic, assign) NSInteger timeoutSeconds;
@property (nonatomic, assign) NSInteger retries;
@property (nonatomic, assign) NSInteger retryDelaySeconds;

@end

@implementation DDNACollectRequest

- (instancetype)initWithEventList:(NSArray *)eventList timeoutSeconds:(NSInteger)timeoutSeconds retries:(NSInteger)retries retryDelaySeconds:(NSInteger)retryDelaySeconds
{
    if ((self = [super self])) {
        if (!eventList || eventList.count == 0) return nil;
        
        NSMutableArray *events = [NSMutableArray arrayWithCapacity:eventList.count];
        for (NSString *event in eventList) {
            NSDictionary *obj = [NSDictionary dictionaryWithJSONString:event];
            if (obj) [events addObject:obj];
            else {
                DDNALogWarn(@"Skipping event with invalid JSON: %@", event);
            }
        }
        
        self.eventJSON = [NSString stringWithContentsOfDictionary:@{@"eventList": events}];
        if (!self.eventJSON) return nil;    // corrupt JSON!
        self.eventCount = eventList.count;
        self.timeoutSeconds = timeoutSeconds;
        self.retries = retries;
        self.retryDelaySeconds = retryDelaySeconds;
    }
    return self;
}

- (NSString *)toJSON
{
    return self.eventJSON;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CollectRequest] Events=%ld Bytes=%lu",
            (long)self.eventCount,
            [self.eventJSON dataUsingEncoding:NSUTF8StringEncoding].length];
}

@end

@interface DDNACollectService () <DDNANetworkRequestDelegate>

@property (nonatomic, copy) NSString *environmentKey;
@property (nonatomic, copy) NSString *collectURL;
@property (nonatomic, copy) NSString *hashSecret;
@property (nonatomic, strong) NSMapTable *requests;

@end

@implementation DDNACollectService

- (instancetype)initWithEnvironmentKey:(NSString *)environmentKey collectURL:(NSString *)collectURL hashSecret:(NSString *)hashSecret
{
    if ((self = [super self])) {
        self.environmentKey = environmentKey;
        self.collectURL = collectURL;
        self.hashSecret = hashSecret;
        self.requests = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)request:(DDNACollectRequest *)collectRequest handler:(DDNACollectResponse)responseHandler
{
    if (!collectRequest || !responseHandler) return;
    
    NSString *jsonPayload = [collectRequest toJSON];
    
    NSURL *url = [NSURL URLWithCollectEndpoint:self.collectURL
                               environmentKey:self.environmentKey
                                      payload:jsonPayload
                                   hashSecret:self.hashSecret];
    
    DDNANetworkRequest *networkRequest = [self.factory buildNetworkRequestWithURL:url jsonPayload:jsonPayload delegate:self];
    if (networkRequest) {
        [self.requests setObject:@{ @"request": collectRequest, @"response": responseHandler} forKey:networkRequest];
        networkRequest.timeoutSeconds = collectRequest.timeoutSeconds;
        [networkRequest send];
    }

}

#pragma mark - DDNANetworkRequestDelegate

- (void)request:(DDNANetworkRequest *)request didReceiveResponse:(NSString *)response statusCode:(NSInteger)statusCode
{
    NSDictionary *collect = [self.requests objectForKey:request];
    if (collect != nil) {
        DDNACollectResponse responseHandler = collect[@"response"];
        if (responseHandler) responseHandler(response, statusCode, nil);
        [self.requests removeObjectForKey:request];
    } else {
        DDNALogDebug(@"Network request not found!");
    }

}

- (void)request:(DDNANetworkRequest *)request didFailWithResponse: (NSString *)response statusCode:(NSInteger)statusCode error:(NSError *)error
{
    BOOL retry = NO;
    NSDictionary *collect = [self.requests objectForKey:request];
    if (collect != nil) {
        DDNACollectRequest *collectRequest = collect[@"request"];
        DDNACollectResponse responseHandler = collect[@"response"];
        if ((statusCode == 408 || error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorNetworkConnectionLost) && collectRequest.retries > 0) {    // timeout
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(collectRequest.retryDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [request send];
            });
            collectRequest.retries--;
            retry = YES;
        } else {
            if (responseHandler) responseHandler(response, statusCode, [error localizedDescription]);
            [self.requests removeObjectForKey:request];
        }
    } else {
        DDNALogDebug(@"Network request not found!");
    }
    
    DDNALogDebug(@"Collect request failed! %ld %@ %@", (long)statusCode, [error localizedDescription], retry ? @"Retrying..." : @"");
}

@end
