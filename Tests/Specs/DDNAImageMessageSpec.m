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

#import "DDNAImageMessage.h"
#import "DDNAEngagement.h"

SpecBegin(DDNAImageMessage)

describe(@"image message", ^{
    
    __block id<DDNAImageMessageDelegate> mockDelegate;
    
    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNAImageMessageDelegate));
    });

    it(@"returns nil if engagement is nil", ^{
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:nil delegate:mockDelegate];
        expect(imageMessage).to.beNil();
    });
    
    it(@"returns nil if engagement is invalid", ^{
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
    });
    
    it(@"returns nil if image key is missing", ^{
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{\n\t\"transactionID\": 2184799313132298240,\n\t\"trace\": {\n\t\t\"initialState\": {\n\t\t\t\"serverNow\": 1460107947856000,\n\t\t\t\"userCreated\": 1459296000000000,\n\t\t\t\"roeLimited\": false\n\t\t},\n\t\t\"engagements\": [{\n\t\t\t\"engagementID\": 4451,\n\t\t\t\"behaviour\": 0,\n\t\t\t\"silent\": false,\n\t\t\t\"enabled\": true,\n\t\t\t\"parameterCriteria\": [],\n\t\t\t\"metricCriteria\": [],\n\t\t\t\"existingVariant\": 8800,\n\t\t\t\"existingState\": null,\n\t\t\t\"existingStateTimestamp\": null,\n\t\t\t\"existingConverted\": 0,\n\t\t\t\"parameters\": {\n\t\t\t\t\"adShowSession\": true\n\t\t\t}\n\t\t}]\n\t},\n\t\"parameters\": {\n\t\t\"adShowSession\": true,\n\t\t\"adProviders\": [{\n\t\t\t\"adProvider\": \"ADMOB\",\n\t\t\t\"eCPM\": 294,\n\t\t\t\"adUnitId\": \"ca-app-pub-4857093250239318/9840016386\"\n\t\t}],\n\t\t\"adRewardedProviders\": [{\n\t\t\t\"adProvider\": \"UNITY\",\n\t\t\t\"eCPM\": 1060,\n\t\t\t\"gameId\": \"106546\",\n\t\t\t\"testMode\": false\n\t\t}, {\n\t\t\t\"adProvider\": \"ADCOLONY\",\n\t\t\t\"eCPM\": 1323,\n\t\t\t\"appId\": \"appdd80fa453e784901bc\",\n\t\t\t\"clientOptions\": \"version:1.0,store:google\",\n\t\t\t\"zoneId\": \"vzc9a5567db2d447d29a\"\n\t\t}, {\n\t\t\t\"adProvider\": \"CHARTBOOST\",\n\t\t\t\"eCPM\": 38,\n\t\t\t\"appId\": \"56e3e633da15274fc8aa6cbf\",\n\t\t\t\"appSignature\": \"a7f6e1592a33abbcc0ac1e311d0ea1f614fefe7c\",\n\t\t\t\"location\": \"Default\"\n\t\t}, {\n\t\t\t\"adProvider\": \"VUNGLE\",\n\t\t\t\"eCPM\": 4,\n\t\t\t\"appId\": \"961178606\"\n\t\t}],\n\t\t\"adFloorPrice\": 1,\n\t\t\"adMinimumInterval\": 200,\n\t\t\"adMaxPerSession\": 20,\n\t\t\"adMaxPerNetwork\": 1,\n\t\t\"adDemoteOnRequestCode\": 1\n\t}\n}";
        
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
    });
    
    it(@"returns nil if image json is invalid", ^{
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
        
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
        
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
        
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
        
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}}},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).to.beNil();
    });
    
    it(@"is created with valid engagement using parameters", ^{
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}";
        
        expect(engagement.json).toNot.beNil();
        expect(engagement.json.allKeys).to.contain(@"image");
        expect(engagement.json.allKeys).to.contain(@"parameters");
        
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).toNot.beNil();
        expect(imageMessage.isReady).to.beFalsy();
        expect(imageMessage.isShowing).to.beFalsy();
        expect(imageMessage.parameters).toNot.beNil();
        expect([imageMessage.parameters isEqualToDictionary:@{@"rewardName":@"wrench"}]).to.beTruthy();
        
    });
    
    it(@"is created with valid engagement without parameters", ^{
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{}}";
        
        expect(engagement.json).toNot.beNil();
        expect(engagement.json.allKeys).to.contain(@"image");
        expect(engagement.json.allKeys).to.contain(@"parameters");
        
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:engagement delegate:mockDelegate];
        expect(imageMessage).toNot.beNil();
        expect(imageMessage.isReady).to.beFalsy();
        expect(imageMessage.isShowing).to.beFalsy();
        expect(imageMessage.parameters).toNot.beNil();
        expect([imageMessage.parameters isEqualToDictionary:@{}]).to.beTruthy();
        
    });
    
});

SpecEnd