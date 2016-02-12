//
//  DDNAProduct.h
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "DDNAParams.h"

@interface DDNAProduct : DDNAParams

+ (instancetype)product;

- (void)setRealCurrencyType:(NSString *)type amount:(NSInteger)amount;

- (void)addVirtualCurrencyName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount;

- (void)addItemName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount;

@end
