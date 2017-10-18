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
 Lightweight logging class for the SDK.
 
 Define Macros to make the interface easier to use.  Enable debug logging by defining
 DDNA_DEBUG=YES.
 */

#define DDNA_LOG_FLAG_ERROR    (1 << 0)  // 0...00001
#define DDNA_LOG_FLAG_WARN     (1 << 1)  // 0...00010
#define DDNA_LOG_FLAG_INFO     (1 << 2)  // 0...00100
#define DDNA_LOG_FLAG_DEBUG    (1 << 3)  // 0...01000
#define DDNA_LOG_FLAG_VERBOSE  (1 << 4)  // 0...10000

#ifndef DDNA_DEBUG
    #define DDNA_DEBUG NO
#endif

typedef NS_OPTIONS(NSUInteger, DDNALogLevel) {
    DDNALogLevelNone    = 0,
    DDNALogLevelError   = 1 << 0,
    DDNALogLevelWarn    = 1 << 1,
    DDNALogLevelInfo    = 1 << 2,
    DDNALogLevelDebug   = 1 << 3,
    DDNALogLevelVerbose = 1 << 4
};

#define DDNALogDebug(frmt, ...) do{ [DDNALog log:DDNA_LOG_FLAG_DEBUG \
                                            file:__FILE__ \
                                        function:sel_getName(_cmd) \
                                            line:__LINE__ \
                                          format:(frmt), ##__VA_ARGS__]; } while(0)

#define DDNALogWarn(frmt, ...) do{ [DDNALog log:DDNA_LOG_FLAG_WARN \
                                           file:__FILE__ \
                                       function:sel_getName(_cmd) \
                                           line:__LINE__ \
                                         format:(frmt), ##__VA_ARGS__]; } while(0)


@interface DDNALog : NSObject

+ (void)setLogLevel:(DDNALogLevel)logLevel;

+ (void)log:(int)flag
       file:(const char *)file
   function:(const char *)function
       line:(int)line
     format:(NSString *)format, ... __attribute__ ((format (__NSString__, 5, 6)));

@end
