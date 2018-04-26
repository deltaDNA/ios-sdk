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

@interface DDNAImageCache () <NSCacheDelegate>

@property (nonatomic, strong) NSCache<NSURL *, UIImage *> *cache;

@end

@implementation DDNAImageCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSCache *cache = [[NSCache alloc] init];
        cache.delegate = self;
        cache.name = @"ddna-asset-cache";
        self.cache = cache;
    }
    return self;
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url
{
    [self.cache setObject:image forKey:url];
}

- (UIImage *)imageForURL:(NSURL *)url
{
    return [self.cache objectForKey:url];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSLog(@"Cache %@ evicting %@", cache.name, obj);
}

@end
