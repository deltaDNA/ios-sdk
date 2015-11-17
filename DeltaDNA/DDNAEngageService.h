//
//  DDNAEngageService.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import "DDNADecisionPoint.h"

@class DDNAInstanceFactory;

@interface DDNAEngageService : NSObject

@property (nonatomic, weak) DDNAInstanceFactory *factory;
@property (nonatomic, copy) void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError);

// TODO - what happens when you want to restart with a different
// session id or user id?
// TODO - implement a cache

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *sessionID;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly) NSString *platform;
@property (nonatomic, copy, readonly) NSString *timezoneOffset;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, copy, readonly) NSString *operatingSystemVersion;

@property (nonatomic, assign, getter=isRequestInProgress, readonly) BOOL requestInProgress;

- (instancetype)initWithEndpoint: (NSString *)endpoint
                  environmentKey: (NSString *)environmentKey
                      hashSecret: (NSString *)hashSecret
                          userID: (NSString *)userID
                       sessionID: (NSString *)sessionID
                         version: (NSString *)version
                      sdkVersion: (NSString *)sdkVersion
                        platform: (NSString *)platform
                  timezoneOffset: (NSString *)timezoneOffset
                    manufacturer: (NSString *)manufacturer
          operatingSystemVersion: (NSString *)operatingSystemVersion;


- (void)requestWithDecisionPoint: (NSString *)decisionPoint
                      parameters: (NSDictionary *)parameters
               completionHandler: (void (^)(NSString *response,
                                            NSInteger statusCode,
                                            NSError *connectionError))handler;

- (void)requestWithDecisionPoint: (NSString *)decisionPoint
                         flavour: (DDNADecisionPointFlavour)flavour
                      parameters: (NSDictionary *)parameters
               completionHandler: (void (^)(NSString *response,
                                            NSInteger statusCode,
                                            NSError *connectionError))handler;

@end

