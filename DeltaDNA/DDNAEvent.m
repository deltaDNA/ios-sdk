//
//  DDNAEvent.m
//  DeltaDNA
//
//  Created by David White on 11/02/2016.
//
//

#import "DDNAEvent.h"
#import "DDNAParams.h"
#import "DDNAProduct.h"

@interface DDNAEvent ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, strong) DDNAParams *eventParams;

@end

@implementation DDNAEvent

+ (instancetype)eventWithName:(NSString *)name
{
    return [[DDNAEvent alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init])) {
        self.eventName = name;
        self.eventParams = [DDNAParams params];
    }
    return self;
}

- (void)setParam:(NSObject *)param forKey:(NSString *)key
{
    [self.eventParams setParam:param forKey:key];
}

- (NSDictionary *)dictionary
{
    return @{
        @"eventName": self.eventName,
        @"eventParams": [NSDictionary dictionaryWithDictionary:[self.eventParams dictionary]]
    };
}

@end
