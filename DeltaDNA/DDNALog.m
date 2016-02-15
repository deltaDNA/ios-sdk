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

#import "DDNALog.h"

@implementation DDNALog

+ (void) log:(int)flag file:(const char *)file function:(const char *)function line:(int)line format:(NSString *)format, ...
{
    va_list args;
    if (format)
    {
        va_start(args, format);
        
        NSString *logMsg = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        NSString *level;
        
        switch (flag) {
            case DDNA_LOG_FLAG_DEBUG:
                level = @"DEBUG";
                break;
            case DDNA_LOG_FLAG_ERROR:
                level = @"ERROR";
                break;
            case DDNA_LOG_FLAG_INFO:
                level = @"INFO";
                break;
            case DDNA_LOG_FLAG_VERBOSE:
                level = @"VERBOSE";
                break;
            case DDNA_LOG_FLAG_WARN:
                level = @"WARNING";
                break;
            default:
                break;
        }
        
        NSLog(@"<DDNASDK %@:(%d)> [%@] %@", fileName, line, level, logMsg);
        
        va_end(args);
    }
}

@end
