//
//  DDNADecisionPointSpec.m
//  DeltaDNA
//
//  Created by David White on 14/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNA/DeltaDNA.h>


SpecBegin(DDNADecisionPoint)

describe(@"decision point", ^{
    
    it(@"creates engagement flavour by default", ^{
        
        DDNADecisionPoint *decisionPoint = [[DDNADecisionPoint alloc] initWithName:@"testName"];
        
        expect(decisionPoint.name).to.equal(@"testName");
        expect(decisionPoint.flavour).to.equal(DDNADecisionPointFlavourEngagement);
        
    });
    
    it(@"creates correct flavour", ^{
       
        DDNADecisionPoint *decisionPoint = [[DDNADecisionPoint alloc] initWithName:@"testName" andFlavour:DDNADecisionPointFlavourEngagement];
        
        expect(decisionPoint.name).to.equal(@"testName");
        expect(decisionPoint.flavour).to.equal(DDNADecisionPointFlavourEngagement);
        
        decisionPoint = [[DDNADecisionPoint alloc] initWithName:@"testName2" andFlavour:DDNADecisionPointFlavourAdvertising];
        
        expect(decisionPoint.name).to.equal(@"testName2");
        expect(decisionPoint.flavour).to.equal(DDNADecisionPointFlavourAdvertising);
        
        decisionPoint = [[DDNADecisionPoint alloc] initWithName:@"testName3" andFlavour:DDNADecisionPointFlavourInternal];
        
        expect(decisionPoint.name).to.equal(@"testName3");
        expect(decisionPoint.flavour).to.equal(DDNADecisionPointFlavourInternal);
        
    });
    
});

SpecEnd