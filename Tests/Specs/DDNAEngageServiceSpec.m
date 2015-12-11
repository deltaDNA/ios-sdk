//
//  DDNAEngageServiceSpec.m
//  DeltaDNA
//
//  Created by David White on 16/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
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
#import "NSString+DeltaDNA.h"
#import "DDNACache.h"


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
        [[DDNACache sharedCache] clear];
        engageService = [[DDNAEngageService alloc] initWithEnvironmentKey:@"12345abcde"
                                                                engageURL:@"http://engage.net"
                                                               hashSecret:nil
                                                               apiVersion:@"1.0.0"
                                                               sdkVersion:@"1.0.0"
                                                                 platform:@"iOS"
                                                           timezoneOffset:@"-05"
                                                             manufacturer:@"Apple Inc."
                                                   operatingSystemVersion:@"iOS 9.1"
                                                           timeoutSeconds:5];
        
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
        __block NSString *resultError;
        
        DDNAEngageRequest *request = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                               userId:@"user-id-1234"
                                                                            sessionId:@"session-id-12345"];
        
        [engageService request:request handler:^(NSString *response, NSInteger statusCode, NSString *error) {
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
        __block NSString *resultError;
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-1234"
                                                                                  sessionId:@"session-id-12345"];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSString *connectionError) {
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
        __block NSString *resultError;
        
        DDNAEngageRequest *engageRequest = [[DDNAEngageRequest alloc] initWithDecisionPoint:@"testDecisionPoint"
                                                                                     userId:@"user-id-12345"
                                                                                  sessionId:@"session-id-12345"];
        
        [engageService request:engageRequest handler:^(NSString *response, NSInteger statusCode, NSString *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).to.beNil();
        expect(resultStatusCode).to.equal(-1);
        expect(resultError).to.equal(@"The operation couldn’t be completed. (NSURLErrorDomain error -57.)");
        
    });
    
});

SpecEnd