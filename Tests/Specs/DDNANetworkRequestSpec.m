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