//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNAEventTrigger.h"
#import "NSDictionary+DeltaDNA.h"

BOOL cond(NSDictionary *parameters, NSArray *condition) {
    DDNAEventTrigger *t = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"condition": condition }];
    return [t respondsToEventSchema:@{@"eventParams": parameters}];
}

SpecBegin(DDNAEventTriggerTest)

describe(@"event trigger", ^{
    
    it(@"builds itself from a json dictionary", ^{
        
        DDNAEventTrigger *t = [[DDNAEventTrigger alloc] initWithDictionary:@{
            @"eventName": @"testEvent",
            @"response": @{
                @"parameters": @{ @"a": @1 }
            },
            @"campaignID": @1,
            @"variantID": @2,
            @"priority": @3,
            @"limit": @4
        }];
        
        expect(t.eventName).to.equal(@"testEvent");
        expect(t.actionType).to.equal(@"gameParameters");
        expect(t.response).to.equal(@{@"parameters": @{ @"a": @1 }});
        expect(t.campaignId).to.equal(1);
        expect(t.variantId).to.equal(2);
        expect(t.priority).to.equal(3);
        expect(t.limit).to.equal(4);
    });
    
    it(@"uses sensible defaults", ^{
        
        DDNAEventTrigger *t = [[DDNAEventTrigger alloc] initWithDictionary:@{}];
        
        expect(t.eventName).to.beNil();
        expect(t.actionType).to.equal(@"gameParameters");
        expect(t.response).to.equal(@{});
        expect(t.campaignId).to.equal(0);
        expect(t.variantId).to.equal(0);
        expect(t.priority).to.equal(0);
        expect(t.limit).to.beNil();
    });
    
    it(@"orders triggers by priority", ^{
        
        // Bigger numbers have higher priority
        
        DDNAEventTrigger *t1 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"priority": @1 }];
        DDNAEventTrigger *t2 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"priority": @2 }];
        DDNAEventTrigger *t3 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"priority": @3 }];
        
        NSArray<DDNAEventTrigger *> *triggers = @[t1, t2, t3];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
        NSArray<DDNAEventTrigger *> *sorted = [triggers sortedArrayUsingDescriptors:@[sort]];
        
        expect(sorted).to.equal(@[t3, t2, t1]);
    });
    
    it(@"fails if event name doesn't match", ^{
        
        DDNAEventTrigger *t1 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"eventName": @"testEvent" }];
        
        expect([t1 respondsToEventSchema:@{ @"eventName": @"anotherEvent" }]).to.beFalsy();
        
    });
    
    it(@"respects the trigger limit", ^{
        
        DDNAEventTrigger *t1 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"limit": @2 }];
        
        expect([t1 respondsToEventSchema:@{}]).to.beTruthy();
        expect([t1 respondsToEventSchema:@{}]).to.beTruthy();
        expect([t1 respondsToEventSchema:@{}]).to.beFalsy();
    });
    
    it(@"handles triggers with empty conditions", ^{
        // TODO: does this fire or not?
        
        DDNAEventTrigger *t1 = [[DDNAEventTrigger alloc] initWithDictionary:@{ @"eventName": @"testEvent" }];
        
        expect([t1 respondsToEventSchema:@{ @"eventName": @"testEvent" }]).to.beTruthy();
    });
    
    it(@"evaluates logical operators", ^{
        
        expect(cond(@{}, @[@{@"b":@YES}, @{@"b":@YES}, @{@"o":@"and"}])).to.beTruthy();
        expect(cond(@{}, @[@{@"b":@YES}, @{@"b":@NO}, @{@"o":@"and"}])).to.beFalsy();
        
        expect(cond(@{@"a": @YES}, @[@{@"p":@"a"}, @{@"b":@YES}, @{@"o":@"and"}])).to.beTruthy();
        expect(cond(@{@"a": @YES}, @[@{@"p":@"a"}, @{@"b":@NO}, @{@"o":@"and"}])).to.beFalsy();
        
        expect(cond(@{}, @[@{@"b":@NO}, @{@"b":@YES}, @{@"o":@"or"}])).to.beTruthy();
        expect(cond(@{}, @[@{@"b":@NO}, @{@"b":@NO}, @{@"o":@"or"}])).to.beFalsy();
        
        expect(cond(@{@"a": @NO}, @[@{@"p":@"a"}, @{@"b":@YES}, @{@"o":@"or"}])).to.beTruthy();
        expect(cond(@{@"a": @NO}, @[@{@"p":@"a"}, @{@"b":@NO}, @{@"o":@"or"}])).to.beFalsy();
    });
    
    it(@"evaluates operators against incompatible types", ^{
        
        expect(cond(@{@"a":@1}, @[@{@"p":@"a"}, @{@"i":@1}, @{@"o":@"and"}])).to.beFalsy();
        expect(cond(@{@"a":@1.0}, @[@{@"p":@"a"}, @{@"f":@1.0}, @{@"o":@"and"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"and"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"}, @{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"and"}])).to.beFalsy();
        
        expect(cond(@{@"a":@1}, @[@{@"p":@"a"}, @{@"i":@1}, @{@"o":@"or"}])).to.beFalsy();
        expect(cond(@{@"a":@1.0}, @[@{@"p":@"a"}, @{@"f":@1.0}, @{@"o":@"or"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"or"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"}, @{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"or"}])).to.beFalsy();
    });
    
    it(@"evaluates equality operators", ^{
        
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@NO}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"},@{@"s":@"b"}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"},@{@"s":@"c"}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@NO}, @{@"o":@"not equal to"}])).to.beTruthy();
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"not equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"not equal to"}])).to.beTruthy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"not equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"not equal to"}])).to.beTruthy();
        
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"},@{@"s":@"b"}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"},@{@"s":@"c"}, @{@"o":@"not equal to"}])).to.beTruthy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"not equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"not equal to"}])).to.beTruthy();
    });
    
    it(@"evaluates comparison operators", ^{
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"greater than"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"greater than"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"greater than"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"greater than"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"greater than"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"greater than"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"greater than"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"greater than"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"greater than"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"greater than eq"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"greater than eq"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"greater than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"greater than eq"}])).to.beFalsy();
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"less than"}])).to.beTruthy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"less than"}])).to.beTruthy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"less than"}])).to.beTruthy();
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@4}, @{@"o":@"less than eq"}])).to.beFalsy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@5}, @{@"o":@"less than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5}, @[@{@"p":@"a"},@{@"i":@6}, @{@"o":@"less than eq"}])).to.beTruthy();
        
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@4.0}, @{@"o":@"less than eq"}])).to.beFalsy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@5.0}, @{@"o":@"less than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@5.0}, @[@{@"p":@"a"},@{@"f":@6.0}, @{@"o":@"less than eq"}])).to.beTruthy();
        
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-05-13T00:00:00.000Z"}, @{@"o":@"less than eq"}])).to.beFalsy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-06-13T00:00:00.000Z"}, @{@"o":@"less than eq"}])).to.beTruthy();
        expect(cond(@{@"a":@"2018-06-13T00:00:00.000Z"}, @[@{@"p":@"a"},@{@"t":@"2018-07-13T00:00:00.000Z"}, @{@"o":@"less than eq"}])).to.beTruthy();
    });
    
    it(@"evaluates comparison operators against incompatible types", ^{
        
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"greater than"}])).to.beFalsy();
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"greater than eq"}])).to.beFalsy();
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@YES}, @[@{@"p":@"a"},@{@"b":@YES}, @{@"o":@"less than eq"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"greater than"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"greater than eq"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"less than"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"less than eq"}])).to.beFalsy();
    });
    
    it(@"evaluates string comparison operators", ^{
       
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"equal to"}])).to.beTruthy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"B"}, @{@"o":@"equal to"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"b"}, @{@"o":@"not equal to"}])).to.beFalsy();
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"s":@"B"}, @{@"o":@"not equal to"}])).to.beTruthy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"O w"}, @{@"o":@"contains"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"o W"}, @{@"o":@"contains"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"O w"}, @{@"o":@"contains ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"o W"}, @{@"o":@"contains ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"oW"}, @{@"o":@"contains ic"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"HeLlO"}, @{@"o":@"starts with"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"Hello"}, @{@"o":@"starts with"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"HeLlO"}, @{@"o":@"starts with ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"hElLo"}, @{@"o":@"starts with ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"wOrLd"}, @{@"o":@"starts with ic"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"wOrLd"}, @{@"o":@"ends with"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"WoRlD"}, @{@"o":@"ends with"}])).to.beFalsy();
        
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"wOrLd"}, @{@"o":@"ends with ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"WoRlD"}, @{@"o":@"ends with ic"}])).to.beTruthy();
        expect(cond(@{@"a":@"HeLlO wOrLd"}, @[@{@"p":@"a"}, @{@"s":@"HeLlO"}, @{@"o":@"ends with ic"}])).to.beFalsy();
    });
    
    it(@"evaluates complex expressions", ^{
        
        expect(cond(@{@"a":@10,@"b":@5,@"c":@"c",@"d":@YES}, @[@{@"p":@"c"},@{@"s":@"p"},@{@"o":@"equal to"},@{@"p":@"a"},@{@"i":@15},@{@"o":@"less than"},@{@"o":@"and"},@{@"p":@"b"},@{@"i":@15},@{@"o":@"greater than eq"},@{@"o":@"and"},@{@"p":@"d"},@{@"b":@YES},@{@"o":@"equal to"},@{@"o":@"or"}])).beTruthy();
    });
    
    it(@"fails on missing parameter", ^{
        
        expect(cond(@{@"a":@5}, @[@{@"p":@"b"}, @{@"i":@5}, @{@"o":@"equal to"}])).beFalsy();
    });
    
    xit(@"fails on mismatched parameter types", ^{
        
        // This doesn't work in objc because it will happily convert 'b' to 0 and then carry on.
        expect(cond(@{@"a":@"b"}, @[@{@"p":@"a"}, @{@"i":@5}, @{@"o":@"not equal to"}])).beFalsy();
    });
    
});

SpecEnd
