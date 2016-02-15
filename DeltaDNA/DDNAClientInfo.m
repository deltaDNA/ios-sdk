//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
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

#import "DDNAClientInfo.h"
#import <UIKit/UIDevice.h>
#import <sys/sysctl.h>


@implementation DDNAClientInfo

+ (DDNAClientInfo *) sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static DDNAClientInfo * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id) init
{
    if ((self = [super init]))
    {
        _platform = [self getPlatform];
        _deviceName = [self getDeviceName];
        _deviceModel = [self getDeviceModel];
        _deviceType = [self getDeviceType];
        _hardwareVersion = [self getHardwareVersion];
        _operatingSystem = [self getOperatingSystem];
        _operatingSystemVersion = [self getOperatingSystemVersion];
        _manufacturer = [self getManufacturer];
        _timezoneOffset = [self getTimezoneOffset];
        _countryCode = [self getCountryCode];
        _languageCode = [self getLanguageCode];
        _locale = [self getLocale];
    }
    return self;
}

- (NSString *) getPlatform
{
    NSString * model = [UIDevice currentDevice].model;
    if ([model hasPrefix:@"iPad"]) return @"IOS_TABLET";
    else if ([model hasPrefix:@"iPhone"]) return @"IOS_MOBILE";
    else if ([model isEqualToString:@"Apple TV"]) return @"IOS_TV";
    return @"IOS";
}

- (NSString *) getDeviceName
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3G";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3G";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3G";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4G";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4G";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4G";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";

    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    return platform;
}

- (NSString *) getHardwareVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\w+(\\d+,\\d+)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:platform
                                                    options:0
                                                      range:NSMakeRange(0, [platform length])];
    if (match) {
        return [platform substringWithRange:[match rangeAtIndex:1]];
    }
    
    return nil;
}

- (NSString *) getDeviceModel
{
    return [UIDevice currentDevice].model;
}

- (NSString *) getDeviceType
{
    NSString * model = [UIDevice currentDevice].model;
    if ([model hasPrefix:@"iPad"]) return @"TABLET";
    else if ([model hasPrefix:@"iPhone"]) return @"MOBILE_PHONE";
    else if ([model containsString:@"TV"]) return @"TV";
    return @"UNKNOWN";
}

- (NSString *) getOperatingSystem
{
    NSString *operatingSystem = [UIDevice currentDevice].systemName;
    if ([operatingSystem isEqualToString: @"iPhone OS"]) return @"IOS";
    else if ([operatingSystem isEqualToString:@"tvOS"]) return @"TVOS";
    return @"OSX";
}

- (NSString *) getOperatingSystemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *) getManufacturer
{
    return @"Apple Inc";
}

- (NSString *) getTimezoneOffset
{
    long secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
    int hoursFromGMT = floor(secondsFromGMT / 3600.0);
    return [NSString stringWithFormat:@"%+03i", hoursFromGMT];
}

- (NSString *) getCountryCode
{
    NSError *error = NULL;
    NSRegularExpression *countryRegex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z]{2}$" options:0 error:&error];
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return [countryRegex numberOfMatchesInString:countryCode options:0 range:NSMakeRange(0, countryCode.length)] == 1 ? countryCode : @"ZZ";
}

- (NSString *) getLanguageCode
{
    NSError *error = NULL;
    NSRegularExpression *languageRegex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z]{2}$" options:0 error:&error];
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    return [languageRegex numberOfMatchesInString:languageCode options:0 range:NSMakeRange(0, languageCode.length)] == 1 ? languageCode : @"zz";
}

- (NSString *) getLocale
{
    NSLocale *locale = [NSLocale currentLocale];
    NSError *error = NULL;
    NSRegularExpression *localeRegex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z]{2}_[A-Z]{2}$" options:0 error:&error];
    return [localeRegex numberOfMatchesInString:locale.localeIdentifier options:0 range:NSMakeRange(0, locale.localeIdentifier.length)] == 1 ? locale.localeIdentifier : @"zz_ZZ";
}

@end
