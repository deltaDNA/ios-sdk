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

#import <Foundation/Foundation.h>
#import "DDNAParams.h"

@interface DDNAProduct : DDNAParams

+ (instancetype)product;

- (void)setRealCurrencyType:(NSString *)type amount:(NSInteger)amount;

- (void)addVirtualCurrencyName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount;

- (void)addItemName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount;

/**
 Converts a currency in a decimal number format with a decimal point,
 such as '1.23' EUR, into an integer representation which can be used
 with setRealCurrency. This method will also work for currencies which
 don't use a minor currency unit, for example such as the Japanese Yen (JPY).
 
 @param code The ISO 4217 currency code.
 @param value The currency value to convert.
 
 @return The converted integer value.
 */
+ (NSInteger)convertCurrencyCode:(NSString *)code value:(NSDecimalNumber *)value;

@end
