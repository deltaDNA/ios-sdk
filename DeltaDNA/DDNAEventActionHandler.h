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
#import "DDNAImageMessage.h"

@class DDNAActionStore;
@class DDNAEventTrigger;

/**
 Protocol for defining handlers which can be registered with `DDNAEventAction`.
 */
@protocol DDNAEventActionHandler <NSObject>

@required
- (BOOL)handleEventTrigger:(DDNAEventTrigger *)eventTrigger store:(DDNAActionStore *)store;
- (NSString *)type;

@end

/**
 A handler for campaigns that return game parameters.
 */
@interface DDNAGameParametersHandler: NSObject<DDNAEventActionHandler>

- (instancetype)initWithHandler:(void(^)(NSDictionary *))handler;
- (BOOL)handleEventTrigger:(DDNAEventTrigger *)eventTrigger store:(DDNAActionStore *)store;
- (NSString *)type;

@end

/**
 A handler for campaigns that return image messages.
 */
@interface DDNAImageMessageHandler : NSObject<DDNAEventActionHandler>

- (instancetype)initWithHandler:(void(^)(DDNAImageMessage *))handler;
- (BOOL)handleEventTrigger:(DDNAEventTrigger *)eventTrigger store:(DDNAActionStore *)store;
- (NSString *)type;

@end
