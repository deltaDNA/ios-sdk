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

#import "DDNAImageCache.h"
#import "DDNALog.h"

static const NSURLRequestCachePolicy kCachePolicy = NSURLRequestUseProtocolCachePolicy;
static const NSTimeInterval kTimeoutInterval = 180;

@interface DDNAImageCache ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *cacheDir;

@end

@implementation DDNAImageCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.requestCachePolicy = kCachePolicy;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        sharedInstance = [[self alloc] initWithURLSession:session cacheDir:@"ImageCache"];
    });
    
    return sharedInstance;
}

- (instancetype)initWithURLSession:(NSURLSession *)session cacheDir:(NSString *)cacheDir
{
    self = [super init];
    if (self) {
        self.session = session;
        self.cacheDir = cacheDir;
    }
    return self;
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url
{
    NSString *location = [[self getCacheLocation] stringByAppendingPathComponent:[url lastPathComponent]];   // filenames are unique
    [UIImagePNGRepresentation(image) writeToFile:location atomically:YES];
}

- (UIImage *)imageForURL:(NSURL *)url
{
    NSString *location = [[self getCacheLocation] stringByAppendingPathComponent:[url lastPathComponent]];
    UIImage *image = [UIImage imageWithContentsOfFile:location];
    return image;
}

- (void)requestImageForURL:(NSURL *)url completionHandler:(void (^)(UIImage * _Nullable))completionHandler
{
    UIImage *image = [self imageForURL:url];
    if (image != nil) {
        DDNALogDebug(@"Cache hit for image at %@", url);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(image);
        });
    }
    else {
        DDNALogDebug(@"Cache miss for image at %@", url);
        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:kCachePolicy timeoutInterval:kTimeoutInterval];
        
        [[_session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
            if (location != nil) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                if (image != nil) {
                    DDNALogDebug(@"Downloaded image at %@", url);
                    [self setImage:image forURL:url];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(image);
                    });
                } else {
                    DDNALogWarn(@"Failed to create image from downloaded data.");
                    completionHandler(nil);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DDNALogWarn(@"Failed to download image asset: %@", error);
                    completionHandler(nil);
                });
            }
        }] resume];
    }
}

- (void)prefechImagesForURLs:(NSArray<NSURL *> *)urls completionHandler:(void (^)(NSInteger downloaded, NSError *error))completionHandler
{
    __block NSInteger remainingTasks = [urls count];
    
    for (NSURL *url in urls) {
        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:kCachePolicy timeoutInterval:kTimeoutInterval];
        [[_session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
            if (location != nil) {
                DDNALogDebug(@"Downloaded image at %@", url);
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                if (image != nil) {
                    [self setImage:image forURL:url];
                } else {
                    DDNALogWarn(@"Failed to create image from downloaded data.");
                    NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create image from downloaded data.", nil),
                    };
                    NSError *imageError = [NSError errorWithDomain:@"deltaDNA" code:-57 userInfo:userInfo];
                    completionHandler([urls count] - remainingTasks, imageError);
                }
            } else {
                DDNALogWarn(@"Failed to download image asset: %@", error);
                completionHandler([urls count] - remainingTasks, error);
            }
            if ((--remainingTasks) == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler([urls count] - remainingTasks, nil);
                });
            }
        }] resume];
    }
}

- (NSString *)getCacheLocation
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [[documentsDirectory stringByAppendingPathComponent:@"DeltaDNA"] stringByAppendingString:self.cacheDir];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    return documentsDirectory;
}

@end
