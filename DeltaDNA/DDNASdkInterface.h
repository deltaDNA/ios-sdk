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

@class DDNAEvent;
@class DDNAEngagement;
@class DDNAUserManager;

@protocol DDNASdkInterface <NSObject>

@property (nonatomic, assign, readonly, getter = hasStarted) BOOL started;
@property (nonatomic, assign, readonly, getter = isUploading) BOOL uploading;

- (void)startWithNewPlayer:(DDNAUserManager *)userManager;

- (void)newSession;
- (void)stop;
- (void)recordEvent:(DDNAEvent *)event;
- (void)requestEngagement:(DDNAEngagement *)engagement
        completionHandler:(void(^)(NSDictionary *parameters, NSInteger statusCode, NSError *error))completionHandler;
- (void)requestEngagement:(DDNAEngagement *)engagement engagementHandler:(void(^)(DDNAEngagement *))engagementHandler;
- (void)recordPushNotification:(NSDictionary *) pushNotification
                     didLaunch:(BOOL) didLaunch;
- (void)requestSessionConfiguration:(DDNAUserManager *)userManager;
- (void)downloadImageAssets;
- (void)upload;
- (void)clearPersistentData;

- (void)setPushNotificationToken:(NSString *)pushNotificationToken;

@end
