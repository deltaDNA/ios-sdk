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
    
    it(@"doesn't throw if setParam is nil", ^{
        
        expect(^{
            DDNAEvent *event = [DDNAEvent eventWithName:@"myEvent"];
            [event setParam:nil forKey:@"nilKey"];
        }).to.raise(@"NSInvalidArgumentException");
        
    });
    
});

SpecEnd