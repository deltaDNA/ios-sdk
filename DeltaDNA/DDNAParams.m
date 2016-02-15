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

#import "DDNAParams.h"

@interface DDNAParams ()

@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation DDNAParams

+ (instancetype)params
{
    return [[DDNAParams alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.params = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setParam:(NSObject *)param forKey:(NSString *)key
{
    @try {
        if ([param isKindOfClass:[DDNAParams class]]) {
            [self.params setObject:[((DDNAParams *)param) dictionary] forKey:key];
        } else if ([param isKindOfClass:[NSDate class]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [self.params setObject:[dateFormatter stringFromDate:((NSDate *)param)] forKey:key];
        } else {
            [self.params setObject:param forKey:key];
        }
    }
    @catch (NSException *e) {
        @throw;
    }
}

- (NSObject *)paramForKey:(NSString *)key
{
    return [self.params objectForKey:key];
}

- (NSDictionary *)dictionary
{
    return self.params;
}

@end
