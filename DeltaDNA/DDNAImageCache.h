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
#import <UIKit/UIKit.h>

@interface DDNAImageCache : NSObject

+ (instancetype)sharedInstance;

- (instancetype)initWithURLSession:(NSURLSession *)session cacheDir:(NSString *)cacheDir;

- (void)setImage:(UIImage *)image forURL:(NSURL *)url;

- (UIImage *)imageForURL:(NSURL *)url;

- (void)requestImageForURL:(NSURL *)url completionHandler:(void (^)(UIImage * _Nullable image))completionHandler;

- (void)prefechImagesForURLs:(NSArray <NSURL *> *)urls completionHandler:(void (^)(NSInteger downloaded, NSError *error))completionHandler;

- (instancetype)init NS_UNAVAILABLE;

@end
