//
//  DDNANetworkRequest.m
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

#import "DDNANetworkRequest.h"


SpecBegin(DDNANetworkRequest)

describe(@"network request", ^{
   
    it(@"calls delegate with a valid response", ^{
       
        // Create a request.
        NSURL *url = [NSURL URLWithString:@"http://deltadna.net"];
        NSString *payload = @"{'greeting':'hello'}";
        id<DDNANetworkRequestDelegate> delegate = mockProtocol(@protocol(DDNANetworkRequestDelegate));

        DDNANetworkRequest *request = [[DDNANetworkRequest alloc] initWithURL:url jsonPayload:payload];
        request.delegate = delegate;
        
        // Replace the default NSURLSession with our mock.
        NSURLSession *mockSession = mock([NSURLSession class]);
        request.urlSession = mockSession;
        
        // Make the request.
        [request send];
        
        // Mock what the sessions completionHandler does.
        NSString *resultStr = @"{'foo': 'bar'}";
        NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *resultResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockSession) dataTaskWithRequest:anything() completionHandler:(id)argument];
        void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = [argument value];
        completionHandler(resultData, resultResponse, nil);
        
        // Confirm delegate is called correctly
        [verify(delegate) request:request didReceiveResponse:resultStr statusCode:200];
        
    });
    
    it(@"calls delegate with an invalid response", ^{
        
        // Create a request.
        NSURL *url = [NSURL URLWithString:@"https://deltadna.net"];
        NSString *payload = @"{'greeting':'hello'}";
        id<DDNANetworkRequestDelegate> delegate = mockProtocol(@protocol(DDNANetworkRequestDelegate));
        
        DDNANetworkRequest *request = [[DDNANetworkRequest alloc] initWithURL:url jsonPayload:payload];
        request.delegate = delegate;
        
        
        // Replace the default NSURLSession with our mock.
        NSURLSession *mockSession = mock([NSURLSession class]);
        request.urlSession = mockSession;
        
        // Make the request.
        [request send];
        
        // Mock what the sessions completionHandler does.
        NSString *resultStr = @"{'foo': 'bar'}";
        NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *resultResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:404 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockSession) dataTaskWithRequest:anything() completionHandler:(id)argument];
        void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = [argument value];
        completionHandler(resultData, resultResponse, nil);
        
        // Confirm delegate is called correctly
        [verify(delegate) request:request didFailWithResponse:resultStr statusCode:404 error:nil];
        
    });
    
    it(@"calls delegate with an error response", ^{
        
        // Create a request.
        NSURL *url = [NSURL URLWithString:@"https://deltadna.net"];
        NSString *payload = @"{'greeting':'hello'}";
        id<DDNANetworkRequestDelegate> delegate = mockProtocol(@protocol(DDNANetworkRequestDelegate));
        
        DDNANetworkRequest *request = [[DDNANetworkRequest alloc] initWithURL:url jsonPayload:payload];
        request.delegate = delegate;
        
        // Replace the default NSURLSession with our mock.
        NSURLSession *mockSession = mock([NSURLSession class]);
        request.urlSession = mockSession;
        
        // Make the request.
        [request send];
        
        // Mock what the sessions completionHandler does.
        NSError *resultError = [NSError errorWithDomain:NSURLErrorDomain code:-57 userInfo:nil];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockSession) dataTaskWithRequest:anything() completionHandler:(id)argument];
        void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = [argument value];
        completionHandler(nil, nil, resultError);
        
        // Confirm delegate is called correctly
        [verify(delegate) request:request didFailWithResponse:nil statusCode:-1 error:resultError];
        
    });

    
});

SpecEnd