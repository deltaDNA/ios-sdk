//
//  DDNANetworkRequest.h
//  
//
//  Created by David White on 15/10/2015.
//
//

#import <Foundation/Foundation.h>

@protocol DDNANetworkRequestDelegate;

@interface DDNANetworkRequest : NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSString *jsonPayload;
@property (nonatomic, assign) NSInteger timeoutSeconds;

@property (nonatomic, weak) id<DDNANetworkRequestDelegate> delegate;

/**
 Replace default NSURLSession to allow mocking in unit tests.
 */
@property (nonatomic, strong) NSURLSession *urlSession;

- (instancetype)initWithURL: (NSURL *)URL jsonPayload:(NSString *)jsonPayload;

- (void)send;

- (void)handleResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

@end

@protocol DDNANetworkRequestDelegate <NSObject>

- (void)request:(DDNANetworkRequest *)request didReceiveResponse: (NSString *)response statusCode: (NSInteger)statusCode;
- (void)request:(DDNANetworkRequest *)request didFailWithResponse: (NSString *)response statusCode: (NSInteger)statusCode error: (NSError *)error;

@end