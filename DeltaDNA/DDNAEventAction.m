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

#import "DDNAEventAction.h"
#import "DDNAEventTrigger.h"
#import "DDNASdkInterface.h"
#import "DDNAEvent.h"
#import "DDNALog.h"

@interface DDNAEventAction ()

@property (nonatomic, strong) NSDictionary *eventSchema;
@property (nonatomic, strong) NSOrderedSet<DDNAEventTrigger *> *eventTriggers;
@property (nonatomic, weak) id<DDNASdkInterface> sdk;
@property (nonatomic, weak) DDNAActionStore *store;
@property (nonatomic, strong) NSMutableOrderedSet< id<DDNAEventActionHandler> > *handlers;

@end

@implementation DDNAEventAction

- (instancetype)initWithEventSchema:(NSDictionary *)eventSchema eventTriggers:(NSOrderedSet<DDNAEventTrigger *> *)eventTriggers sdk:(id<DDNASdkInterface>)sdk store:(DDNAActionStore *)store
{
    if ((self = [super init])) {
        self.eventSchema = [NSDictionary dictionaryWithDictionary:eventSchema];
        self.eventTriggers = eventTriggers;
        self.sdk = sdk;
        self.store = store;
        self.handlers = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

- (void)addHandler:(nonnull id<DDNAEventActionHandler>)handler
{
    [self.handlers addObject:handler];
}

- (void)run
{
    for (DDNAEventTrigger *t in self.eventTriggers) {
        if ([t respondsToEventSchema:self.eventSchema]) {
            for (id<DDNAEventActionHandler> h in self.handlers) {
                if ([h handleEventTrigger:t store:self.store]) {
                    break;
                }
            }
            // send event...
            DDNAEvent *actionTriggered = [DDNAEvent eventWithName:@"ddnaEventTriggeredAction"];
            [actionTriggered setParam:[NSNumber numberWithUnsignedInteger:t.campaignId] forKey:@"ddnaEventTriggeredCampaignID"];
            [actionTriggered setParam:[NSNumber numberWithInteger:t.priority] forKey:@"ddnaEventTriggeredCampaignPriority"];
            [actionTriggered setParam:[NSNumber numberWithUnsignedInteger:t.variantId] forKey:@"ddnaEventTriggeredVariantID"];
            [actionTriggered setParam:t.actionType forKey:@"ddnaEventTriggeredActionType"];
            [actionTriggered setParam:[NSNumber numberWithUnsignedInteger:t.count] forKey:@"ddnaEventTriggeredSessionCount"];
            
            if (t.campaignName) {
                [actionTriggered setParam:t.campaignName forKey:@"ddnaEventTriggeredCampaignName"];
            }
            if (t.variantName) {
                [actionTriggered setParam:t.variantName forKey:@"ddnaEventTriggeredVariantName"];
            }
            
            [self.sdk recordEvent:actionTriggered];
            return;
        }
    }
}

@end
