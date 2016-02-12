//
//  DDNAParams.h
//  DeltaDNA
//
//  Created by David White on 15/02/2016.
//
//

#import <Foundation/Foundation.h>

@interface DDNAParams : NSObject

+ (instancetype)params;

- (void)setParam:(NSObject *)param forKey:(NSString *)key;

- (NSObject *)paramForKey:(NSString *)key;

- (NSDictionary *)dictionary;

@end
