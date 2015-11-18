//
//  DDNAFakeNetworkRequest.m
//  SmartAds
//
//  Created by David White on 22/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import "DDNAFakeNetworkRequest.h"

@interface DDNAFakeNetworkRequest ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;

@end

@implementation DDNAFakeNetworkRequest

- (instancetype)initWithURL:(NSString *)URL data:(NSString *)data statusCode:(NSInteger)statusCode error:(NSError *)error
{
    if ((self = [super init])) {
        self.data = [data dataUsingEncoding:NSUTF8StringEncoding];
        self.response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:URL]
                                                    statusCode:statusCode
                                                   HTTPVersion:@"HTTP/1.1"
                                                  headerFields:@{}];
        self.error = error;
    }
    return self;
}

- (void)send
{
    NSLog(@"I'm a fake network request");
    [self handleResponse:self.data response:self.response error:self.error];
}

@end

