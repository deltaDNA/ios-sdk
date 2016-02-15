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

#import "NSURL+DeltaDNA.h"


SpecBegin(NSURL_DeltaDNA)

describe(@"NSURL+DeltaDNA", ^{
   
    it(@"creates simple http url", ^{
       
        NSURL *url = [NSURL URLWithEngageEndpoint:@"http://engage1999abcd.deltadna.net" environmentKey:@"5582251763508113932"];
        
        NSURL *expectedURL = [NSURL URLWithString:@"http://engage1999abcd.deltadna.net/5582251763508113932"];
        
        expect(url).to.equal(expectedURL);
    });
    
    it(@"creates hashed http url", ^{
        
        NSURL *url = [NSURL URLWithEngageEndpoint:@"http://engage1999abcd.deltadna.net"
                                   environmentKey:@"5582251763508113932"
                                          payload:@"{'foo': 'bar'}"
                                       hashSecret:@"12345abcde"];
        
        NSURL *expectedURL = [NSURL URLWithString:@"http://engage1999abcd.deltadna.net/5582251763508113932/hash/6172f13895b22d30359c6d6172a31d3a"];
        
        expect(url).to.equal(expectedURL);
        
    });
    
    it(@"creates simple https url", ^{
        
        NSURL *url = [NSURL URLWithEngageEndpoint:@"https://engage1999abcd.deltadna.net" environmentKey:@"5582251763508113932"];
        
        NSURL *expectedURL = [NSURL URLWithString:@"https://engage1999abcd.deltadna.net/5582251763508113932"];
        
        expect(url).to.equal(expectedURL);
        
    });
    
    it(@"creates hashed https url", ^{
        
        NSURL *url = [NSURL URLWithEngageEndpoint:@"https://engage1999abcd.deltadna.net"
                                   environmentKey:@"5582251763508113932"
                                          payload:@"{'foo': 'bar'}"
                                       hashSecret:@"12345abcde"];
        
        NSURL *expectedURL = [NSURL URLWithString:@"https://engage1999abcd.deltadna.net/5582251763508113932/hash/6172f13895b22d30359c6d6172a31d3a"];
        
        expect(url).to.equal(expectedURL);
        
    });
    
});

SpecEnd
