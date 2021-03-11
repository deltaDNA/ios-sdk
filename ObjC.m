#import <Foundation/Foundation.h>
#import "ObjC.h"

@implementation ObjC: NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        NSMutableDictionary *userInfo = exception.userInfo == nil ? [NSMutableDictionary new] : [exception.userInfo mutableCopy];
        if ([userInfo valueForKey:NSLocalizedFailureReasonErrorKey] == nil && exception.reason != nil ) {
            [userInfo setValue:exception.reason forKey:NSLocalizedFailureReasonErrorKey];
            
        }
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:userInfo];
        return NO;
    }
}

@end
