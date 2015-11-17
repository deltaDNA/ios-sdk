//
//  DDNAEngageService.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNAEngageService.h"
#import "DDNANetworkRequest.h"
#import "DDNAInstanceFactory.h"
#import "NSURL+DeltaDNA.h"
#import "NSString+Helpers.h"
#import "NSDictionary+Helpers.h"
#import "DDNALog.h"

@interface DDNAEngageService () <DDNANetworkRequestDelegate>

@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) NSString *environmentKey;
@property (nonatomic, copy) NSString *hashSecret;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *sdkVersion;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *timezoneOffset;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *operatingSystemVersion;

@property (nonatomic, assign) BOOL requestInProgress;

@end

@implementation DDNAEngageService

- (instancetype)initWithEndpoint:(NSString *)endpoint
                  environmentKey:(NSString *)environmentKey
                      hashSecret:(NSString *)hashSecret
                          userID:(NSString *)userID
                       sessionID:(NSString *)sessionID
                         version:(NSString *)version
                      sdkVersion:(NSString *)sdkVersion
                        platform:(NSString *)platform
                  timezoneOffset:(NSString *)timezoneOffset
                    manufacturer:(NSString *)manufacturer
          operatingSystemVersion:(NSString *)operatingSystemVersion
{
    if ((self = [super init])) {
        self.endpoint = endpoint;
        self.environmentKey = environmentKey;
        self.hashSecret = hashSecret;
        self.userID = userID;
        self.sessionID = sessionID;
        self.version = version;
        self.sdkVersion = sdkVersion;
        self.platform = platform;
        self.timezoneOffset = timezoneOffset;
        self.manufacturer = manufacturer;
        self.operatingSystemVersion = operatingSystemVersion;
        self.factory = [DDNAInstanceFactory sharedInstance];
    }
    return self;
}

- (void)requestWithDecisionPoint:(NSString *)decisionPoint
                      parameters:(NSDictionary *)parameters
               completionHandler:(void (^)(NSString *response,
                                           NSInteger statusCode,
                                           NSError *connectionError))handler
{
    return [self requestWithDecisionPoint:decisionPoint
                                  flavour:DDNADecisionPointFlavourEngagement
                               parameters:parameters
                        completionHandler:handler];
}

- (void)requestWithDecisionPoint:(NSString *)decisionPoint
                         flavour:(DDNADecisionPointFlavour)flavour
                      parameters:(NSDictionary *)parameters
               completionHandler:(void (^)(NSString *response,
                                           NSInteger statusCode,
                                           NSError *connectionError))handler
{
    DDNALogDebug(@"Making engage request for %@@%@ with parameters %@", decisionPoint, [NSString stringWithDDNADecisionPointFlavour:flavour], parameters);
    
    self.completionHandler = handler;
    
    NSMutableDictionary *request = [NSMutableDictionary dictionaryWithCapacity:11];
    [request setValue:self.userID forKey:@"userID"];
    [request setValue:self.sessionID forKey:@"sessionID"];
    [request setValue:self.version forKey:@"version"];
    [request setValue:self.sdkVersion forKey:@"sdkVersion"];
    [request setValue:self.platform forKey:@"platform"];
    [request setValue:self.timezoneOffset forKey:@"timezoneOffset"];
    [request setValue:self.manufacturer forKey:@"manufacturer"];
    [request setValue:self.operatingSystemVersion forKey:@"operatingSystemVersion"];
    [request setValue:decisionPoint forKey:@"decisionPoint"];
    [request setValue:[NSString stringWithDDNADecisionPointFlavour:flavour] forKey:@"flavour"];
    [request setValue:parameters forKey:@"parameters"];
    
    NSString *jsonPayload = [NSString stringWithContentsOfDictionary:request];
    
    NSURL *URL = [NSURL URLWithEngageEndpoint:self.endpoint
                               environmentKey:self.environmentKey
                                      payload:jsonPayload
                                   hashSecret:self.hashSecret];
    
    DDNANetworkRequest *networkRequest = [self.factory buildNetworkRequestWithURL:URL
                                                                      jsonPayload:jsonPayload
                                                                         delegate:self];
    [networkRequest send];
    self.requestInProgress = YES;
}

#pragma mark - DDNANetworkRequestDelegate;

- (void)request:(DDNANetworkRequest *)request didReceiveResponse:(NSString *)response statusCode:(NSInteger)statusCode
{
    self.requestInProgress = NO;
    self.completionHandler(response, statusCode, nil);
}

- (void)request:(DDNANetworkRequest *)request didFailWithResponse: (NSString *)response statusCode:(NSInteger)statusCode error:(NSError *)error
{
    self.requestInProgress = NO;
    self.completionHandler(response, statusCode, error);
}

@end
