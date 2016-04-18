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

#import <UIKit/UIKit.h>

__attribute__((deprecated))
@protocol DDNAPopup

/**
 Prepares the popup with the image part of an Engage response.
 
 @param image The image object from an Engage response.
 */
- (void)prepareWithImage:(NSDictionary*)image;

/**
 Displays the popup if is prepared.
 */
- (void)show;

/**
 Closes the popup explictly.
 */
- (void)close;

/**
 Block is called before @c prepareWithImage fetches it's resource.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^beforePrepare)();

/**
 Block is called after @c prepareWithImage has fetched it's resource.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^afterPrepare)();

/**
 Block is called when a view is clicked that dismisses the popup.
 @param name The name reports which view was selected.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^dismiss)(NSString* name);

/**
 Block is called when a view is clicked with an action or link.
 @param name The name reports which view was selected.
 @param type The type reports if it was an 'action' or a 'link'.
 @param value The value is the parameter for the action.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^onAction)(NSString* name, NSString* type, NSString* value);

/**
 Block is called before the popup is about to be closed.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^beforeClose)();

/**
 Block is called after the popup is closed.
 
 Use a weak reference if referencing the popup to avoid a retain cycle.
 */
@property (nonatomic, copy) void (^afterClose)();

@end

__attribute__((deprecated))
@interface DDNABasicPopup : UIView <DDNAPopup>

/**
 Creates a basic popup for use in a game.
 */
+ (DDNABasicPopup*)popup;

- (void)prepareWithImage:(NSDictionary*)image;
- (void)show;
- (void)close;

@property (nonatomic, copy) void (^beforePrepare)();
@property (nonatomic, copy) void (^afterPrepare)();
@property (nonatomic, copy) void (^dismiss)(NSString* name);
@property (nonatomic, copy) void (^onAction)(NSString* name, NSString* type, NSString* value);
@property (nonatomic, copy) void (^beforeClose)();
@property (nonatomic, copy) void (^afterClose)();

@end