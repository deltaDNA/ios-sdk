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

#import <Foundation/Foundation.h>

@interface DDNAUserManager : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL doNotTrack;
@property (nonatomic, assign) BOOL forgotten;
@property (nonatomic, assign, getter=isNewPlayer) BOOL newPlayer;
@property (nonatomic, strong) NSDate *firstSession;
@property (nonatomic, strong) NSDate *lastSession;
@property (nonatomic, strong) NSString *crossGameUserId;
@property (nonatomic, strong) NSString *advertisingId;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (NSUInteger)msSinceFirstSession;
- (NSUInteger)msSinceLastSession;

- (void)clearPersistentData;

@end
