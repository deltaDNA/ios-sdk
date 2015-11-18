//
//  NSURL+DeltaDNASpec.m
//  DeltaDNA
//
//  Created by David White on 15/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNA/NSURL+DeltaDNA.h>


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
