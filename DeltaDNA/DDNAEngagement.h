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

/**
 `DDNAEngagement` creates and holds an engagement from the Engage service.  It is created with a `decisionPoint` which is a marker in the game that matches a decision point on the platform.  On the platform actions are defined that could be returned by Engage if this player matches the real-time criteria.  If a suitable match occurs a JSON response is returned and this is added to the requesting engagement.  The game should inspect the returned json to dynamically change the games' behaviour.
 
 ## Possible actions
 
 For a successful engagement the `-json` property will always contain a `parameters` key.  This will be empty if no parameters were added to the engagement action.  Optionally it may also contain `image` or `heading` and `message` if Image Message or Simple Message are defined.
 */
@interface DDNAEngagement : NSObject

/**
 The decision point for this engagement.
 */
@property (nonatomic, copy, readonly) NSString *decisionPoint;

/**
 The raw response from the Engage service.  This will be nil if the request has not been made or
 an error occurred.  If the Engagement could return a valid JSON response it will be a JSON string, else
 it will be a message with additional intformation.
 */
@property (nonatomic, copy) NSString *raw;

/**
 The http status code returned by the Engage service.  This will be 0 if the request has not
 been made or Engage had an error.
 */
@property (nonatomic, assign) NSInteger statusCode;

/**
 If the Engage request had a connection error, it is recorded here.
 */
@property (nonatomic, strong) NSError *error;

/**
 The Engage response as an NSDictionary.  If has yet to made this is nil, if there was a problem with engage this will be empty.
 */
@property (nonatomic, strong) NSDictionary *json;

/**
 Create an Engagement with a Decision Point.
 */
+ (instancetype)engagementWithDecisionPoint:(NSString *)decisionPoint;

/**
 Create an Engagement with a Decision Point.
 */
- (instancetype)initWithDecisionPoint:(NSString *)decisionPoint;

/**
 Add a parameter to the Decision Point.
 */
- (void)setParam:(NSObject *)param forKey:(NSString *)key;

/**
 Returns the Engagement as a dictionary.
 */
- (NSDictionary *)dictionary;

@end
