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

#import "NSURL+DeltaDNA.h"
#import "NSString+DeltaDNA.h"

@implementation NSURL (DeltaDNA)

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey
{
    return [NSURL URLWithEngageEndpoint:endpoint environmentKey:environmentKey payload:@"" hashSecret:nil];
}

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey payload:(NSString *)payload hashSecret:(NSString *)hashSecret
{
    NSString *hashComponent = @"";
    
    if (hashSecret != nil && hashSecret.length > 0) {
        hashComponent = [NSString stringWithFormat:@"/hash/%@", [[payload stringByAppendingString:hashSecret] md5]];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@%@", endpoint, environmentKey, hashComponent];
    
    return [NSURL URLWithString:url];
}

@end
