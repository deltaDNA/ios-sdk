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

#import "NSDictionary+DeltaDNA.h"
#import "NSString+DeltaDNA.h"

@implementation NSDictionary (DeltaDNA)

+ (NSDictionary *) dictionaryWithJSONString: (NSString *) jsonString
{    
    if ([NSString stringIsNilOrEmpty:jsonString])
    {
        return [NSDictionary dictionary];
    }
    
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:&error];
    if (error != 0)
    {
        return [NSDictionary dictionary];
    }
    
    return result;
}

@end