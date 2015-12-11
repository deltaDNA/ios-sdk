//
//  DDNAEventStoreProtocol.h
//  
//
//  Created by David White on 11/12/2015.
//
//

#import <Foundation/Foundation.h>

@protocol DDNAEventStoreProtocol <NSObject>

@required

- (BOOL)pushEvent:(NSDictionary *)event;
- (BOOL)swapBuffers;
- (BOOL)isInEmpty;
- (BOOL)isOutEmpty;
- (NSArray *)readOut;
- (void)clearOut;
- (void)clearAll;

@end
