//
//  DDNAEventSpec.m
//  DeltaDNA
//
//  Created by David White on 12/02/2016.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "NSString+DeltaDNA.h"
#import "DDNAEvent.h"

SpecBegin(DDNAEvent)

describe(@"event", ^{
    
    it(@"create without parameters", ^{
       
        DDNAEvent *event = [DDNAEvent eventWithName:@"myEvent"];
        
        NSDictionary *result = @{
            @"eventName": @"myEvent",
            @"eventParams": @{}
        };
        
        expect(event.dictionary).to.equal(result);
        
    });
    
    it(@"create with parameters", ^{
        
        DDNAEvent *event = [DDNAEvent eventWithName:@"myEvent"];
        [event setParam:@5 forKey:@"level"];
        [event setParam:@"Kaboom!" forKey:@"ending"];
        
        NSDictionary *result = @{
            @"eventName": @"myEvent",
            @"eventParams": @{
                @"level": @5,
                @"ending": @"Kaboom!"
            }
        };
        
        expect(event.dictionary).to.equal(result);
    });
    
    it(@"create with nested parameters", ^{
        
        DDNAEvent *event = [DDNAEvent eventWithName:@"myEvent"];
        [event setParam:@{@"level2": @{@"yo!": @"greeting"}} forKey:@"level1"];
        
        NSDictionary *result = @{
            @"eventName": @"myEvent",
            @"eventParams": @{
                @"level1": @{
                    @"level2": @{
                        @"yo!": @"greeting"
                    }
                }
            }
        };
        
        expect(event.dictionary).to.equal(result);
        
    });
    
    it(@"throws if setParam is nil", ^{
        
    });
    
});

SpecEnd