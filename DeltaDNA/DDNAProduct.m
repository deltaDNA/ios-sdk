//
//  DDNAProduct.m
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
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
