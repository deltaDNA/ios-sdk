//
//  NSString+DeltaDNA.h
//  DeltaDNASDK
//
//  Created by David White on 18/07/2014.
//  Copyright (c) 2014 deltadna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DeltaDNA)

+ (BOOL) stringIsNilOrEmpty: (NSString*) aString;

+ (NSString *) stringWithContentsOfDictionary: (NSDictionary *) aDictionary;

- (NSString *) md5;

- (BOOL)isEqualToStringCaseInsensitive:(NSString *)string;

@end
