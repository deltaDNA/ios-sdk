// Simple wrapper for persisting player game data

#import <Foundation/Foundation.h>

@interface DDNAPlayerPrefs : NSObject

+ (void) setObject: (NSObject *) object forKey: (NSString *) key DEPRECATED_ATTRIBUTE;
+ (void) setInteger: (int) integer forKey: (NSString *) key DEPRECATED_ATTRIBUTE;

+ (id) getObjectForKey: (NSString *) key withDefault: (NSObject *) defaultObject;
+ (int) getIntegerForKey: (NSString *) key withDefault: (int) defaultInteger;

+ (void) deleteKey: (NSString *) key DEPRECATED_ATTRIBUTE;
+ (void) clear DEPRECATED_ATTRIBUTE;
+ (void) save DEPRECATED_ATTRIBUTE;

@end