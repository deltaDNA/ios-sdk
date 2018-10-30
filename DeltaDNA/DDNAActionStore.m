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
#import "DDNAEventTrigger.h"
#import "DDNALog.h"
#import "DDNAUtils.h"

static NSString *const kStoreName = @"ActionStore.plist";

@interface DDNAActionStore ()

@property (nonatomic, strong) NSMutableDictionary *store;
@property (nonatomic, copy) NSString *location;

+ (NSString *)keyForTrigger:(DDNAEventTrigger *)trigger;

@end

@implementation DDNAActionStore

- (instancetype)initWithPath:(NSString *)path
{
    if ((self = [super init])) {
        self.location = [path stringByAppendingPathComponent:kStoreName];
        self.store = [NSMutableDictionary dictionaryWithContentsOfFile:self.location];
        if (!self.store) {
            self.store = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)setParameters:(NSDictionary *)parameters forTrigger:(DDNAEventTrigger *)trigger
{
    @try {
        if (parameters != nil) {
            [self.store setObject:parameters forKey:[DDNAActionStore keyForTrigger:trigger]];
            [self.store writeToFile:self.location atomically:YES];
        }
    }
    @catch (NSException *exception) {
        DDNALogDebug(@"Error saving to action store: %@", exception.reason);
    }
}

- (NSDictionary *)parametersForTrigger:(DDNAEventTrigger *)trigger
{
    return [self.store objectForKey:[DDNAActionStore keyForTrigger:trigger]];
}

- (void)removeForTrigger:(DDNAEventTrigger *)trigger
{
    [self.store removeObjectForKey:[DDNAActionStore keyForTrigger:trigger]];
    [self.store writeToFile:self.location atomically:YES];
}

- (void)clear
{
    [self.store removeAllObjects];
    [self.store writeToFile:self.location atomically:YES];
}

+ (NSString *)keyForTrigger:(DDNAEventTrigger *)trigger
{
    return [NSString stringWithFormat:@"%ld",[trigger campaignId]];
}

@end
