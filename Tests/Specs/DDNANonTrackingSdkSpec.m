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

#import "DDNANonTrackingSdk.h"
#import "DDNAInstanceFactory.h"
#import "DDNACollectService.h"
#import "DDNASDK.h"
#import "DDNAUserManager.h"
#import "DDNASettings.h"
#import "NSDictionary+DeltaDNA.h"

SpecBegin(DDNANonTrackingSdkTest)

describe(@"not tracking sdk", ^{
    
    __block DDNAInstanceFactory *mockInstanceFactory;
    __block DDNACollectService *mockCollectService;
    __block DDNASDK *mockSdk;
    __block DDNAUserManager *mockUserManager;
    __block DDNASettings *mockSettings;
    __block DDNANonTrackingSdk *nonTrackingSdk;
    
    beforeEach(^{
        mockSdk = mock([DDNASDK class]);
        mockCollectService = mock([DDNACollectService class]);
        mockInstanceFactory = mock([DDNAInstanceFactory class]);
        mockUserManager = mock([DDNAUserManager class]);
        mockSettings = mock([DDNASettings class]);
        [given([mockInstanceFactory buildCollectService]) willReturn:mockCollectService];
        [given([mockSdk settings]) willReturn:mockSettings];
        nonTrackingSdk = [[DDNANonTrackingSdk alloc] initWithSdk:mockSdk instanceFactory:mockInstanceFactory];
    });
    
    it(@"sends the ddnaForgetMe event", ^{
        
        [given([mockUserManager doNotTrack]) willReturnBool:YES];
        [given([mockUserManager forgotten]) willReturnBool:NO];
        [given([mockSdk platform]) willReturn:@"test console"];
        [given([mockSdk userID]) willReturn:@"user123"];
        [given([mockSdk sessionID]) willReturn:@"session123"];
        [given([mockSettings httpRequestCollectTimeoutSeconds]) willReturnInt:5];
        [given([mockSettings httpRequestMaxTries]) willReturnInt:2];
        [given([mockSettings httpRequestRetryDelaySeconds]) willReturnInt:30];
        
        [nonTrackingSdk startWithNewPlayer:mockUserManager];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockCollectService) request:(id)argument handler:anything()];
        DDNACollectRequest *collectRequest = argument.value;
        expect(collectRequest).toNot.beNil();
        expect(collectRequest.eventCount).to.equal(1);
        expect(collectRequest.timeoutSeconds).to.equal(5);
        expect(collectRequest.retries).to.equal(2);
        expect(collectRequest.retryDelaySeconds).to.equal(30);

        NSDictionary *json = [NSDictionary dictionaryWithJSONString:collectRequest.toJSON];
        NSDictionary *eventJson = json[@"eventList"][0];
        expect(eventJson[@"eventUUID"]).toNot.beNil();
        expect(eventJson[@"eventTimestamp"]).toNot.beNil();
        expect(eventJson[@"userID"]).to.equal(@"user123");
        expect(eventJson[@"sessionID"]).to.equal(@"session123");
        expect(eventJson[@"eventName"]).to.equal(@"ddnaForgetMe");
        NSDictionary *eventParams = eventJson[@"eventParams"];
        expect(eventParams[@"platform"]).to.equal(@"test console");
        expect(eventParams[@"sdkVersion"]).to.equal(DDNA_SDK_VERSION);
    });
});

SpecEnd
