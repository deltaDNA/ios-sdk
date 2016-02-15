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

#import "DDNATransaction.h"

void validateParam(NSString *param, NSString *name)
{
    if (param == nil || param.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ cannot be nil", name] userInfo:nil]);
    }
}

@interface DDNATransaction ()

@end

@implementation DDNATransaction

+ (instancetype)transactionWithName:(NSString *)name type:(NSString *)type productsReceived:(DDNAProduct *)productsReceived productsSpent:(DDNAProduct *)productsSpent
{
    return [[DDNATransaction alloc] initWithName:name type:type productsReceived:productsReceived productsSpent:productsSpent];
}

- (instancetype)initWithName:(NSString *)name type:(NSString *)type productsReceived:(DDNAProduct *)productsReceived productsSpent:(DDNAProduct *)productsSpent
{
    if (name == nil || name.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"name cannot be nil or empty" userInfo:nil]);
    }
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    if (productsReceived == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"productsReceived cannot be nil" userInfo:nil]);
    }
    if (productsSpent == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"productsSpent cannot be nil" userInfo:nil]);
    }
    
    if ((self = [super initWithName:@"transaction"])) {
        [self setParam:name forKey:@"transactionName"];
        [self setParam:type forKey:@"transactionType"];
        [self setParam:productsReceived forKey:@"productsReceived"];
        [self setParam:productsSpent forKey:@"productsSpent"];
    }
    return self;
}

- (void)setTransactionId:(NSString *)transactionId
{
    validateParam(transactionId, @"transactionID");
    [self setParam:transactionId forKey:@"transactionID"];
}

- (void)setReceipt:(NSString *)receipt
{
    validateParam(receipt, @"transactionReceipt");
    [self setParam:receipt forKey:@"transactionReceipt"];
}

- (void)setServer:(NSString *)server
{
    validateParam(server, @"transactionServer");
    [self setParam:server forKey:@"transactionServer"];
}

- (void)setTransactorId:(NSString *)transactorId
{
    validateParam(transactorId, @"transactorID");
    [self setParam:transactorId forKey:@"transactorID"];
}

- (void)setProductId:(NSString *)productId
{
    validateParam(productId, @"productID");
    [self setParam:productId forKey:@"productID"];
}

@end
