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

@interface DDNAClientInfo : NSObject

@property (nonatomic, copy, readonly) NSString *platform;
@property (nonatomic, copy, readonly) NSString *deviceName;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *deviceType;
@property (nonatomic, copy, readonly) NSString *hardwareVersion;
@property (nonatomic, copy, readonly) NSString *operatingSystem;
@property (nonatomic, copy, readonly) NSString *operatingSystemVersion;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, copy, readonly) NSString *timezoneOffset;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *languageCode;
@property (nonatomic, copy, readonly) NSString *locale;

+ (DDNAClientInfo *) sharedInstance;

@end
