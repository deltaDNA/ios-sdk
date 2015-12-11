//
//  DDNAVolatileEventStore.h
//  
//
//  Created by David White on 11/12/2015.
//
//

#import <Foundation/Foundation.h>
#import "DDNAEventStoreProtocol.h"

@interface DDNAVolatileEventStore : NSObject <DDNAEventStoreProtocol>

- (instancetype)initWithSizeBytes:(NSUInteger)bytes;

@end
