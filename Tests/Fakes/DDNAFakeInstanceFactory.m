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

#import "DDNAFakeInstanceFactory.h"
#import "DDNANetworkRequest.h"
#import "DDNAEngageService.h"


@implementation DDNAFakeInstanceFactory

- (DDNANetworkRequest *)buildNetworkRequestWithURL:(NSURL *)URL jsonPayload:(NSString *)jsonPayload delegate:(id<DDNANetworkRequestDelegate>)delegate
{
    if (self.fakeNetworkRequest) {
        self.fakeNetworkRequest.delegate = delegate;
        return self.fakeNetworkRequest;
    } else {
        return [super buildNetworkRequestWithURL:URL jsonPayload:jsonPayload delegate:delegate];
    }
}

- (DDNAEngageService *)buildEngageService
{
    if (self.fakeEngageService) {
        return self.fakeEngageService;
    } else {
        return [super buildEngageService];
    }
}

@end
