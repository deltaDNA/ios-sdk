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

#import "DDNAActionStore.h"
#import "DDNAEventActionHandler.h"
#import "DDNAEventTrigger.h"
#import "DDNAEngagement.h"
#import "NSString+DeltaDNA.h"
#import "DDNALog.h"
#import "DDNAImageCache.h"


@interface DDNAGameParametersHandler ()

@property (nonatomic, copy) void (^handler)(NSDictionary *);

@end

@implementation DDNAGameParametersHandler

- (instancetype)initWithHandler:(void (^)(NSDictionary *))handler
{
    if ((self = [super init])) {
        self.handler = handler;
    }
    return self;
}

- (BOOL)handleEventTrigger:(DDNAEventTrigger *)eventTrigger store:(DDNAActionStore *)store
{
    if ([eventTrigger.actionType isEqualToString:self.type]) {
        NSDictionary *persistedParams = [store parametersForTrigger:eventTrigger];
        
        if (persistedParams) {
            [store removeForTrigger:eventTrigger];
            self.handler(persistedParams);
        } else {
            self.handler([NSDictionary dictionaryWithDictionary:eventTrigger.response[@"parameters"]]);
        }
        
        return YES;
    }
    return NO;
}

- (NSString *)type {
    return @"gameParameters";
}

@end


@interface DDNAImageMessageHandler () <DDNAImageMessageDelegate>

@property (nonatomic, copy) void (^handler)(DDNAImageMessage *);
@property (nonatomic, strong) id strongSelf;

@end

@implementation DDNAImageMessageHandler

- (instancetype)initWithHandler:(void (^)(DDNAImageMessage *))handler
{
    if ((self = [super init])) {
        self.handler = handler;
    }
    return self;
}

- (BOOL)handleEventTrigger:(DDNAEventTrigger *)eventTrigger store:(DDNAActionStore *)store
{
    if ([eventTrigger.actionType isEqualToString:self.type]) {
        // Only fire if the resources are already loaded for the trigger
        
        NSString *imageUrl = eventTrigger.response[@"image"] ? eventTrigger.response[@"image"][@"url"] : nil;
        if (imageUrl && [DDNAImageCache.sharedInstance imageForURL:[NSURL URLWithString:imageUrl]]) {
            NSDictionary *persistedParams = [store parametersForTrigger:eventTrigger];
            NSDictionary *response = [NSMutableDictionary dictionaryWithDictionary:eventTrigger.response];
            if (persistedParams) {
                [response setValue:persistedParams forKey:@"parameters"];
            }
            
            DDNAEngagement *dummyEngagement = [[DDNAEngagement alloc] initWithDecisionPoint:@"trigger"];
            dummyEngagement.statusCode = 200;
            dummyEngagement.raw = [NSString stringWithContentsOfDictionary:response];
            
            DDNAImageMessage *imageMessage = [[DDNAImageMessage alloc] initWithEngagement:dummyEngagement];
            imageMessage.delegate = self;
            // the ImageMessage only holds a weak ref to us, this ensure we stick about to get the response
            // on the delegate
            self.strongSelf = self;
            
            if (persistedParams) {
                [store removeForTrigger:eventTrigger];
            }
            
            [imageMessage fetchResources];
            
            return YES;
        }
    }
    return NO;
}

- (NSString *)type
{
    return @"imageMessage";
}

- (void)didFailToReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage withReason:(NSString *)reason
{
    DDNALogWarn(@"Failed to retrieve images for image message.");
}

- (void)didReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage
{
    self.strongSelf = nil;
    self.handler(imageMessage);
}

- (void)onActionImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name type:(NSString *)type value:(NSString *)value
{
    
}

- (void)onDismissImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name {
    
}

@end
