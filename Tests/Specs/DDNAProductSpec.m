//
//  DDNAProductSpec.m
//  DeltaDNA
//
//  Created by David White on 12/02/2016.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "NSString+DeltaDNA.h"
#import "DDNAProduct.h"

SpecBegin(DDNAProduct)

describe(@"product", ^{
    
    __block DDNAProduct *product;
    
    beforeEach(^{
        product = [DDNAProduct product];
    });
    
    it(@"add items", ^{
        [product addItemName:@"grow" type:@"potion" amount:2];
        [product addItemName:@"shrink" type:@"potion" amount:1];
        
        NSDictionary *result = @{
            @"items": @[
                @{
                    @"item": @{
                        @"itemName": @"grow",
                        @"itemType": @"potion",
                        @"itemAmount": @2
                    },
                },
                @{
                    @"item": @{
                        @"itemName": @"shrink",
                        @"itemType": @"potion",
                        @"itemAmount": @1
                    }
                }
            ]
        };
        expect(product.dictionary).to.equal(result);
    });
    
    it(@"add virtual currencies", ^{
        [product addVirtualCurrencyName:@"VIP Points" type:@"GRIND" amount:50];
        [product addVirtualCurrencyName:@"Gold Coins" type:@"In-Game" amount:100];
        
        NSDictionary *result = @{
            @"virtualCurrencies": @[
                @{
                    @"virtualCurrency": @{
                        @"virtualCurrencyName": @"VIP Points",
                        @"virtualCurrencyType": @"GRIND",
                        @"virtualCurrencyAmount": @50
                    }
                },
                @{
                    @"virtualCurrency": @{
                        @"virtualCurrencyName": @"Gold Coins",
                        @"virtualCurrencyType": @"In-Game",
                        @"virtualCurrencyAmount": @100
                    }
                }
            ]
        };
        expect(product.dictionary).to.equal(result);
    });
    
    it(@"set a real currency", ^{
        [product setRealCurrencyType:@"USD" amount:15];
        
        NSDictionary *result = @{
            @"realCurrency": @{
                @"realCurrencyType": @"USD",
                @"realCurrencyAmount": @15
            }
        };
        expect(product.dictionary).to.equal(result);
    });
    
    it(@"throws if nil or empty", ^{
        
        expect(^{
            [DDNAProduct product];
            [product addItemName:nil type:@"potion" amount:2];
        }).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addItemName:@"" type:@"potion" amount:2];
        }).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addItemName:@"grow" type:nil amount:2];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addItemName:@"grow" type:@"" amount:2];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addVirtualCurrencyName:nil type:@"GRIND" amount:50];
        }).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addVirtualCurrencyName:@"" type:@"GRIND" amount:50];
        }).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addVirtualCurrencyName:@"VIP Points" type:nil amount:50];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product addVirtualCurrencyName:@"VIP Points" type:@"" amount:50];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product setRealCurrencyType:nil amount:15];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{
            [DDNAProduct product];
            [product setRealCurrencyType:@"" amount:15];
        }).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
    });
    
});

SpecEnd