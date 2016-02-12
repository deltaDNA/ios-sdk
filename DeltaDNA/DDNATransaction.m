//
//  DDNATransaction.m
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
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
