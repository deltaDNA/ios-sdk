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

#import "DDNAProduct.h"

@interface DDNAProduct ()

@property (nonatomic, weak) NSMutableArray *virtualCurrencies;
@property (nonatomic, weak) NSMutableArray *items;

@end

@implementation DDNAProduct

+ (instancetype)product
{
    return [[DDNAProduct alloc] init];
}

- (void)setRealCurrencyType:(NSString *)type amount:(NSInteger)amount
{
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    [self setParam:@{@"realCurrencyType":type, @"realCurrencyAmount":[NSNumber numberWithInteger:amount]} forKey:@"realCurrency"];
}

- (void)addVirtualCurrencyName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount
{
    if (name == nil || name.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"name cannot be nil or empty" userInfo:nil]);
    }
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    
    NSDictionary *virtualCurrency = @{
        @"virtualCurrency": @{
            @"virtualCurrencyName": name,
            @"virtualCurrencyType": type,
            @"virtualCurrencyAmount": [NSNumber numberWithInteger:amount]
        }
    };
    
    if (![self paramForKey:@"virtualCurrencies"]) {
        self.virtualCurrencies = [NSMutableArray arrayWithObject:virtualCurrency];
        [self setParam:self.virtualCurrencies forKey:@"virtualCurrencies"];
    } else {
        [self.virtualCurrencies addObject:virtualCurrency];
    }
}

- (void)addItemName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount
{
    if (name == nil || name.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"name cannot be nil or empty" userInfo:nil]);
    }
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    
    NSDictionary *item = @{
        @"item": @{
            @"itemName": name,
            @"itemType": type,
            @"itemAmount": [NSNumber numberWithInteger:amount]
        }
    };
    
    if (![self paramForKey:@"items"]) {
        self.items = [NSMutableArray arrayWithObject:item];
        [self setParam:self.items forKey:@"items"];
    } else {
        [self.items addObject:item];
    }
}

@end
