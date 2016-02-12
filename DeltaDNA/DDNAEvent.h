//
//  DDNAEvent.h
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
//

#import <Foundation/Foundation.h>

@interface DDNAEvent : NSObject

+ (instancetype)eventWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

- (void)setParam:(NSObject *)param forKey:(NSString *)key;


// Returns a copy
- (NSDictionary *)dictionary;

@end
