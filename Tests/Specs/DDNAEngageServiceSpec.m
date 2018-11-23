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

#import "DDNAEngageService.h"
#import "DDNAFakeInstanceFactory.h"
#import "DDNAFakeNetworkRequest.h"
#import "DDNAEngageCache.h"
#import "../../DeltaDNA/NSString+DeltaDNA.h"


SpecBegin(DDNAEngageService)

describe(@"engage request", ^{
    
    it(@"builds engage request with default flavour", ^{
        DDNAEngageRequest *request = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint" userId:@"user-id-12345" sessionId:@"session-id-12345"];
        
        expect(request.decisionPoint).to.equal(@"testDecisionPoint");
        expect(request.flavour).to.equal(@"engagement");
        expect(request.parameters).to.beNil();
        expect(request.userId).to.equal(@"user-id-12345");
        expect(request.sessionId).to.equal(@"session-id-12345");
    });
    
    it(@"builds engage request with custom flavour", ^{
        DDNAEngageRequest *request = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint" userId:@"user-id-12345" sessionId:@"session-id-12345"];
        
        request.flavour = @"advertising";
        request.parameters = @{@"hello":@"goodbye"};
        
        expect(request.decisionPoint).to.equal(@"testDecisionPoint");
        expect(request.flavour).to.equal(@"advertising");
        expect(request.parameters).to.equal(@{@"hello":@"goodbye"});
        expect(request.userId).to.equal(@"user-id-12345");
        expect(request.sessionId).to.equal(@"session-id-12345");

    });
    
});

