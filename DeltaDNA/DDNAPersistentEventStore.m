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

#import "DDNAPersistentEventStore.h"
#import "DDNAPlayerPrefs.h"
#import "DDNALog.h"

static NSString *const PP_KEY_IN_FILE = @"DDSDK_EVENT_IN_FILE";
static NSString *const PP_KEY_OUT_FILE = @"DDSDK_EVENT_OUT_FILE";
static NSString *const FILE_A = @"A";
static NSString *const FILE_B = @"B";
static NSString *const kSettingsFile = @"EventStore.plist";
static NSString *const kInFileName = @"In File";
static NSString *const kOutFileName = @"Out File";

@interface DDNAPersistentEventStore ()
{
    NSFileHandle * inFileHandle;
    NSString * inFilePath;
    NSFileHandle * outFileHandle;
    NSString * outFilePath;
    BOOL initialised;
    NSMutableDictionary *settings;
}

@property (nonatomic, assign) NSUInteger maxFileSizeBytes;

@end

@implementation DDNAPersistentEventStore

- (instancetype)initWithPath:(NSString *)path sizeBytes:(NSUInteger)bytes clean:(BOOL)clean
{
    if ((self = [super init]))
    {
        self.maxFileSizeBytes = bytes;
        settings = [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
        if (settings == nil || clean) settings = [NSMutableDictionary dictionary];
        [self initialiseFileStreamsInDir:path clearStore:clean];
        initialised = true;
    }
    return self;
}

- (BOOL)pushEvent:(NSDictionary *)eventDictionary
{
    @synchronized(self)
    {
        if (initialised)
        {
            @try
            {
                // Serialise to a JSON byte array
                NSError * error = nil;
                NSData * eventData = [NSJSONSerialization dataWithJSONObject:eventDictionary
                                                                     options:0
                                                                       error:&error];
                if (error != nil && error.code != 0)
                {
                    DDNALogWarn(@"Event Store failed to serialize '%@' event to JSON, got %li", eventDictionary[@"eventName"], (long)error.code);
                    return false;
                }
                
                NSUInteger eventLength = eventData.length;
                
                if ([inFileHandle offsetInFile] + eventLength < self.maxFileSizeBytes) {
                    // Storage format is simply length:record in utf-8.
                    NSMutableData *bytes = [NSMutableData data];
                    [bytes appendBytes:&eventLength length:sizeof(eventLength)];
                    [bytes appendData:eventData];
                    
                    [inFileHandle writeData:bytes];
                    return true;
                } else {
                    DDNALogWarn(@"Event Store full, dropping '%@' event (%lu bytes).", eventDictionary[@"eventName"], eventLength);
                    return false;
                }
            }
            @catch (NSException *exception)
            {
                DDNALogWarn(@"Problem pushing '%@' event to Event Store: %@", eventDictionary[@"eventName"], exception.reason);
            }
        }
        return false;
    }
}

- (BOOL)swapBuffers
{
    @synchronized(self)
    {
        // Only swap if the out buffer is empty.
        unsigned long long fileOffset = outFileHandle.offsetInFile;
        if ([outFileHandle seekToEndOfFile] == 0)
        {
            // Close off the write stream.
            [inFileHandle synchronizeFile];
            // Swap the file handles and paths.
            NSFileHandle *temp = inFileHandle;
            inFileHandle = outFileHandle;
            outFileHandle = temp;
            NSString *tempPath = inFilePath;
            inFilePath = outFilePath;
            outFilePath = tempPath;
            
            // Reset the write stream.
            [inFileHandle truncateFileAtOffset:0];
            // Reset the read stream.
            [outFileHandle seekToFileOffset:0];
            
            [self storeBufferSettings];
            
            return true;
        }
        else
        {
            [outFileHandle seekToFileOffset:fileOffset];
            return false;
        }
    }
}

- (NSArray *)readOut
{
    @synchronized(self)
    {
        // Return an array of Strings, the JSON representation of each event.
        NSMutableArray *results = [NSMutableArray array];
        @try
        {
            NSData *lengthField;
            NSData *eventField;
            NSUInteger eventLength = 0;
            
            while ([lengthField = [outFileHandle readDataOfLength:sizeof(eventLength)] length] > 0)
            {
                [lengthField getBytes:&eventLength length:sizeof(eventLength)];
                eventField = [outFileHandle readDataOfLength:eventLength];
                if (eventField.length != eventLength) {
                    DDNALogWarn(@"Attempted to read %lu bytes from event store, actually read %lu bytes", (unsigned long)eventLength, (unsigned long)eventField.length);
                    [outFileHandle truncateFileAtOffset:0];
                    break;
                }
                [results addObject:[[NSString alloc] initWithData:eventField encoding:NSUTF8StringEncoding]];
            }
            // reset so we can read again
            [outFileHandle seekToFileOffset:0];
        }
        @catch (NSException *exception)
        {
            DDNALogDebug(@"Problem reading events from the Event Store: %@", exception.reason);
            [outFileHandle truncateFileAtOffset:0];
        }
        
        return results;
    }
}

- (void)clearOut
{
    @synchronized(self)
    {
        [outFileHandle truncateFileAtOffset:0];
    }
}

- (void)clearAll
{
    @synchronized(self) {
        [inFileHandle truncateFileAtOffset:0];
        [outFileHandle truncateFileAtOffset:0];
    }
}

- (BOOL)isInEmpty
{
    @synchronized(self) {
        unsigned long long fileOffset = inFileHandle.offsetInFile;
        if ([inFileHandle seekToEndOfFile] == 0) {
            return YES;
        }
        
        [inFileHandle seekToFileOffset:fileOffset];
        return NO;
    }
}

- (BOOL)isOutEmpty
{
    @synchronized(self) {
        unsigned long long fileOffset = outFileHandle.offsetInFile;
        if ([outFileHandle seekToEndOfFile] == 0) {
            return YES;
        }
        
        [outFileHandle seekToFileOffset:fileOffset];
        return NO;
    }
}

- (void)dealloc
{
    [inFileHandle synchronizeFile];
    [inFileHandle closeFile];
    [outFileHandle synchronizeFile];
    [outFileHandle closeFile];
}

// Private Methods //

- (void)initialiseFileStreamsInDir:(NSString *)storeDir clearStore:(BOOL)clearStore
{
    // Create directory if doesn't exist.
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:storeDir withIntermediateDirectories:YES attributes:nil error:&error];

    NSString *inFile = [settings objectForKey:kInFileName];
    if (!inFile) {
        // try legacy location
        inFile = [DDNAPlayerPrefs getObjectForKey:PP_KEY_IN_FILE withDefault:FILE_A];
    }
    if (!inFile) {
        inFile = FILE_A;
    }
    
    NSString *outFile = [settings objectForKey:kOutFileName];
    if (!outFile) {
        // try legacy location
        outFile = [DDNAPlayerPrefs getObjectForKey:PP_KEY_OUT_FILE withDefault:FILE_B];
    }
    if (!outFile) {
        outFile = FILE_B;
    }

    inFile = [inFile lastPathComponent];    // support for old event stores that may have full path
    outFile = [outFile lastPathComponent];
    
    inFilePath = [storeDir stringByAppendingPathComponent:inFile];
    outFilePath = [storeDir stringByAppendingPathComponent:outFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    inFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:inFilePath];
    if (inFileHandle == nil)
    {
        DDNALogDebug(@"In file %@ not found", inFilePath);
        [fileManager createFileAtPath:inFilePath contents:nil attributes:nil];
        inFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:inFilePath];
        
        if (inFileHandle == nil)
        {
            DDNALogDebug(@"Failed to create in file");
        }
        else
        {
            DDNALogDebug(@"In file created");
        }
    }
    else
    {
        DDNALogDebug(@"In file %@ exists", inFilePath);
        [inFileHandle seekToEndOfFile];
    }
    
    outFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:outFilePath];
    if (outFileHandle == nil)
    {
        DDNALogDebug(@"Out file %@ not found", outFilePath);
        [fileManager createFileAtPath:outFilePath contents:nil attributes:nil];
        outFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:outFilePath];
        
        if (outFileHandle == nil)
        {
            DDNALogDebug(@"Failed to create out file");
        }
        else
        {
            DDNALogDebug(@"Out file created");
        }
    }
    else
    {
        DDNALogDebug(@"Out file %@ exists", outFilePath);
        [outFileHandle seekToFileOffset:0];
    }
    
    if (clearStore == YES)
    {
        [inFileHandle truncateFileAtOffset:0];
        [outFileHandle truncateFileAtOffset:0];
    }
    
    [self storeBufferSettings];
}

- (NSString *)settingsPath
{
    // Finds the default location for saving user data on MacOS/iOS
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"DeltaDNA"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    return [documentsDirectory stringByAppendingPathComponent:kSettingsFile];
}

- (void)storeBufferSettings
{
    [settings setObject:[inFilePath lastPathComponent] forKey:kInFileName];
    [settings setObject:[outFilePath lastPathComponent] forKey:kOutFileName];
    [settings writeToFile:self.settingsPath atomically:YES];
}


@end