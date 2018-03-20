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

@class DDNAParams;
@class DDNAImageMessage;
@class DDNASDK;

NS_ASSUME_NONNULL_BEGIN

/**
 The @c EngageFactory helps with creating the different types of action available
 from our Engage service.  It makes the request to engage and calls your handler
 when the request completes.
 */
@interface DDNAEngageFactory : NSObject

typedef void (^GameParametersHandler)(NSDictionary * gameParameters);
typedef void (^ImageMessageHandler)(DDNAImageMessage * _Nullable imageMessage);

/**
 Requests a basic set of game parameters from Engage.  These are returned as a @c NSDictionary
 of game parameter to value pairs.  If no campaign is setup for the decision point the
 dictionary will be empty, so you are safe to test for expected keys.
 
 @param decisionPoint The decision point this action will be called for.
 
 @param handler A callback that will contain the set of game parameters.
 */
- (void)requestGameParametersForDecisionPoint:(NSString *)decisionPoint
                                      handler:(GameParametersHandler)handler;

/**
 Requests a basic set of game parameters from Engage.  These are returned as a @c NSDictionary
 of game parameter to value pairs.  If no campaign is setup for the decision point the
 dictionary will be empty, so you are safe to test for expected keys.
 
 @param decisionPoint The decision point this action will be called for.
 
 @param parameters An optional set of real-time parameters to pass to Engage.
 
 @param handler A callback that will contain the set of game parameters if successful.
 */
- (void)requestGameParametersForDecisionPoint:(NSString *)decisionPoint
                                   parameters:(nullable DDNAParams *)parameters
                                      handler:(GameParametersHandler)handler;

/**
 Requests an image message popup from Engage.
 
 @param decisionPoint The decision point this action will be called for.
 
 @parm handler A callback that will contain the @c DDNAImageMessage if successful.
 */
- (void)requestImageMessageForDecisionPoint:(NSString *)decisionPoint
                                    handler:(ImageMessageHandler)handler;

/**
 Requests an image message popup from Engage.
 
 @param decisionPoint The decision point this action will be called for.
 
 @param parameters An optional set of real-time parameters to pass to Engage.
 
 @parm handler A callback that will contain the @c DDNAImageMessage if successful.
 */
- (void)requestImageMessageForDecisionPoint:(NSString *)decisionPoint
                                 parameters:(nullable DDNAParams *)parameters
                                    handler:(ImageMessageHandler)handler;

- (instancetype)initWithDDNASDK:(DDNASDK *)sdk;

@end

NS_ASSUME_NONNULL_END
