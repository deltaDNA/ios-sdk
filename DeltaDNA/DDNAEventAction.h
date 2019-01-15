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

#import <Foundation/Foundation.h>
#import "DDNAEventActionHandler.h"
#import "DDNASettings.h"

@class DDNAActionStore;
@class DDNAEventTrigger;
@protocol DDNASdkInterface;

@interface DDNAEventAction : NSObject

/**
 An action associated with an event, and the event triggers that could contain a matching campaign.
 */
- (instancetype)initWithEventSchema:(NSDictionary *)eventSchema eventTriggers:(NSOrderedSet<DDNAEventTrigger *> *)eventTriggers sdk:(id<DDNASdkInterface>)sdk store:(DDNAActionStore *)store settings:(DDNASettings *)settings;

/**
 Register a handler to handle an event trigger campaign action.
 */
- (void)addHandler:(nonnull id<DDNAEventActionHandler>)handler;

/**
 Evaluates the event it was generated from against all event triggered campaigns, and calls the first matching handler.
 */
- (void)run;

@end
