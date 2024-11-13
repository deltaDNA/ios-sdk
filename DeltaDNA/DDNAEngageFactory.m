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

#import "DDNAEngageFactory.h"
#import "DDNAEngagement.h"
#import "DDNAParams.h"
#import "DDNAImageMessage.h"
#import "DDNASDK.h"


@interface DDNAEngageFactory ()

@property (nonatomic, weak) DDNASDK *sdk;

@end

@implementation DDNAEngageFactory

- (instancetype)initWithDDNASDK:(id)sdk
{
    if ((self = [super init])) {
        self.sdk = sdk;
    }
    return self;
}

- (void)requestGameParametersForDecisionPoint:(NSString *)decisionPoint
                                      handler:(GameParametersHandler)handler
{
    [self requestGameParametersForDecisionPoint:decisionPoint parameters:nil handler:handler];
}

- (void)requestGameParametersForDecisionPoint:(NSString *)decisionPoint
                                   parameters:(nullable DDNAParams *)parameters
                                      handler:(GameParametersHandler)handler
{
    [DDNAEngageFactory validateDecisionPoint:decisionPoint];
    
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    NSDictionary *paramsCopy = [[NSDictionary alloc] initWithDictionary:parameters.dictionary copyItems:YES];
    
    // Put the old DDNA decisionPoint name into the parameter block for remoteConfig so we can use JEXL to trigger by decisionPoint
    [engagement setParam:decisionPoint forKey:@"decisionPoint"];
    
    for (NSString *key in paramsCopy) {
        [engagement setParam:[parameters.dictionary valueForKey:key] forKey:key];
    }
    
    [self.sdk requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        if (response != nil && response.json != nil && response.json[@"configs"] && response.json[@"configs"][@"settings"]) {
            handler(response.json[@"configs"][@"settings"]);
        } else {
            handler(@{});
        }
    }];
}

- (void)requestImageMessageForDecisionPoint:(NSString *)decisionPoint
                                    handler:(ImageMessageHandler)handler
{
    [self requestImageMessageForDecisionPoint:decisionPoint parameters:nil handler:handler];
}

- (void)requestImageMessageForDecisionPoint:(NSString *)decisionPoint
                                 parameters:(nullable DDNAParams *)parameters
                                    handler:(ImageMessageHandler)handler
{
    [DDNAEngageFactory validateDecisionPoint:decisionPoint];
    
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    NSDictionary *paramsCopy = [[NSDictionary alloc] initWithDictionary:parameters.dictionary copyItems:YES];
    for (NSString *key in paramsCopy) {
        [engagement setParam:[parameters.dictionary valueForKey:key] forKey:key];
    }
    
    [self.sdk requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        DDNAImageMessage *imageMessage = [[DDNAImageMessage alloc] initWithEngagement:response];
        handler(imageMessage);
    }];
    
    
}

#pragma mark - private methods

+ (void)validateDecisionPoint:(NSString *)decisionPoint
{
    if (decisionPoint == nil || decisionPoint.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"decisionPoint cannot be nil or empty" userInfo:nil]);
    }
}

@end
