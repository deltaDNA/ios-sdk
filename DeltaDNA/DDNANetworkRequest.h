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

#import <Foundation/Foundation.h>

@protocol DDNANetworkRequestDelegate;

@interface DDNANetworkRequest : NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSString *jsonPayload;
@property (nonatomic, assign) NSInteger timeoutSeconds;

@property (nonatomic, weak) id<DDNANetworkRequestDelegate> delegate;

/**
 Replace default NSURLSession to allow mocking in unit tests.
 */
@property (nonatomic, strong) NSURLSession *urlSession;

- (instancetype)initWithURL: (NSURL *)URL jsonPayload:(NSString *)jsonPayload;

- (void)send;

- (void)handleResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

@end

@protocol DDNANetworkRequestDelegate <NSObject>

- (void)request:(DDNANetworkRequest *)request didReceiveResponse: (NSString *)response statusCode: (NSInteger)statusCode;
- (void)request:(DDNANetworkRequest *)request didFailWithResponse: (NSString *)response statusCode: (NSInteger)statusCode error: (NSError *)error;

@end