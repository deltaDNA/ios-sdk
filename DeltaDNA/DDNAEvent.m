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

#import "DDNAEvent.h"
#import "DDNAParams.h"
#import "DDNAProduct.h"

@interface DDNAEvent ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, strong) DDNAParams *eventParams;

@end

@implementation DDNAEvent

+ (instancetype)eventWithName:(NSString *)name
{
    return [[DDNAEvent alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init])) {
        self.eventName = name;
        self.eventParams = [DDNAParams params];
    }
    return self;
}

- (void)setParam:(NSObject *)param forKey:(NSString *)key
{
    [self.eventParams setParam:param forKey:key];
}

- (NSDictionary *)dictionary
{
    return @{
        @"eventName": self.eventName,
        @"eventParams": [NSDictionary dictionaryWithDictionary:[self.eventParams dictionary]]
    };
}

@end
