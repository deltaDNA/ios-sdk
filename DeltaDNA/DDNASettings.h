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

#import <Foundation/Foundation.h>
#import "DDNAEventActionHandler.h"

extern NSString *const DDNA_SDK_VERSION;
extern NSString *const DDNA_ENGAGE_API_VERSION;

extern NSString *const DDNA_EVENT_STORAGE_PATH;
extern NSString *const DDNA_ENGAGE_STORAGE_PATH;
extern NSString *const DDNA_ACTION_STORAGE_PATH;

extern NSUInteger const DDNA_MAX_EVENT_STORE_BYTES;

@interface DDNASettings : NSObject

/**
 Instructs the SDK to send a newPlayer event when the game
 is run the first time.
 */
@property (nonatomic, assign) BOOL onFirstRunSendNewPlayerEvent;

/**
 Instructs the SDK to send a clientDevice event when the
 game is started.
 */
@property (nonatomic, assign) BOOL onStartSendClientDeviceEvent;

/**
 Instructs the SDK to send a gameStarted event when the 
 game is started.
 */
@property (nonatomic, assign) BOOL onStartSendGameStartedEvent;

/**
 Controls the delay in seconds between retrying failed
 HTTP requests.
 */
@property (nonatomic, assign) int httpRequestRetryDelaySeconds;

/**
 Controls the number of times the SDK retries a failed
 HTTP request before giving up.
 */
@property (nonatomic, assign) int httpRequestMaxTries;

/**
 Controls the timeout in seconds before the SDK decides
 a HTTP request to Collect is unresponsive.
 */
@property (nonatomic, assign) int httpRequestCollectTimeoutSeconds;

/**
 Controls the timeout in seconds before the SDK decides
 a HTTP request to Engage is unresponsive.
 */
@property (nonatomic, assign) int httpRequestEngageTimeoutSeconds;

/**
 Controls if the SDK should automatically upload events
 in the background.
 */
@property (nonatomic, assign) BOOL backgroundEventUpload;

/**
 Controls how many seconds the SDK waits before starting
 to upload events in the backgroound.
 */
@property (nonatomic, assign) int backgroundEventUploadStartDelaySeconds;

/**
 Controls how frequently the event upload method is called.
 */
@property (nonatomic, assign) int backgroundEventUploadRepeatRateSeconds;

/**
 Controls if the event store is used or not (default YES).
 */
@property (nonatomic, assign) BOOL useEventStore;

/**
 Controls the amount of time the app can be backgrounded before we consider a new session to have started.  A value of 0 disables automatically generating new sessions.
 */
@property (nonatomic, assign) int sessionTimeoutSeconds;

/**
 Number of seconds Engage retains cached responses from the Engage server.  A value of 0 disables the Engage cache.
 */
@property (nonatomic, assign) int engageCacheExpirySeconds;

/**
 Controls if the SDK will handle multiple actions on single event trigger
 */
@property (nonatomic, assign) BOOL multipleActionsForEventTriggerEnabled;

/**
 Controls whether the user or the SDK provides transaction events for the Audience Pinpointer signal events.
 A value of true means the SDK will automatically generate a basic transaction event for each unitySignalPurchase.
 A value of false means this will be provided by the game.
 Defaults to true.
 */
@property (nonatomic, assign) BOOL automaticallyGenerateTransactionForAudiencePinpointer;

/**
 Returns the path to the privates settings directory on 
 this device.
 */
+ (NSString *)getPrivateSettingsDirectoryPath;

/**
 Set Default Game Parameters Handler
 */
- (void)setDefaultGameParametersHandlerWith:(DDNAGameParametersHandler *)handler;

/**
 Set Default Image Message Handler
 */
- (void)setDefaultImageMessageHandlerWith:(DDNAImageMessageHandler *)handler;

/**
 Get Default Game Parameter Handler
 */
- (DDNAGameParametersHandler *)getDefaultGameParametersHandler;

/**
 Get Default Image Message Handler
 */
- (DDNAImageMessageHandler *)getDefaultImageParameterHandler;
@end
