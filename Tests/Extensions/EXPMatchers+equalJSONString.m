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

#import "EXPMatchers+equalJSONString.h"
#import "NSDictionary+DeltaDNA.h"

EXPMatcherImplementationBegin(equalJSONString, (NSString *other)) {
    BOOL actualIsNil = actual == nil;
    
    prerequisite(^BOOL {
        return !actualIsNil;
    });
    
    match(^BOOL {
        
        NSDictionary *actualDict = [NSDictionary dictionaryWithJSONString:actual];
        NSDictionary *otherDict = [NSDictionary dictionaryWithJSONString:other];
        
        return [actualDict isEqualToDictionary:otherDict];
    });
    
    failureMessageForTo(^NSString * {
        if (actualIsNil) {
            return @"the actual value in nil/null";
        }
        return [NSString stringWithFormat:@"expected: %@ to be equal to %@", actual, other];
    });
    
    failureMessageForNotTo(^NSString * {
        if (actualIsNil) {
            return @"the actual value in nil/null";
        }
        return [NSString stringWithFormat:@"expected: %@ to not equal %@", actual, other];
    });
}
EXPMatcherImplementationEnd
