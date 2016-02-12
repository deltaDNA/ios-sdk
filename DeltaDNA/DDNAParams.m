//
//  DDNAParams.m
//  DeltaDNA
//
//  Created by David White on 15/02/2016.
//
//

#import "DDNAParams.h"

@interface DDNAParams ()

@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation DDNAParams

+ (instancetype)params
{
    return [[DDNAParams alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.params = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setParam:(NSObject *)param forKey:(NSString *)key
{
    @try {
        if ([param isKindOfClass:[DDNAParams class]]) {
            [self.params setObject:[((DDNAParams *)param) dictionary] forKey:key];
        } else if ([param isKindOfClass:[NSDate class]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [self.params setObject:[dateFormatter stringFromDate:((NSDate *)param)] forKey:key];
        } else {
            [self.params setObject:param forKey:key];
        }
    }
    @catch (NSException *e) {
        @throw;
    }
}

- (NSObject *)paramForKey:(NSString *)key
{
    return [self.params objectForKey:key];
}

- (NSDictionary *)dictionary
{
    return self.params;
}

@end
