//
//  DDNACache.h
//  DeltaDNA
//
//  Created by David White on 05/02/2016.
//
//

#import <Foundation/Foundation.h>

@interface DDNACache : NSObject

+ (instancetype)sharedCache;

- (void)setObject:(NSObject *)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (void)clear;

@end
