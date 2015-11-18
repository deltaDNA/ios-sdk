//
//  DDNAEngageServiceSpec.m
//  SmartAds
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
#import "NSString+Helpers.h"


SpecBegin(DDNAEngageService)

describe(@"engage service request", ^{
    
    __block DDNAEngageService *engageService;
    __block DDNAFakeInstanceFactory *fakeFactory;
    
    beforeEach(^{
        engageService = [[DDNAEngageService alloc] initWithEndpoint:@"http://engage.net"
                                                     environmentKey:@"12345abcde"
                                                         hashSecret:nil
                                                             userID:@"user-id-1234"
                                                          sessionID:@"session-id-12345"
                                                            version:@"1.0.0"
                                                         sdkVersion:@"1.0.0"
                                                           platform:@"iOS"
                                                     timezoneOffset:@"-05"
                                                       manufacturer:@"Apple Inc."
                                             operatingSystemVersion:@"iOS 9.1"];
        
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
        
        [engageService requestWithDecisionPoint:nil flavour:DDNADecisionPointFlavourInternal parameters:nil completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
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
        __block NSError *resultError;
        
        [engageService requestWithDecisionPoint:nil flavour:DDNADecisionPointFlavourInternal parameters:nil completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
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
        
        [engageService requestWithDecisionPoint:nil flavour:DDNADecisionPointFlavourInternal parameters:nil completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
            resultResponse = response;
            resultStatusCode = statusCode;
            resultError = connectionError;
        }];
        
        expect(resultResponse).to.beNil();
        expect(resultStatusCode).to.equal(-1);
        expect(resultError).to.equal([NSError errorWithDomain:NSURLErrorDomain code:-57 userInfo:nil]);
        
    });
    
});

SpecEnd