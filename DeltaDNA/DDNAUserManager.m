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

#import "DDNAUserManager.h"
#import "NSString+DeltaDNA.h"
#import "DDNAPlayerPrefs.h"
#import "DDNAUtils.h"

NSString * const kDDNAUserId = @"DeltaDNA UserId";
NSString * const kDDNADoNotTrack = @"com.deltadna.doNotTrack";
NSString * const kDDNAForgotten = @"com.deltadna.forgotten";
NSString * const kDDNAFirstSession = @"com.deltadna.firstSession";
NSString * const kDDNALastSession = @"com.deltadna.lastSession";
NSString * const PP_KEY_USER_ID = @"DDSDK_USER_ID";
NSString * const kDDNAAdvertisingId = @"com.deltadna.advertisingId";

@interface DDNAUserManager ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation DDNAUserManager

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    if ((self = [super init])) {
        self.userDefaults = userDefaults;
        self.newPlayer = NO;
    }
    return self;
}

- (NSString *)userId
{
    NSString *userID = [self.userDefaults stringForKey:kDDNAUserId];
    if (userID) return userID;
    
    // read legacy userId
    userID = [DDNAPlayerPrefs getObjectForKey:PP_KEY_USER_ID withDefault:nil];
    if (userID != nil) {
        [self setUserId:userID];
    }
    return userID;
}

- (void)setUserId:(NSString *)userId
{
    NSString *persistedUserId = [self.userDefaults stringForKey:kDDNAUserId];
    self.newPlayer = NO;
    if ([NSString stringIsNilOrEmpty:persistedUserId]) {    // first time!
        self.newPlayer = YES;
        if ([NSString stringIsNilOrEmpty:userId]) {     // generate a user id
            userId = [DDNAUserManager generateUserID];
        }
    } else if (![NSString stringIsNilOrEmpty:userId]) {
        if (![persistedUserId isEqualToString:userId]) {    // started with a different user id
            self.newPlayer = YES;
        }
    }
    
    if (![NSString stringIsNilOrEmpty:userId]) {
        [self.userDefaults setObject:userId forKey:kDDNAUserId];
    }
}

- (BOOL)doNotTrack
{
    return [self.userDefaults boolForKey:kDDNADoNotTrack];
}

- (void)setDoNotTrack:(BOOL)doNotTrack
{
    [self.userDefaults setBool:doNotTrack forKey:kDDNADoNotTrack];
}

- (BOOL)forgotten
{
    return [self.userDefaults boolForKey:kDDNAForgotten];
}

- (void)setForgotten:(BOOL)forgotten
{
    [self.userDefaults setBool:forgotten forKey:kDDNAForgotten];
}

- (NSDate *)firstSession
{
    return [self.userDefaults objectForKey:kDDNAFirstSession];
}

- (void)setFirstSession:(NSDate *)firstSession
{
    [self.userDefaults setObject:firstSession forKey:kDDNAFirstSession];
}

- (NSUInteger)msSinceFirstSession
{
    return [self firstSession] ? [[NSDate date] timeIntervalSinceDate:[self firstSession]] * 1000 : 0;
}

- (NSDate *)lastSession
{
    return [self.userDefaults objectForKey:kDDNALastSession];
}

- (void)setLastSession:(NSDate *)lastSession
{
    [self.userDefaults setObject:lastSession forKey:kDDNALastSession];
}

- (NSUInteger)msSinceLastSession
{
    return [self lastSession] ? [[NSDate date] timeIntervalSinceDate:[self lastSession]] * 1000 : 0;
}

- (void)setAdvertisingId:(NSString *)advertisingId
{
    [self.userDefaults setObject:advertisingId forKey:kDDNAAdvertisingId];
}

- (NSString *)advertisingId
{
    return [self.userDefaults objectForKey:kDDNAAdvertisingId];
}

- (void)clearPersistentData
{
    [self.userDefaults removeObjectForKey:kDDNAUserId];
    [self.userDefaults removeObjectForKey:kDDNADoNotTrack];
    [self.userDefaults removeObjectForKey:kDDNAForgotten];
    [self.userDefaults removeObjectForKey:kDDNAFirstSession];
    [self.userDefaults removeObjectForKey:kDDNALastSession];
    [self.userDefaults removeObjectForKey:kDDNAAdvertisingId];
    self.newPlayer = NO;
}

+ (NSString *) generateUserID
{
    return [DDNAUtils generateUserID];
}

@end
