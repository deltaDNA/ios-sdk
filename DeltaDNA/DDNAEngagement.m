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

#import "DDNAEngagement.h"
#import "DDNAParams.h"

@interface DDNAEngagement ()

@property (nonatomic, copy) NSString *decisionPoint;
@property (nonatomic, copy) NSString *flavour;
@property (nonatomic, strong) DDNAParams *engageParams;

@end

@implementation DDNAEngagement

+ (instancetype)engagementWithDecisionPoint:(NSString *)decisionPoint
{
    return [[DDNAEngagement alloc] initWithDecisionPoint:decisionPoint];
}

- (instancetype)initWithDecisionPoint:(NSString *)decisionPoint
{
    if ((self = [super init])) {
        if (decisionPoint == nil || decisionPoint.length == 0) {
            @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"decisionPoint cannot be nil or empty" userInfo:nil]);
        }
        self.decisionPoint = decisionPoint;
        self.flavour = @"engagement";
        self.engageParams = [DDNAParams params];
    }
    return self;
}

- (void)setParam:(NSObject *)param forKey:(NSString *)key
{
    [self.engageParams setParam:param forKey:key];
}

- (NSDictionary *)dictionary
{
    return @{
        @"decisionPoint": self.decisionPoint,
        @"flavour": self.flavour,
        @"parameters": [NSDictionary dictionaryWithDictionary:[self.engageParams dictionary]]
    };
}


@end
