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

#import "DDNAFakeNetworkRequest.h"

@interface DDNAFakeNetworkRequest ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;

@end

@implementation DDNAFakeNetworkRequest

- (instancetype)initWithURL:(NSString *)URL data:(NSString *)data statusCode:(NSInteger)statusCode error:(NSError *)error
{
    if ((self = [super init])) {
        self.data = [data dataUsingEncoding:NSUTF8StringEncoding];
        self.response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:URL]
                                                    statusCode:statusCode
                                                   HTTPVersion:@"HTTP/1.1"
                                                  headerFields:@{}];
        self.error = error;
    }
    return self;
}

- (void)send
{
    NSLog(@"I'm a fake network request");
    [self handleResponse:self.data response:self.response error:self.error];
}

@end

