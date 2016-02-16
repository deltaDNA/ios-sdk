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

@class DDNASettings;
@class DDNAEvent;
@class DDNAEngagement;
@protocol DDNAPopup;

@interface DDNASDK : NSObject

/**
 Change default SDK behaviour via the settings property.
 See DDNASettings.h for available options.
 */
@property (nonatomic, strong) DDNASettings *settings;

/** 
 The hash secret for your environment.  This must be set
 @b before starting the SDK.  You only need to set this
 if hashing as been enabled for this environment.  If 
 hashing is enabled and the secret has not been set Collect
 will return 403 errors.
 */
@property (nonatomic, copy) NSString *hashSecret;

/**
 A version string for your game.  This is used to help you
 identify which version of your game is being played on the
 platform.  This must be set @b before starting the SDK.
 */
@property (nonatomic, copy) NSString *clientVersion;

/**
 The Apple push notification token. Set this @b before starting
 the SDK to enable DeltaDNA to send push notifications to your
 game.  
 
 @see http://docs.deltadna.com/ios-sdk/#PushNotification for
 an example of how to get the token.
 */
@property (nonatomic, copy) NSString *pushNotificationToken;

/// The environment key for this game environment (Dev or Live).
@property (nonatomic, copy, readonly) NSString *environmentKey;
/// The URL for Collect for this environment.
@property (nonatomic, copy, readonly) NSString *collectURL;
/// The URL for Engage for this environment.
@property (nonatomic, copy, readonly) NSString *engageURL;
/// The User ID for this game.
@property (nonatomic, copy, readonly) NSString *userID;
/// The Session ID for this game.
@property (nonatomic, copy, readonly) NSString *sessionID;
/// The platform this game is running on.
@property (nonatomic, copy, readonly) NSString *platform;

/// Has the SDK been started yet.
@property (nonatomic, assign, getter = hasStarted) BOOL started;

/// Is the SDK uploading events.
@property (nonatomic, assign, getter = isUploading) BOOL uploading;

/**
 Singleton access to the deltaDNA SDK.
 @return The deltaDNA SDK instance.
 */
+ (instancetype)sharedInstance;

/**
 The SDK must be started once before you can send events.
 @param environmentKey The games's unique environment key.
 @param collectURL The games's unique Collect URL.
 @param engageURL The games's unique EngageURL, use nil if not using Engage.
 */
- (void)startWithEnvironmentKey: (NSString *) environmentKey
                     collectURL: (NSString *) collectURL
                      engageURL: (NSString *) engageURL;

/**
 The SDK must be started once before you can send events.
 @param environmentKey The games's unique environment key.
 @param collectURL The games's unique Collect URL.
 @param engageURL The games's unique EngageURL, use nil if not using Engage.
 @param userID The user id to associate the game events with, use nil if you want the SDK to generate a random one.
 */
- (void)startWithEnvironmentKey: (NSString *) environmentKey
                     collectURL: (NSString *) collectURL
                      engageURL: (NSString *) engageURL
                         userID: (NSString *) userID;

/**
 Generates a new session id, subsequent events will belong to a new session.
 */
- (void)newSession;

/**
 Sends a 'gameEnded' event to Collect and stops background uploads.
 */
- (void)stop;

/**
 Records an event using the DDNAEvent builder class.
 @param event The event to record.
 */
- (void)recordEvent:(DDNAEvent *)event;

/**
 Records an event with no custom parameters.
 @param eventName The name of the event schema.
 */
- (void)recordEventWithName:(NSString *)eventName;

/**
 Records an event with a dictionary of event parameters.  Structure the dictionary keys to match the @b eventParams structure of your event schema.
 @param eventName The name of the event schema.
 @param eventParams A dictionary of event parameters.
 */
- (void)recordEventWithName:(NSString *)eventName eventParams:(NSDictionary *)eventParams;

/**
 @typedef
 
 @abstract Block type for the callback from an Engage request.
 */
typedef void (^DDNAEngagementResponseBlock) (NSDictionary *engageResponse);

/**
 Makes an Engage call for a decision point.  If the decision point is
 recognised, the callback block is called with the response parameters.
 @param decisionPoint The decision point.
 @param callback The block to call once Engage returns.
 */
