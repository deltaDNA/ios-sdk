//
//  DDNAFakeInstanceFactory.h
//  DeltaDNA
//
//  Created by David White on 21/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import "DDNAInstanceFactory.h"


@interface DDNAFakeInstanceFactory : DDNAInstanceFactory

@property (nonatomic, strong) DDNANetworkRequest *fakeNetworkRequest;   // override, else returns default

@property (nonatomic, strong) DDNAEngageService *fakeEngageService;

@end
