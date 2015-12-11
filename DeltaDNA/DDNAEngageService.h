//
//  DDNAEngageService.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

@class DDNAInstanceFactory;

@interface DDNAEngageRequest : NSObject

@property (nonatomic, copy, readonly) NSString *decisionPoint;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, copy) NSString *flavour;
@property (nonatomic, strong) NSDictionary *parameters;

- (instancetype)initWithDecisionPoint:(NSString *)decisionPoint
                               userId:(NSString *)userId
                            sessionId:(NSString *)sessionId;

- (NSString *)description;

@end

typedef void (^DDNAEngageResponse) (NSString *response, NSInteger statusCode, NSString *error);

@interface DDNAEngageService : NSObject

@property (nonatomic, weak) DDNAInstanceFactory *factory;

- (instancetype)initWithEnvironmentKey:(NSString *)environmentKey
                             engageURL:(NSString *)engageURL
                            hashSecret:(NSString *)hashSecret
                            apiVersion:(NSString *)apiVersion
                            sdkVersion:(NSString *)sdkVersion
                              platform:(NSString *)platform
                        timezoneOffset:(NSString *)timezoneOffset
                          manufacturer:(NSString *)manufacturer
                operatingSystemVersion:(NSString *)operatingSystemVersion
                        timeoutSeconds:(NSInteger)timeoutSeconds;

- (void)request:(DDNAEngageRequest *)request handler:(DDNAEngageResponse)responseHander;

@end