- (void)requestEngagement: (NSString *) decisionPoint
            callbackBlock: (DDNAEngagementResponseBlock) callback DEPRECATED_ATTRIBUTE;

/**
 Makes an Engage call for a decision point.  If the decision point is
 recognised, the callback block is called with the response parameters.
 @param decisionPoint The decision point.
 @param engageParams A dictionary of parameters for Engage.
 @param callback The block to call once Engage returns. Will be nil is no response is available.
 */
- (void)requestEngagement: (NSString *) decisionPoint
         withEngageParams: (NSDictionary *) engageParams
            callbackBlock: (DDNAEngagementResponseBlock) callback DEPRECATED_ATTRIBUTE;

/**
 Makes an Engage call.  Create a @c DDNAEngagement with a decision point and optional paramters.  If the engagement is recognised by the platform the completion handler returns the set of parameters to use.
 @param engagement The engagement to request.
 @param completionHandler Optional callback that reports the parameters the engagement returns.  The status code and error report any network failures.
 */
- (void)requestEngagement:(DDNAEngagement *)engagement
        completionHandler:(void(^)(NSDictionary *parameters, NSInteger statusCode, NSError *error))completionHandler;

/**
 Requests an image based engagement for popup on the screen.  This is a convienience around @c requestEngagement that loads the image resource automatically from the original engage request.  Register a block with the popup's afterPrepare block to be notified when the resource has loaded.
 @param decisionPoint The decisionPoint
 @param engageParams A dictionary of parameters for Engage.
 @param imagePopup An object that conforms to the @c DDNAPopup protocol that can handle the response.
 */
- (void)requestImageMessage: (NSString *) decisionPoint
           withEngageParams: (NSDictionary *) engageParams
                 imagePopup: (id <DDNAPopup>) popup DEPRECATED_ATTRIBUTE;

/**
 Requests an image based engagement for popup on the screen.  This is a convienience around @c requestEngagement that loads the image resource automatically from the original engage request.  Register a block with the popup's afterPrepare block to be notified when the resource has loaded.
 @param decisionPoint The decisionPoint
 @param engageParams A dictionary of parameters for Engage.
 @param imagePopup An object that conforms to the @c DDNAPopup protocol that can handle the response.
 @param callbackBlock A block that is called with the full engage response for custom behaviour.
 */
- (void)requestImageMessage: (NSString *) decisionPoint
           withEngageParams: (NSDictionary *) engageParams
                 imagePopup: (id <DDNAPopup>) popup
              callbackBlock: (DDNAEngagementResponseBlock) callback DEPRECATED_ATTRIBUTE;

/**
 Requests an image message engagement.  The image resource is automatically loaded from the engage request.  Register a block with the popup's afterPrepare block to be notified when the resource has loaded.
 @param engagement The engagement the image message is an action for.
 @param popup An object that conforms to the @c DDNAPopup protocol that can handle the response, for example @c DDNABasicPopup.
 @param completionHandler Optional callback that reports the parameters the engagement returns.  The status code and error report any network failures.
 */
- (void)requestImageMessage:(DDNAEngagement *)engagement
                      popup:(id<DDNAPopup>)popup
          completionHandler:(void(^)(NSDictionary *parameters, NSInteger statusCode, NSError *error))completionHandler;

/**
 Records receiving a push notification.  Call from @c application:didFinishLaunchingWithOptions and @c application:didReceiveRemoteNotification so we can track the open rate of your notifications.  It is safe to call this method before @c startWithEnvironmentKey:collectURL:engageURL, the event will be queued.
 */
- (void) recordPushNotification: (NSDictionary *) pushNotification
                      didLaunch: (BOOL) didLaunch;

/**
 Sends recorded events to deltaDNA.  The default SDK behaviour is to call this
 periodically in the background for you.  If you disable background uploading
 you must call this method reguraly to send your game events.  The call is
 non blocking.
 */
- (void)upload;

/**
 Clears persisted data from the device.  This includes any cached events that
 haven't been sent to Collect, cached engagement request responses and the 
 user id.  If the user id was auto generated by the SDK, a new user id will
 be created next time the game runs.  The newPlayer event will also be sent
 again.
 */
- (void)clearPersistentData;

@end
