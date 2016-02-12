//
//  DDNAVolatileEventStore.m
//  
//
//  Created by David White on 11/12/2015.
//
//

#import "DDNAVolatileEventStore.h"
#import "DDNALog.h"

@interface DDNAVolatileEventStore ()

@property (nonatomic, assign) NSUInteger maxQueueSizeBytes;
@property (nonatomic, strong) NSMutableData *inQueue;
@property (nonatomic, strong) NSMutableData *outQueue;

@end

@implementation DDNAVolatileEventStore

- (instancetype)initWithSizeBytes:(NSUInteger)bytes
{
    if ((self = [super init])) {
        self.maxQueueSizeBytes = bytes;
        self.inQueue = [NSMutableData dataWithCapacity:bytes];
        self.outQueue = [NSMutableData dataWithCapacity:bytes];
    }
    return self;
}

#pragma mark - DDNAEventStoreProtocol

- (BOOL)pushEvent:(NSDictionary *)event
{
    @synchronized(self) {
        
        @try {
            
            if (event.allKeys.count == 0) {
                DDNALogWarn(@"Ignoring empty event");
                return NO;
            }
            
            if ([NSJSONSerialization isValidJSONObject:event]) {
                
                NSError * error = nil;
                NSData * data = [NSJSONSerialization dataWithJSONObject:event options:0 error:&error];
                
                if (error) {
                    DDNALogWarn(@"Failed to serialise object: %@", error.localizedDescription);
                    return NO;
                }
                
                // store event as length+data
                if (self.inQueue.length + sizeof(NSUInteger) + data.length < self.maxQueueSizeBytes) {
                    NSUInteger length = data.length;
                    [self.inQueue appendBytes:&length length:sizeof(NSUInteger)];
                    [self.inQueue appendData:data];
                    
                } else {
                    DDNALogWarn(@"Event store full");
                    return NO;
                }
                
            } else {
                DDNALogWarn(@"Not a valid JSON object");
                return NO;
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Exception writing JSON object to queue: %@", exception.reason);
            return NO;
        }
        
        return YES;
    }
}

- (BOOL)swapBuffers
{
    @synchronized(self) {
        // only swap if the out queue is empty
        if (self.outQueue.length == 0) {
            NSMutableData *temp = self.inQueue;
            self.inQueue = self.outQueue;
            self.outQueue = temp;
            return YES;
        }
        return NO;
    }
}

- (NSArray *)readOut
{
    @synchronized(self) {
        NSMutableArray *events = [NSMutableArray array];
        @try {
            
            NSInteger index = 0;
            while (index < self.outQueue.length) {
                
                NSData *eventField = nil;
                NSUInteger eventLength = 0;
                
                [self.outQueue getBytes:&eventLength range:NSMakeRange(index, sizeof(eventLength))];
                index += sizeof(eventLength);
                eventField = [self.outQueue subdataWithRange:NSMakeRange(index, eventLength)];
                index += eventLength;
                
                if (eventField.length != eventLength) {
                    DDNALogWarn(@"Attempted to read %lu bytes from event store, actually read %lu bytes", (unsigned long)eventLength, (unsigned long)eventField.length);
                    self.outQueue.length = 0;
                    break;
                }
                
                [events addObject:[[NSString alloc] initWithData:eventField encoding:NSUTF8StringEncoding]];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Problem reading events from the Event Store: %@", exception.reason);
            self.outQueue.length = 0;
        }
        return events;
    }
}

- (void)clearOut
{
    @synchronized(self) {
        self.outQueue.length = 0;
    }
}

- (void)clearAll
{
    @synchronized(self) {
        self.inQueue.length = 0;
        self.outQueue.length = 0;
    }
}

- (BOOL)isInEmpty
{
    @synchronized(self) {
        return self.inQueue.length == 0;
    }
}

- (BOOL)isOutEmpty
{
    @synchronized(self) {
        return self.outQueue.length == 0;
    }
}

@end
