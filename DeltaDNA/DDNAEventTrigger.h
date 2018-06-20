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

@class DDNAEvent;

@interface DDNAEventTrigger : NSObject

@property (nonatomic, copy, readonly) NSString *eventName;
@property (nonatomic, copy, readonly) NSString *actionType;
@property (nonatomic, strong, readonly) NSDictionary *response;
@property (nonatomic, assign, readonly) NSUInteger campaignId;
@property (nonatomic, assign, readonly) NSUInteger variantId;
@property (nonatomic, assign, readonly) NSInteger priority;
@property (nonatomic, strong, readonly) NSNumber *limit;
@property (nonatomic, assign, readonly) NSUInteger count;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)respondsToEventSchema:(NSDictionary *)eventSchema;

@end

