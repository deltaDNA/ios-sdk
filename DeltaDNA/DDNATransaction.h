//
//  DDNATransaction.h
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "DDNAEvent.h"
#import "DDNAProduct.h"

@interface DDNATransaction : DDNAEvent

+ (instancetype)transactionWithName:(NSString *)name
                               type:(NSString *)type
                   productsReceived:(DDNAProduct *)productsReceived
                      productsSpent:(DDNAProduct *)productsSpent;

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
            productsReceived:(DDNAProduct *)productsReceived
               productsSpent:(DDNAProduct *)productsSpent;

- (void)setTransactionId:(NSString *)transactionId;
- (void)setReceipt:(NSString *)receipt;
- (void)setServer:(NSString *)server;
- (void)setTransactorId:(NSString *)transactorId;
- (void)setProductId:(NSString *)productId;

@end
