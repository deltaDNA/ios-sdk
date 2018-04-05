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

#import "DDNAEngageFactory.h"
#import "DDNASDK.h"
#import "DDNAEngagement.h"
#import "DDNAImageMessage.h"

SpecBegin(DDNAEngageFactory)

describe(@"engage factory", ^{
    
    __block DDNASDK *mockSdk;
    __block DDNAEngageFactory *engageFactory;
    __block DDNAEngagement *fakeEngagement;
    
    beforeEach(^{
        mockSdk = mock([DDNASDK class]);
        engageFactory = [[DDNAEngageFactory alloc] initWithDDNASDK:mockSdk];
        
        [givenVoid([mockSdk requestEngagement:anything() engagementHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^engagementHandler)(DDNAEngagement *engagement) = [invocation mkt_arguments][1];
            engagementHandler(fakeEngagement);
            return nil;
        }];
    });

    it(@"requests game parameters", ^{
        
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = @{@"parameters":@{ @"key1": @5, @"key2": @7 }};
        
        [engageFactory requestGameParametersForDecisionPoint:@"testDecisionPoint" handler:^(NSDictionary * gameParameters) {
            expect(gameParameters).toNot.beNil();
            expect(gameParameters).to.haveACountOf(2);
            expect([gameParameters isEqualToDictionary:fakeEngagement.json[@"parameters"]]);
        }];
        
    });
    
    it(@"returns empty game parameters with invalid engagement", ^{
        
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = nil;
        
        [engageFactory requestGameParametersForDecisionPoint:@"testDecisionPoint" handler:^(NSDictionary * gameParameters) {
            expect(gameParameters).toNot.beNil();
            expect(gameParameters).to.haveACountOf(0);
            expect([gameParameters isEqualToDictionary:@{}]);
        }];
    });
    
    it(@"requests an image message", ^{
        
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        [engageFactory requestImageMessageForDecisionPoint:@"testDecisionPoint" handler:^(DDNAImageMessage * _Nullable imageMessage) {
            expect(imageMessage).toNot.beNil();
            expect(imageMessage.parameters).toNot.beNil();
            expect(imageMessage.parameters).to.haveACountOf(1);
            expect([imageMessage.parameters isEqualToDictionary:@{@"rewardName":@"wrench"}]);
        }];
    });
    
    it(@"requests an image message", ^{
        
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = nil;
        
        [engageFactory requestImageMessageForDecisionPoint:@"testDecisionPoint" handler:^(DDNAImageMessage * _Nullable imageMessage) {
            expect(imageMessage).to.beNil();
        }];
    });
});

SpecEnd