describe(@"engage service", ^{
    
    __block DDNAEngageService *engageService;
    __block DDNAFakeInstanceFactory *fakeFactory;
    
    beforeEach(^{
        engageService = [[DDNAEngageService alloc] initWithEnvironmentKey:@"12345abcde"
                                                                engageURL:@"http://engage.net"
                                                               hashSecret:nil
                                                               apiVersion:@"1.0.0"
                                                               sdkVersion:@"1.0.0"
                                                                 platform:@"iOS"
                                                                   locale:@"en_UK"
                                                           timezoneOffset:@"-05"
                                                             manufacturer:@"Apple Inc."
                                                   operatingSystemVersion:@"iOS 9.1"
                                                           timeoutSeconds:5
                                                      cacheExpiryInterval:100];
        [engageService clearCache];
        
        fakeFactory = [[DDNAFakeInstanceFactory alloc] init];
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] init];
        engageService.factory = fakeFactory;
    });
    
    it(@"calls completion handler with failed request", ^{
        
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@"Request body couldn't be processed: One or more of the compulsory parameters are missing!"
                                                                          statusCode:400
                                                                               error:nil];
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        DDNAEngageRequest *request = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                               userId:@"user-id-1234"
                                                                            sessionId:@"session-id-12345"];
        
        [engageService request:request handler:^(NSString *response, NSInteger statusCode, NSError *error) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = error;
        }];
        
        expect(resultResponse).to.equal(@"Request body couldn't be processed: One or more of the compulsory parameters are missing!");
        expect(resultStatusCode).to.equal(400);
        expect(resultError).to.beNil();

    });
    
    it(@"calls completion handler with successful response", ^{
        
        NSDictionary *request = @{
            @"userID": @"user-id-1234",
            @"sessionID": @"session-id-12345",
            @"version": @"1.0.0",
            @"sdkVersion": @"1.0.0",
            @"platform": @"iOS",
            @"locale": @"en_UK",
            @"timezoneOffset": @"-05",
            @"manufacturer": @"Apple Inc.",
            @"operatingSystemVersion": @"iOS 9.1",
            @"decisionPoint": @"testDecisionPoint",
            @"flavour": @"engagement",
            @"parameters": @{
                @"foo": @"bar",
                @"score": @1
            }
        };

        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:[NSString stringWithContentsOfDictionary:request]
                                                                          statusCode:200
                                                                               error:nil];
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-1234"
                                                                                  sessionId:@"session-id-12345"];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).to.equal([NSString stringWithContentsOfDictionary:request]);
        expect(resultStatusCode).to.equal(200);
        expect(resultError).to.beNil();
        
    });
    
    it(@"calls completion handler with failed response", ^{
        
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:nil
                                                                          statusCode:-1
                                                                               error:[NSError errorWithDomain:NSURLErrorDomain code:-57 userInfo:nil]];
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-12345"
                                                                                  sessionId:@"session-id-12345"];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).to.beNil();
        expect(resultStatusCode).to.equal(-1);
        expect(resultError).to.equal([NSError errorWithDomain:NSURLErrorDomain code:-57 userInfo:nil]);
        
    });
    
    it(@"uses the cache correctly", ^{

        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-12345"
                                                                                  sessionId:@"session-id-12345"];
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        // Bad request with empty cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@""
                                                                          statusCode:400
                                                                               error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"");
        expect(resultStatusCode).will.equal(400);
        expect(resultError).will.beNil();
        
        // Good response, which should be added to cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@"{\"parameters\":{}}"
                                                                          statusCode:200
                                                                               error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"{\"parameters\":{}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();
        
        // Bad request, returns value from cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@""
                                                                          statusCode:500
                                                                               error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"{\"isCachedResponse\":true,\"parameters\":{}}");
        expect(resultStatusCode).will.equal(500);
        expect(resultError).will.beNil();
        
        // Good response again
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@"{\"parameters\":{\"colour\":\"blue\"}}"
                                                                          statusCode:200
                                                                               error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"{\"parameters\":{\"colour\":\"blue\"}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();
        
    });
    
    it(@"skips the cache on unavailable engagements", ^{
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
            userId:@"user-id-12345"
            sessionId:@"session-id-12345"];
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        // good response, which should be added to cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc]
            initWithURL:@"http://engage.net"
            data:@"{\"parameters\":{}}"
            statusCode:200
            error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"{\"parameters\":{}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();
        
        // bad request, should not return value from cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc]
            initWithURL:@"http://engage.net"
            data:@""
            statusCode:400
            error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"");
        expect(resultStatusCode).will.equal(400);
        expect(resultError).will.beNil();
        
        // good response again
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc]
            initWithURL:@"http://engage.net"
            data:@"{\"parameters\":{\"colour\":\"blue\"}}"
            statusCode:200
            error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).will.equal(@"{\"parameters\":{\"colour\":\"blue\"}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();
    });
    
    it(@"works with a disabled cache", ^{
        
        engageService = [[DDNAEngageService alloc] initWithEnvironmentKey:@"12345abcde"
                                                                engageURL:@"http://engage.net"
                                                               hashSecret:nil
                                                               apiVersion:@"1.0.0"
                                                               sdkVersion:@"1.0.0"
                                                                 platform:@"iOS"
                                                                   locale:@"en_UK"
                                                           timezoneOffset:@"-05"
                                                             manufacturer:@"Apple Inc."
                                                   operatingSystemVersion:@"iOS 9.1"
                                                           timeoutSeconds:5
                                                      cacheExpiryInterval:0];
        [engageService clearCache];
        engageService.factory = fakeFactory;
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-12345"
                                                                                  sessionId:@"session-id-12345"];
        
        
        
        __block NSString *resultResponse;
        __block NSInteger resultStatusCode;
        __block NSError *resultError;
        
        // Bad request with empty cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@""
                                                                          statusCode:400
                                                                               error:nil];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];

        expect(resultResponse).will.equal(@"");
        expect(resultStatusCode).will.equal(400);
        expect(resultError).will.beNil();

        // Good response, which should be ignored cache
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@"{\"parameters\":{}}"
                                                                          statusCode:200
                                                                               error:nil];

        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];

        expect(resultResponse).will.equal(@"{\"parameters\":{}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();

        // Bad request, passes respose straight back
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@""
                                                                          statusCode:400
                                                                               error:nil];

        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];

        expect(resultResponse).will.equal(@"");
        expect(resultStatusCode).will.equal(400);
        expect(resultError).will.beNil();

        // Good response again
        fakeFactory.fakeNetworkRequest = [[DDNAFakeNetworkRequest alloc] initWithURL:@"http://engage.net"
                                                                                data:@"{\"parameters\":{\"colour\":\"blue\"}}"
                                                                          statusCode:200
                                                                               error:nil];

        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];

        expect(resultResponse).will.equal(@"{\"parameters\":{\"colour\":\"blue\"}}");
        expect(resultStatusCode).will.equal(200);
        expect(resultError).will.beNil();
        
    });
    
});

SpecEnd
