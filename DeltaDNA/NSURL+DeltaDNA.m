//
//  DDNANetworkURL.m
//  
//
//  Created by David White on 15/10/2015.
//
//

#import "NSURL+DeltaDNA.h"
#import "NSString+DeltaDNA.h"

@implementation NSURL (DeltaDNA)

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey
{
    return [NSURL URLWithEngageEndpoint:endpoint environmentKey:environmentKey payload:@"" hashSecret:nil];
}

+ (NSURL *)URLWithEngageEndpoint:(NSString *)endpoint environmentKey:(NSString *)environmentKey payload:(NSString *)payload hashSecret:(NSString *)hashSecret
{
    NSString *hashComponent = @"";
    
    if (hashSecret != nil && hashSecret.length > 0) {
        hashComponent = [NSString stringWithFormat:@"/hash/%@", [[payload stringByAppendingString:hashSecret] md5]];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@%@", endpoint, environmentKey, hashComponent];
    
    return [NSURL URLWithString:url];
}

@end
