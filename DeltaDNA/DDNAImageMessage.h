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
#import <UIKit/UIKit.h>

@class DDNAEngagement;

@protocol DDNAImageMessageDelegate;

/**
 `DDNAImageMessage` draws an Engagement Image Message action on the screen.  Create one from a requested `DDNAEngagement`.  If the response from Engage contains an image message a 'DDNAImageMessage' is instantiated, otherwise nil is returned.
 
  ## Preparing the Image Message
 
  The `DDNAImageMessage` must download it's resources such as the background image separately.  Use the `DDNAImageMessageDelegate` to be notified once the resources have been downloaded.
 
  ## Showing the Image Message
 
  Use `-isReady` to check the resources have been successfully downloaded.  If ready `-showFromRootViewController:` will draw the image message on top by adding it to the View Controller's hierarchy.
 
  ## Actions
 
  Each Image Message supports actions that are defined when setting up the Image Message on the platform.  The `DDNAImageMessageDelegate` calls `-onDismissImageMessage:name` for dismiss actions.  Other actions call `-inActionImageMessage:name:type:value`.  Use this callback to handle custom commands from the engagement.
 
 */
@interface DDNAImageMessage : UIView

@property (nonatomic, weak) id<DDNAImageMessageDelegate> delegate;

/**
 The custom parameters returned by the engagement.  Will be empty if the Enagement contained no parameters.
 */
@property (nonatomic, strong, readonly) NSDictionary *parameters;

/**
 Creates and returns a `DDNAImageMessage` if the engagement contains a valid image message response, otherwise nil.
 
 @param engagement The engagement returned from an engage request.
 
 @param delegate The delegate to use with this `DDNAImageMessage`.
 */
+ (instancetype)imageMessageWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNAImageMessageDelegate>)delegate;

/**
 Initialises a `DDNAImageMessage` from a `DDNAEngagement`.
 
 @param engagement The engagement returned from an engage request.
 
 @return An initialised image message or nil if the engagement didn't contain an image message.
 */
- (instancetype)initWithEngagement:(DDNAEngagement *)engagement;

/**
 Downloads the image resources from the CDN.  If the CDN is unavailable it will try to use a cache.
 */
- (void)fetchResources;

/**
 Reports if the image message is ready to be displayed.
 
 @return If the image message is ready to display.
 */
- (BOOL)isReady;

/**
 Shows the image message on screen.
 
 @param viewController The view controller to add the image message to.
 */
- (void)showFromRootViewController:(UIViewController *)viewController;

/**
 Reports of the image message is showing on screen.
 
 @return If the image message is showing on screen.
 */
- (BOOL)isShowing;

/**
 Closes the image message.  Normally you would not call this directly, it is called by the dismiss action when the player interacts with the image message.
 */
- (void)close;

@end

/**
 `DDNAImageMessageDelegate` reports when the image message resources have been downloaded from the CDN and when the player interacts with the popup.
 */
@protocol DDNAImageMessageDelegate <NSObject>

/**
 Reports when the image message has received its resources.  This could be a cached image if the CDN is unavailable.
 
 @param imageMessage The image message.
 */
- (void)didReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage;

/**
 Reports if an image message fails to download it's resources.  
 
 @param imageMessage The image message.
 
 @param reason A description of the error that occurred.
 */
- (void)didFailToReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage withReason:(NSString *)reason;

/**
 Called when a dismiss action is triggered by the player.
 
 @param imageMessage The image message.
 
 @param name The name of image message component that triggered the action (background, shim, button1 etc).
 */
- (void)onDismissImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name;

/**
 Called when an action is triggered by the player.
 
 @param imageMessage The image message.
 
 @param name The name of the image message component that triggers the action (background, shim, button1 etc).
 
 @param type The type of action (action, link, or store).
 
 @param value The value of the action.
 */
- (void)onActionImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name type:(NSString *)type value:(NSString *)value;

@end
