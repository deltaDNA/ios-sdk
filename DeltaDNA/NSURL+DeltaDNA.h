//
//  DDNANetworkURL.h
//  
//
//  Created by David White on 15/10/2015.
//
//

#import <Foundation/Foundation.h>

@interface NSURL (DeltaDNA)

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey;

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey payload:(NSString *)payload hashSecret:(NSString *)hashSecret;

@end
