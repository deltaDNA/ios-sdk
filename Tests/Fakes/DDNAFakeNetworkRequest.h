//
//  DDNAFakeNetworkRequest.h
//  DeltaDNA
//
//  Created by David White on 22/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "DDNANetworkRequest.h"


@interface DDNAFakeNetworkRequest : DDNANetworkRequest

- (instancetype)initWithURL:(NSString *)URL data:(NSString *)data statusCode:(NSInteger)statusCode error:(NSError *)error;

@end
