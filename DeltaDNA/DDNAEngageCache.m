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

#import "DDNAEngageCache.h"
#import "DDNALog.h"
#import "DDNAUtils.h"

static NSString *const kCacheName = @"EngageCache.plist";
static NSTimeInterval const kDefaultExpiryTime = 12 * 60 * 60;  // 12 hours

@interface DDNAEngageCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, copy) NSString *cacheLocation;
@property (nonatomic, assign) NSTimeInterval expiryTimeInterval;

@end

@implementation DDNAEngageCache

- (instancetype)initWithPath:(NSString *)path expiryTimeInterval:(NSTimeInterval)expiryTimeInterval
{
    if ((self = [super init])) {
        
        self.cacheLocation = [[DDNAUtils getCacheDir] stringByAppendingPathComponent:path];
        self.expiryTimeInterval = expiryTimeInterval;
        self.cache = [NSMutableDictionary dictionaryWithContentsOfFile:self.cacheLocation];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.cacheLocation]) {
            self.cache = [NSMutableDictionary dictionaryWithContentsOfFile:self.cacheLocation];
        }
        if (!self.cache) {
            self.cache = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)setObject:(NSObject *)object forKey:(NSString *)key
{
    @try {
        if (object != nil) {
            [self.cache setObject:@{@"object": object, @"modified":[NSDate date]} forKey:key];
            [self.cache writeToFile:self.cacheLocation atomically:YES];
        }
    }
    @catch (NSException *exception) {
        DDNALogDebug(@"Error saving to cache: %@", exception.reason);
    }
}

- (id)objectForKey:(NSString *)key
{
    NSDictionary *found = [self.cache objectForKey:key];
    if (found && [[NSDate date] timeIntervalSinceDate:found[@"modified"]] < self.expiryTimeInterval) {
        return found[@"object"];
    }
    return nil;
}

- (void)clear
{
    [self.cache removeAllObjects];
    [self.cache writeToFile:self.cacheLocation atomically:YES];
}

@end
