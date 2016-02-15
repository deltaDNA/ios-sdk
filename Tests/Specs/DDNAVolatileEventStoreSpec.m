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

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNAVolatileEventStore.h"


SpecBegin(DDNAVolatileEventStore)

describe(@"volatile event store", ^{
    
    __block DDNAVolatileEventStore *store;
    
    beforeEach(^{
       
        store = [[DDNAVolatileEventStore alloc] initWithSizeBytes:64];
        
    });
    
    it(@"creates an event store of requested size", ^{
        
        expect(store).toNot.beNil();
        expect(store.isOutEmpty).to.beTruthy();
        
    });
    
    it(@"accepts events up to the maximum size", ^{
        
        NSDictionary *event = @{
            @"name": @"Jan",
            @"age": @6
        };
        
        expect([store pushEvent:event]).to.beTruthy();
        expect([store pushEvent:event]).to.beTruthy();
        expect([store pushEvent:event]).to.beFalsy();
        
    });
    
    it(@"handles empty events", ^{
        
        NSMutableDictionary *event = [NSMutableDictionary dictionary];
        
        expect([store pushEvent:event]).to.beFalsy();
    });
    
    it(@"handles corrupt events", ^{
        
        NSMutableDictionary *event = [NSMutableDictionary dictionary];
        
        id danger = [NSObject alloc];
        [event setObject:danger forKey:@"danger"];

        expect([store pushEvent:event]).to.beFalsy();
        
    });
    
    it(@"reads events", ^{
        
        NSDictionary *event1 = @{
            @"name": @"Jan",
            @"age": @6
        };
        
        NSDictionary *event2 = @{
            @"name": @"Ben",
            @"age": @14
        };
        
        NSDictionary *event3 = @{
            @"name": @"Jen",
            @"age": @10
        };
        
        NSDictionary *event4 = @{
            @"name": @"Lou",
            @"age": @8
        };
        
        NSDictionary *event5 = @{
            @"name": @"Sam",
            @"age": @12
        };
        
        expect([store pushEvent:event1]).to.beTruthy();
        expect([store pushEvent:event2]).to.beTruthy();
        expect([store pushEvent:event3]).to.beFalsy();
        expect(store.isOutEmpty).to.beTruthy();
        expect([store swapBuffers]).to.beTruthy();
        expect(store.isOutEmpty).to.beFalsy();
        expect([store pushEvent:event3]).to.beTruthy();
        expect([store pushEvent:event4]).to.beTruthy();
        expect([store pushEvent:event5]).to.beFalsy();
        
        NSArray *events = [store readOut];
        expect(events).toNot.beNil();
        expect(events.count).to.equal(2);
        expect(events[0]).to.equal(@"{\"name\":\"Jan\",\"age\":6}");
        expect(events[1]).to.equal(@"{\"name\":\"Ben\",\"age\":14}");
        expect([store swapBuffers]).to.beFalsy();
        
        [store clearOut];
        expect(store.isOutEmpty).to.beTruthy();
        expect([store swapBuffers]).to.beTruthy();
        expect(store.isOutEmpty).to.beFalsy();
        expect([store pushEvent:event5]).to.beTruthy();
        
        events = [store readOut];
        expect(events).toNot.beNil();
        expect(events.count).to.equal(2);
        expect(events[0]).to.equal(@"{\"name\":\"Jen\",\"age\":10}");
        expect(events[1]).to.equal(@"{\"name\":\"Lou\",\"age\":8}");
        expect([store swapBuffers]).to.beFalsy();
        
        [store clearOut];
        expect(store.isOutEmpty).to.beTruthy();
        expect([store swapBuffers]).to.beTruthy();
        expect(store.isOutEmpty).to.beFalsy();
        
        events = [store readOut];
        expect(events).toNot.beNil();
        expect(events.count).to.equal(1);
        expect(events[0]).to.equal(@"{\"name\":\"Sam\",\"age\":12}");
        
        [store clearOut];
        expect(store.isOutEmpty).to.beTruthy();
        expect([store swapBuffers]).to.beTruthy();
        expect(store.isOutEmpty).to.beTruthy();
    });
    
    it(@"clears event store", ^{
        
        NSDictionary *event = @{
            @"name": @"Jan",
            @"age": @6
        };
        
        expect([store isInEmpty]).to.beTruthy();
        expect([store isOutEmpty]).to.beTruthy();
        expect([store pushEvent:event]).to.beTruthy();
        expect([store isInEmpty]).to.beFalsy();
        expect([store isOutEmpty]).to.beTruthy();
        expect([store swapBuffers]).to.beTruthy();
        expect([store isInEmpty]).to.beTruthy();
        expect([store isOutEmpty]).to.beFalsy();
        expect([store pushEvent:event]).to.beTruthy();
        expect([store isInEmpty]).to.beFalsy();
        expect([store isOutEmpty]).to.beFalsy();
        [store clearAll];
        expect([store isInEmpty]).to.beTruthy();
        expect([store isOutEmpty]).to.beTruthy();
    });
});

SpecEnd
