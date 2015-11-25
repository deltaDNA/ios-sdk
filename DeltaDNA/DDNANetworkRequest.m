//
//  DDNANetworkRequest.m
//  
//
//  Created by David White on 15/10/2015.
//
//

#import "DDNANetworkRequest.h"
#import "DDNASDK.h"

@interface DDNANetworkRequest ()

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSString *jsonPayload;

@end

@implementation DDNANetworkRequest

- (instancetype)initWithURL:(NSURL *)URL jsonPayload:(NSString *)jsonPayload
{
    if ((self = [super init])) {
        self.URL = URL;
        self.jsonPayload = jsonPayload;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        // TODO: make this configurable
        sessionConfiguration.allowsCellularAccess = YES;
        
        self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)send
{
    // TODO: Is Internet reachable?
    [self makeRequest];
}

- (void)makeRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[DDNASDK sharedInstance].settings.httpRequestTimeoutSeconds];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self.jsonPayload dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponse:data response:response error:error];
    }] resume];
}

- (void)handleResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{    
    if (self.delegate) {
        if (error != nil) {
            [self.delegate request:self didFailWithResponse:nil statusCode:-1 error:error];
        } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (statusCode >= 400) {
                [self.delegate request:self didFailWithResponse:responseString statusCode:statusCode error:error];
            } else {
                
                [self.delegate request:self didReceiveResponse:responseString statusCode:statusCode];
            }
        }
    }
}

@end
