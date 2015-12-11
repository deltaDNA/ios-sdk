//
//  DDNAPersistentEventStore.h
//
//
//  Created by David White on 11/12/2015.
//
//


#include <Foundation/Foundation.h>
#import "DDNAEventStoreProtocol.h"

@interface DDNAPersistentEventStore : NSObject <DDNAEventStoreProtocol>

- (instancetype)initWithPath:(NSString *)path sizeBytes:(NSUInteger)bytes clean:(BOOL)clean;

@end