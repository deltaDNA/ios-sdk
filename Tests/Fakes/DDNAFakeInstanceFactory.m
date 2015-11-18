//
//  DDNAFakeInstanceFactory.m
//  DeltaDNA
//
//  Created by David White on 21/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
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
