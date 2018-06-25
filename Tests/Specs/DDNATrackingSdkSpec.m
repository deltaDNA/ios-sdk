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

#import "DDNATrackingSdk.h"
#import "DDNAInstanceFactory.h"
#import "DDNACollectService.h"
#import "DDNAEngageService.h"
#import "DDNAImageCache.h"
#import "DDNASDK.h"
#import "DDNAUserManager.h"
#import "DDNASettings.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNAEvent.h"
#import "DDNAEngagement.h"

SpecBegin(DDNATrackingSdkTest)

describe(@"tracking sdk", ^{
    
    __block DDNAInstanceFactory *mockInstanceFactory;
    __block DDNACollectService *mockCollectService;
    __block DDNAEngageService *mockEngageService;
    __block DDNASDK *mockSdk;
    __block DDNAUserManager *mockUserManager;
    __block DDNASettings *mockSettings;
    __block DDNATrackingSdk *trackingSdk;
    __block id<DDNANetworkRequestDelegate> mockDelegate;
    
    beforeEach(^{
        mockSdk = mock([DDNASDK class]);
        mockCollectService = mock([DDNACollectService class]);
        mockEngageService = mock([DDNAEngageService class]);
        mockInstanceFactory = mock([DDNAInstanceFactory class]);
        mockUserManager = mock([DDNAUserManager class]);
        mockSettings = mock([DDNASettings class]);
        [given([mockInstanceFactory buildCollectService]) willReturn:mockCollectService];
        [given([mockInstanceFactory buildEngageService]) willReturn:mockEngageService];
        [given([mockSdk settings]) willReturn:mockSettings];
        [given([mockSdk platform]) willReturn:@"test console"];
        [given([mockSdk userID]) willReturn:@"user123"];
        [given([mockSdk sessionID]) willReturn:@"session123"];
        [given([mockSdk engageURL]) willReturn:@"/engage"];
        [given([mockSettings httpRequestCollectTimeoutSeconds]) willReturnInt:5];
        [given([mockSettings httpRequestMaxTries]) willReturnInt:2];
        [given([mockSettings httpRequestRetryDelaySeconds]) willReturnInt:30];
        trackingSdk = [[DDNATrackingSdk alloc] initWithSdk:mockSdk instanceFactory:mockInstanceFactory];
        mockDelegate = mockProtocol(@protocol(DDNASDKDelegate));
    });
    
    afterEach(^{
        if (trackingSdk.hasStarted) {
            [trackingSdk stop];
        }
    });
    
    it(@"sends default sdk events", ^{

        [given([mockUserManager isNewPlayer]) willReturnBool:YES];
        [given([mockSettings onFirstRunSendNewPlayerEvent]) willReturnBool:YES];
        [given([mockSettings onStartSendGameStartedEvent]) willReturnBool:YES];
        [given([mockSettings onStartSendClientDeviceEvent]) willReturnBool:YES];

        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk upload];

        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockCollectService) request:(id)argument handler:anything()];
        DDNACollectRequest *collectRequest = argument.value;
        expect(collectRequest).toNot.beNil();
        expect(collectRequest.eventCount).to.equal(3);

        NSDictionary *json = [NSDictionary dictionaryWithJSONString:collectRequest.toJSON];
        expect(json[@"eventList"][0][@"eventName"]).to.equal(@"newPlayer");
        expect(json[@"eventList"][1][@"eventName"]).to.equal(@"gameStarted");
        expect(json[@"eventList"][2][@"eventName"]).to.equal(@"clientDevice");
    });

    it(@"can disable default sdk events", ^{

        [given([mockUserManager isNewPlayer]) willReturnBool:YES];
        [given([mockSettings onFirstRunSendNewPlayerEvent]) willReturnBool:NO];
        [given([mockSettings onStartSendGameStartedEvent]) willReturnBool:NO];
        [given([mockSettings onStartSendClientDeviceEvent]) willReturnBool:NO];

        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk upload];

        [verifyCount(mockCollectService, never()) request:anything() handler:anything()];
    });
    
    it(@"sends stop event", ^{
       
        [given([mockUserManager isNewPlayer]) willReturnBool:YES];
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk stop];

        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockCollectService) request:(id)argument handler:anything()];
        DDNACollectRequest *collectRequest = argument.value;
        expect(collectRequest).toNot.beNil();
        expect(collectRequest.eventCount).to.equal(1);

        NSDictionary *json = [NSDictionary dictionaryWithJSONString:collectRequest.toJSON];
        expect(json[@"eventList"][0][@"eventName"]).to.equal(@"gameEnded");
    });
    
    it(@"calls sdk started on its delegate", ^{

        [given([mockSdk delegate]) willReturn:mockDelegate];
        [trackingSdk startWithNewPlayer:mockUserManager];
        [verify(mockDelegate) didStartSdk];
    });

    it(@"does not call start on its delegate if not set", ^{

        [trackingSdk startWithNewPlayer:mockUserManager];
        [verifyCount(mockDelegate, never()) didStartSdk];
    });

    it(@"calls sdk stopped on its delegate", ^{

        [given([mockSdk delegate]) willReturn:mockDelegate];
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk stop];
        [verify(mockDelegate) didStopSdk];
        
    });
    
    it(@"does not call stop on its delegate if not set", ^{
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk stop];
        [verifyCount(mockDelegate, never()) didStopSdk];
    });

    it(@"requests session configuration", ^{

        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockEngageService) request:(id)argument handler:anything()];
        DDNAEngageRequest *engageRequest = argument.value;
        expect(engageRequest).toNot.beNil();
        expect(engageRequest.decisionPoint).to.equal(@"config");
        expect(engageRequest.flavour).to.equal(@"internal");
        expect(engageRequest.parameters).toNot.beNil();
        NSDictionary *parameters = engageRequest.parameters;
        expect(parameters[@"timeSinceFirstSession"]).toNot.beNil();
        expect(parameters[@"timeSinceLastSession"]).toNot.beNil();
    });
    
    it(@"calls session configured on its delegate", ^{
        [given([mockSdk delegate]) willReturn:mockDelegate];
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"isCachedResponse\":false,\"parameters\":{}}", 200, nil);
            return nil;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        [verifyCount(mockDelegate, never()) didFailToConfigureSessionWithError:anything()];
        [verify(mockDelegate) didConfigureSessionWithCache:NO];
    });
    
    it(@"calls session configured on its delegate with cached response", ^{
        [given([mockSdk delegate]) willReturn:mockDelegate];
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"isCachedResponse\":true,\"parameters\":{}}", 200, nil);
            return nil;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        [verifyCount(mockDelegate, never()) didFailToConfigureSessionWithError:anything()];
        [verify(mockDelegate) didConfigureSessionWithCache:YES];
    });
    
    it(@"calls session failed to configure when an error occurs", ^{
        NSError *mockError = mock([NSError class]);
        [given([mockSdk delegate]) willReturn:mockDelegate];
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(nil, 500, mockError);
            return nil;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        [verifyCount(mockDelegate, times(1)) didFailToConfigureSessionWithError:mockError];
        [verifyCount(mockDelegate, never()) didConfigureSessionWithCache:anything()];
    });
    
    it(@"reads event whitelist from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"eventsWhitelist\":[\"event1\",\"event2\"]}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.eventWhitelist).to.beNil();  // Send all events before configuration completes.
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.eventWhitelist).toNot.beNil();
        expect(trackingSdk.eventWhitelist).to.contain(@"event1");
        expect(trackingSdk.eventWhitelist).to.contain(@"event2");
    });
    
    it(@"handles missing event whitelist from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.eventWhitelist).to.beNil();  // Send all events before configuration completes.
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.eventWhitelist).to.beNil();
    });
    
    it(@"reads decision point whitelist from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"dpWhitelist\":[\"dp1\",\"dp2\"]}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.decisionPointWhitelist).to.beNil();  // Respond to all decision points before configuration completes.
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.decisionPointWhitelist).toNot.beNil();
        expect(trackingSdk.decisionPointWhitelist).to.contain(@"dp1");
        expect(trackingSdk.decisionPointWhitelist).to.contain(@"dp2");
    });
    
    it(@"reads event triggers from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"triggers\":[{\"campaignID\": 28440,\"condition\": [{\"p\": \"userScore\"},{\"i\": 5},{\"o\": \"greater than\"}],\"eventName\":\"achievement\",\"priority\": 0,\"response\": {\"parameters\": {},\"transactionID\":2473687550473027584},\"variantID\": 36625},{\"campaignID\": 28441,\"condition\": [{\"p\": \"userScore\"},{\"i\": 5},{\"o\": \"less than\"}],\"eventName\":\"transaction\",\"priority\": 0,\"response\": {\"parameters\": {},\"transactionID\":2473687550473027584},\"variantID\": 36625}]}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.eventTriggers.count).to.equal(0);
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.eventTriggers.count).to.equal(2);
    });
    
    it(@"handles missing decision point whitelist from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.decisionPointWhitelist).to.beNil();  // Respond to all decision points before configuration completes.
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.decisionPointWhitelist).to.beNil();
    });
    
    it(@"reads image cache from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"imageCache\":[\"/image1.png\",\"/image2.png\"]}}", 200, nil);
            return nil;
        }];
        
        expect(trackingSdk.imageCacheList).toNot.beNil();
        expect(trackingSdk.imageCacheList.count).to.equal(0);
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.imageCacheList.count).to.equal(2);
        expect(trackingSdk.imageCacheList).to.contain(@"/image1.png");
        expect(trackingSdk.imageCacheList).to.contain(@"/image2.png");
    });
    
    it(@"handles missing image cache list from session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{}}", 200, nil);
            return nil;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        expect(trackingSdk.imageCacheList).toNot.beNil();
        expect(trackingSdk.imageCacheList.count).to.equal(0);
    });
    
    it(@"populates image cache after session configuration", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"imageCache\":[\"/image1.png\",\"/image2.png\"]}}", 200, nil);
            return nil;
        }];
        
        // annoyingly the image cache must be a singleton to support the old image message class,
        // this is required to mock it out
        __strong Class mockImageCacheClass = mockClass([DDNAImageCache class]);
        DDNAImageCache *mockImageCache = mock([DDNAImageCache class]);
        stubSingleton(mockImageCacheClass, sharedInstance);
        [given([DDNAImageCache sharedInstance]) willReturn:mockImageCache];
        [givenVoid([mockImageCache prefechImagesForURLs:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            NSArray *urls = [invocation mkt_arguments][0];
            void (^completionHandler)(NSInteger downloaded, NSError *error) = [invocation mkt_arguments][1];
            completionHandler(urls.count, nil);
            return nil;
        }];
        
        [given([mockSdk delegate]) willReturn:mockDelegate];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        [verifyCount(mockDelegate, never()) didFailToPopulateImageMessageCacheWithError:anything()];
        [verifyCount(mockDelegate, times(1)) didPopulateImageMessageCache];
        
    });
    
    it(@"reports if image cache fails to populate", ^{
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"imageCache\":[\"/image1.png\",\"/image2.png\"]}}", 200, nil);
            return nil;
        }];
        
        __strong Class mockImageCacheClass = mockClass([DDNAImageCache class]);
        DDNAImageCache *mockImageCache = mock([DDNAImageCache class]);
        stubSingleton(mockImageCacheClass, sharedInstance);
        [given([DDNAImageCache sharedInstance]) willReturn:mockImageCache];
        [givenVoid([mockImageCache prefechImagesForURLs:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(NSInteger downloaded, NSError *error) = [invocation mkt_arguments][1];
            completionHandler(0, mock([NSError class]));
            return nil;
        }];
        
        [given([mockSdk delegate]) willReturn:mockDelegate];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        [verifyCount(mockDelegate, times(1)) didFailToPopulateImageMessageCacheWithError:anything()];
        [verifyCount(mockDelegate, never()) didPopulateImageMessageCache];
        
    });
    
    it(@"sends started notification", ^{
        
        __block BOOL receivedStartedEvent = NO;
        __block NSNotification *receivedNote = nil;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"DDNASDKStarted" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            receivedStartedEvent = YES;
            receivedNote = note;;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        
        expect(receivedStartedEvent).will.beTruthy();
        expect(receivedNote.object).will.equal(mockSdk);
        expect(trackingSdk.taskQueueSuspended).to.beFalsy();
    });
    
    it(@"only sends whitelisted events", ^{

        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"eventsWhitelist\":[\"allowedEvent\"]}}", 200, nil);
            return nil;
        }];
        
        [given([mockUserManager isNewPlayer]) willReturnBool:NO];
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];

        DDNAEvent *allowedEvent = [DDNAEvent eventWithName:@"allowedEvent"];
        DDNAEvent *disallowedEvent = [DDNAEvent eventWithName:@"disallowedEvent"];

        [trackingSdk recordEvent:allowedEvent];
        [trackingSdk recordEvent:disallowedEvent];
        [trackingSdk upload];

        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockCollectService, times(1)) request:(id)argument handler:anything()];
        DDNACollectRequest *collectRequest = argument.value;
        expect(collectRequest).toNot.beNil();
        expect(collectRequest.eventCount).to.equal(1);

    });
    
    it(@"sends all events when no whitelist", ^{
        
        [given([mockUserManager isNewPlayer]) willReturnBool:NO];
        [trackingSdk startWithNewPlayer:mockUserManager];
        
        DDNAEvent *allowedEvent = [DDNAEvent eventWithName:@"allowedEvent"];
        DDNAEvent *disallowedEvent = [DDNAEvent eventWithName:@"disallowedEvent"];
        
        [trackingSdk recordEvent:allowedEvent];
        [trackingSdk recordEvent:disallowedEvent];
        [trackingSdk upload];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockCollectService, times(1)) request:(id)argument handler:anything()];
        DDNACollectRequest *collectRequest = argument.value;
        expect(collectRequest).toNot.beNil();
        expect(collectRequest.eventCount).to.equal(2);
        
    });
    
    it(@"only requests whitelisted decision points", ^{
        
        [givenVoid([mockEngageService request:anything() handler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^handler)(NSString *response, NSInteger statusCode, NSError *error) = [invocation mkt_arguments][1];
            handler(@"{\"parameters\":{\"dpWhitelist\":[\"allowedDp@engagement\"]}}", 200, nil);
            return nil;
        }];
        
        [trackingSdk startWithNewPlayer:mockUserManager];
        [trackingSdk requestSessionConfiguration:mockUserManager];
        
        DDNAEngagement *allowedEngagement = [DDNAEngagement engagementWithDecisionPoint:@"allowedDp"];
        DDNAEngagement *disallowedEngagement = [DDNAEngagement engagementWithDecisionPoint:@"disallowedDp"];
        
        [trackingSdk requestEngagement:allowedEngagement completionHandler:nil];
        [trackingSdk requestEngagement:disallowedEngagement completionHandler:nil];
        
        [verifyCount(mockEngageService, times(2)) request:anything() handler:anything()];
    });
    
    it(@"sends all decision points when no whitelist", ^{
    
        [trackingSdk startWithNewPlayer:mockUserManager];
        
        DDNAEngagement *allowedEngagement = [DDNAEngagement engagementWithDecisionPoint:@"allowedDp"];
        DDNAEngagement *disallowedEngagement = [DDNAEngagement engagementWithDecisionPoint:@"disallowedDp"];
        
        [trackingSdk requestEngagement:allowedEngagement completionHandler:nil];
        [trackingSdk requestEngagement:disallowedEngagement completionHandler:nil];
        
        [verifyCount(mockEngageService, times(2)) request:anything() handler:anything()];
        
    });
});

SpecEnd
