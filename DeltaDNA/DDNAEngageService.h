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

#import <Foundation/Foundation.h>

@class DDNAInstanceFactory;

@interface DDNAEngageRequest : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *decisionPoint;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy) NSString *flavour;
@property (nonatomic, strong) NSDictionary *parameters;

- (instancetype)initWithDecisionPoint:(NSString *)decisionPoint
                               userId:(NSString *)userId
                            sessionId:(NSString *)sessionId;

- (NSString *)description;

@end

typedef void (^DDNAEngageResponse) (NSString *response, NSInteger statusCode, NSError *error);

@interface DDNAEngageService : NSObject

@property (nonatomic, weak) DDNAInstanceFactory *factory;

- (instancetype)initWithEnvironmentKey:(NSString *)environmentKey
                             projectID:(NSString *)projectID
                             engageURL:(NSString *)engageURL
                            hashSecret:(NSString *)hashSecret
                            apiVersion:(NSString *)apiVersion
                            sdkVersion:(NSString *)sdkVersion
                              platform:(NSString *)platform
                                locale:(NSString *)locale
                        timezoneOffset:(NSString *)timezoneOffset
                          manufacturer:(NSString *)manufacturer
                operatingSystemVersion:(NSString *)operatingSystemVersion
                        timeoutSeconds:(NSInteger)timeoutSeconds
                   cacheExpiryInterval:(NSTimeInterval)cacheExpiryInterval;

- (void)request:(DDNAEngageRequest *)request handler:(DDNAEngageResponse)responseHander;

- (void)clearCache;

@end

