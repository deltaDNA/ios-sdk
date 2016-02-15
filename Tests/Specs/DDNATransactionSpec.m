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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "DDNATransaction.h"

SpecBegin(DDNATransaction)

describe(@"transaction", ^{
    
    it(@"create basic", ^{
        
        DDNAProduct *productsReceived = [DDNAProduct product];
        DDNAProduct *productsSpent = [DDNAProduct product];
        
        DDNATransaction *transaction = [DDNATransaction transactionWithName:@"shop" type:@"weapon" productsReceived:productsReceived productsSpent:productsSpent];
        
        NSDictionary *result = @{
            @"eventName": @"transaction",
            @"eventParams": @{
                @"transactionName": @"shop",
                @"transactionType": @"weapon",
                @"productsReceived": @{},
                @"productsSpent": @{}
            }
        };
        
        expect(transaction.dictionary).to.equal(result);
    });
    
    it(@"create optional", ^{
        
        DDNAProduct *productsReceived = [DDNAProduct product];
        DDNAProduct *productsSpent = [DDNAProduct product];
        
        DDNATransaction *transaction = [DDNATransaction transactionWithName:@"shop" type:@"weapon" productsReceived:productsReceived productsSpent:productsSpent];
        [transaction setTransactionId:@"12345"];
        [transaction setServer:@"local"];
        [transaction setReceipt:@"123223----***5433"];
        [transaction setTransactorId:@"abcde"];
        [transaction setProductId:@"5678-4332"];
        
        NSDictionary *result = @{
            @"eventName": @"transaction",
            @"eventParams": @{
                @"transactionName": @"shop",
                @"transactionType": @"weapon",
                @"productsReceived": @{},
                @"productsSpent": @{},
                @"transactionID": @"12345",
                @"transactionServer": @"local",
                @"transactionReceipt": @"123223----***5433",
                @"transactorID": @"abcde",
                @"productID": @"5678-4332"
            }
        };
        
        expect(transaction.dictionary).to.equal(result);
        
    });
    
    it (@"throws if nil or empty", ^{
        
        DDNAProduct *productsReceived = [DDNAProduct product];
        DDNAProduct *productsSpent = [DDNAProduct product];
        
        expect(^{[DDNATransaction transactionWithName:nil type:@"weapon" productsReceived:productsReceived productsSpent:productsSpent];}).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{[DDNATransaction transactionWithName:@"" type:@"weapon" productsReceived:productsReceived productsSpent:productsSpent];}).to.raiseWithReason(NSInvalidArgumentException, @"name cannot be nil or empty");
        
        expect(^{[DDNATransaction transactionWithName:@"shop" type:nil productsReceived:productsReceived productsSpent:productsSpent];}).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{[DDNATransaction transactionWithName:@"shop" type:@"" productsReceived:productsReceived productsSpent:productsSpent];}).to.raiseWithReason(NSInvalidArgumentException, @"type cannot be nil or empty");
        
        expect(^{[DDNATransaction transactionWithName:@"shop" type:@"weapon" productsReceived:nil productsSpent:productsSpent];}).to.raiseWithReason(NSInvalidArgumentException, @"productsReceived cannot be nil");
        
        expect(^{[DDNATransaction transactionWithName:@"shop" type:@"weapon" productsReceived:productsReceived productsSpent:nil];}).to.raiseWithReason(NSInvalidArgumentException, @"productsSpent cannot be nil");
    });
    
});

SpecEnd