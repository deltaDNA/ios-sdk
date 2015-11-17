//
//  DDNAInstanceFactory.h
//  
//
//  Created by David White on 17/11/2015.
//
//

#import <Foundation/Foundation.h>

@class DDNANetworkRequest;
@protocol DDNANetworkRequestDelegate;

@class DDNAEngageService;


@interface DDNAInstanceFactory : NSObject

+ (instancetype)sharedInstance;

- (DDNANetworkRequest *)buildNetworkRequestWithURL: (NSURL *)URL
                                       jsonPayload: (NSString *)jsonPayload
                                          delegate: (id<DDNANetworkRequestDelegate>)delegate;

- (DDNAEngageService *)buildEngageService;

@end
