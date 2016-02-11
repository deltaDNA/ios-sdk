//
//  DDNACollectService.h
//  DeltaDNA
//
//  Created by David White on 10/02/2016.
//
//

#import <Foundation/Foundation.h>

@class DDNAInstanceFactory;

@interface DDNACollectRequest : NSObject

- (instancetype)initWithEventList:(NSArray *)eventList
                   timeoutSeconds:(NSInteger)timeoutSeconds
                          retries:(NSInteger)retries
                retryDelaySeconds:(NSInteger)retryDelaySeconds;

- (NSString *)toJSON;

@end

typedef void (^DDNACollectResponse) (NSString *response, NSInteger statusCode, NSString *error);

@interface DDNACollectService : NSObject

@property (nonatomic, weak) DDNAInstanceFactory *factory;

- (instancetype)initWithEnvironmentKey:(NSString *)environmentKey
                            collectURL:(NSString *)collectURL
                            hashSecret:(NSString *)hashSecret;

- (void)request:(DDNACollectRequest *)request handler:(DDNACollectResponse)responseHandler;

@end
