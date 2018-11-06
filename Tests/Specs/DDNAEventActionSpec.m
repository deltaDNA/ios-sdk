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

#import "DDNAEventAction.h"
#import "DDNAEvent.h"
#import "DDNAEventTrigger.h"
#import "DDNAEventActionHandler.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNASdkInterface.h"


SpecBegin(DDNAEventActionTest)

describe(@"event action", ^{
    
    xit(@"tries triggers in order", ^{
        
        DDNAEvent *e = mock([DDNAEvent class]);
        DDNAEventTrigger *t1 = mock([DDNAEventTrigger class]);
        [given([t1 priority]) willReturnInt:5];
        DDNAEventTrigger *t2 = mock([DDNAEventTrigger class]);
        [given([t2 priority]) willReturnInt:3];
        DDNAEventTrigger *t3 = mock([DDNAEventTrigger class]);
        [given([t3 priority]) willReturnInt:1];
        NSOrderedSet *triggers = [NSOrderedSet orderedSetWithArray:@[t1, t2, t3]];
        id<DDNASdkInterface> mockSdk = mockProtocol(@protocol(DDNASdkInterface));
        
        DDNAEventAction *a = [[DDNAEventAction alloc] initWithEventSchema:e.dictionary eventTriggers:triggers sdk:mockSdk];
        [a run];
        
        // Ah, can't verify the order mocks were called in.
        // https://github.com/jonreid/OCMockito/issues/18
    });
    
    it(@"handlers are run until one handles the action", ^{
        
        DDNAEvent *e = mock([DDNAEvent class]);
        DDNAEventTrigger *t = mock([DDNAEventTrigger class]);
        NSOrderedSet *triggers = [NSOrderedSet orderedSetWithArray:@[t]];
        id<DDNASdkInterface> mockSdk = mockProtocol(@protocol(DDNASdkInterface));
        id<DDNAEventActionHandler> h1 = mockProtocol(@protocol(DDNAEventActionHandler));
        id<DDNAEventActionHandler> h2 = mockProtocol(@protocol(DDNAEventActionHandler));
        id<DDNAEventActionHandler> h3 = mockProtocol(@protocol(DDNAEventActionHandler));
        
        [given([t respondsToEventSchema:anything()]) willReturnBool:YES];
        [given([h1 handleEventTrigger:t]) willReturnBool:NO];
        [given([h2 handleEventTrigger:t]) willReturnBool:YES];
        
        DDNAEventAction *a = [[DDNAEventAction alloc] initWithEventSchema:e.dictionary eventTriggers:triggers sdk:mockSdk];
        [a addHandler:h1];
        [a addHandler:h2];
        [a addHandler:h3];
        [a run];
        
        [verifyCount(h1, times(1)) handleEventTrigger:t];
        [verifyCount(h2, times(1)) handleEventTrigger:t];
        [verifyCount(h3, never()) handleEventTrigger:t];
    });
    
    it(@"does nothing with an empty action", ^{
        
        DDNAEventTrigger *t = mock([DDNAEventTrigger class]);
        id<DDNAEventActionHandler> h1 = mockProtocol(@protocol(DDNAEventActionHandler));
        
        [given([t respondsToEventSchema:anything()]) willReturnBool:YES];
        [given([h1 handleEventTrigger:t]) willReturnBool:YES];
        
        DDNAEventAction *a = [[DDNAEventAction alloc] init];
        [a addHandler:h1];
        [a run];
        
        [verifyCount(h1, never()) handleEventTrigger:t];
    });
    
    it(@"posts actionTriggered event", ^{
        
        DDNAEvent *e = mock([DDNAEvent class]);
        DDNAEventTrigger *t = mock([DDNAEventTrigger class]);
        NSOrderedSet *triggers = [NSOrderedSet orderedSetWithArray:@[t]];
        id<DDNASdkInterface> mockSdk = mockProtocol(@protocol(DDNASdkInterface));
        
        [given([t respondsToEventSchema:anything()]) willReturnBool:YES];
        [given([t campaignId]) willReturnInt:1];
        [given([t priority]) willReturnInt:2];
        [given([t variantId]) willReturnInt:3];
        [given([t campaignName]) willReturn:@"campaignName"];
        [given([t variantName]) willReturn:@"variantName"];
        [given([t actionType]) willReturn:@"gameParameters"];
        [given([t count]) willReturnInt:4];
        
        DDNAEventAction *a = [[DDNAEventAction alloc] initWithEventSchema:e.dictionary eventTriggers:triggers sdk:mockSdk];
        [a run];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockSdk) recordEvent:(id)argument];
        DDNAEvent *capturedEvent = argument.value;
        NSDictionary *schema = capturedEvent.dictionary;
        expect(schema[@"eventName"]).to.equal(@"ddnaEventTriggeredAction");
        NSDictionary *eventParams = schema[@"eventParams"];
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredCampaignID");
        expect(eventParams[@"ddnaEventTriggeredCampaignID"]).to.equal(@1);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredCampaignPriority");
        expect(eventParams[@"ddnaEventTriggeredCampaignPriority"]).to.equal(@2);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredVariantID");
        expect(eventParams[@"ddnaEventTriggeredVariantID"]).to.equal(@3);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredCampaignName");
        expect(eventParams[@"ddnaEventTriggeredCampaignName"]).to.equal(@"campaignName");
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredVariantName");
        expect(eventParams[@"ddnaEventTriggeredVariantName"]).to.equal(@"variantName");
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredActionType");
        expect(eventParams[@"ddnaEventTriggeredActionType"]).to.equal(@"gameParameters");
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredSessionCount");
        expect(eventParams[@"ddnaEventTriggeredSessionCount"]).to.equal(@4);
    });
    
    it(@"posts actionTriggered event missing optional fields", ^{
        DDNAEvent *e = mock([DDNAEvent class]);
        DDNAEventTrigger *t = mock([DDNAEventTrigger class]);
        NSOrderedSet *triggers = [NSOrderedSet orderedSetWithArray:@[t]];
        id<DDNASdkInterface> mockSdk = mockProtocol(@protocol(DDNASdkInterface));
        
        [given([t respondsToEventSchema:anything()]) willReturnBool:YES];
        [given([t campaignId]) willReturnInt:1];
        [given([t priority]) willReturnInt:2];
        [given([t variantId]) willReturnInt:3];
        [given([t actionType]) willReturn:@"gameParameters"];
        [given([t count]) willReturnInt:4];
        
        DDNAEventAction *a = [[DDNAEventAction alloc] initWithEventSchema:e.dictionary eventTriggers:triggers sdk:mockSdk];
        [a run];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockSdk) recordEvent:(id)argument];
        DDNAEvent *capturedEvent = argument.value;
        NSDictionary *schema = capturedEvent.dictionary;
        expect(schema[@"eventName"]).to.equal(@"ddnaEventTriggeredAction");
        NSDictionary *eventParams = schema[@"eventParams"];
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredCampaignID");
        expect(eventParams[@"ddnaEventTriggeredCampaignID"]).to.equal(@1);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredCampaignPriority");
        expect(eventParams[@"ddnaEventTriggeredCampaignPriority"]).to.equal(@2);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredVariantID");
        expect(eventParams[@"ddnaEventTriggeredVariantID"]).to.equal(@3);
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredActionType");
        expect(eventParams[@"ddnaEventTriggeredActionType"]).to.equal(@"gameParameters");
        expect(eventParams.allKeys).to.contain(@"ddnaEventTriggeredSessionCount");
        expect(eventParams[@"ddnaEventTriggeredSessionCount"]).to.equal(@4);
        
        expect(eventParams.allKeys).notTo.contain(@"ddnaEventTriggeredCampaignName");
        expect(eventParams.allKeys).notTo.contain(@"ddnaEventTriggeredVariantName");
    });
});

SpecEnd
