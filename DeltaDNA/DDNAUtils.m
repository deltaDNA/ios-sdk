//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "DDNAUtils.h"
#import "DDNALog.h"
#import "NSString+DeltaDNA.h"

@interface DDNAUtils()
@end

@implementation DDNAUtils

+ (NSString*) fixURL: (NSString*) url
{
    NSString *lowerCase = [url lowercaseString];
    if (![lowerCase hasPrefix:@"http://"] && ![lowerCase hasPrefix:@"https://"]) {
        return [@"https://" stringByAppendingString:url];
    } else if ([lowerCase hasPrefix:@"http://"]) {
        DDNALogWarn(@"Changing %@ to use HTTPS", url);
        return [@"https://" stringByAppendingString:[url substringFromIndex:[@"http://" length]]];
    } else {
        return url;
    }
}

+ (NSString *) getCurrentTimestamp
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:gregorianCalendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *) generateUserID
{
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *) generateSessionID
{
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *)getCacheDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"DeltaDNA"];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDNALogDebug(@"Error occured while creating directories. %@, %@ %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
    }
    return documentsDirectory;
}

@end
