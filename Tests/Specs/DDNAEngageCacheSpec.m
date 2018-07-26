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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNAEngageCache.h"

void deleteCache() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [[documentsDirectory stringByAppendingPathComponent:@"DeltaDNA"] stringByAppendingPathComponent:@"EngageCache.plist"];
    [[NSFileManager defaultManager] removeItemAtPath:documentsDirectory error:nil];
}

SpecBegin(DDNAEngageCacheTest)

describe(@"engage cache", ^{
    
    beforeEach(^{
        deleteCache();
    });
    
    it(@"saves objects", ^{
        
        DDNAEngageCache *engageCache = [[DDNAEngageCache alloc] initWithPath:@"EngageCache.plist" expiryTimeInterval:100];
        [engageCache setObject:@"Test Obj" forKey:@"testKey"];
        
        DDNAEngageCache *engageCache2 = [[DDNAEngageCache alloc] initWithPath:@"EngageCache.plist" expiryTimeInterval:100];
        expect([engageCache2 objectForKey:@"testKey"]).to.equal(@"Test Obj");
    });
    
    it(@"cache can be cleared", ^{

        DDNAEngageCache *engageCache = [[DDNAEngageCache alloc] initWithPath:@"EngageCache.plist" expiryTimeInterval:100];
        [engageCache setObject:@"Test Obj" forKey:@"testKey"];
        
        [engageCache clear];
        
        expect([engageCache objectForKey:@"testKey"]).to.beNil();
    });
    
    it(@"expires items after a time", ^{
        
        DDNAEngageCache *engageCache = [[DDNAEngageCache alloc] initWithPath:@"EngageCache.plist" expiryTimeInterval:2];
        
        [engageCache setObject:@"Test Obj" forKey:@"testKey"];
        expect([engageCache objectForKey:@"testKey"]).after(1).to.equal(@"Test Obj");
        expect([engageCache objectForKey:@"testKey"]).after(2).to.beNil();
    });
    
    it(@"disables the cache with 0 expiry time", ^{
        
        DDNAEngageCache *engageCache = [[DDNAEngageCache alloc] initWithPath:@"EngageCache.plist" expiryTimeInterval:0];
        
        [engageCache setObject:@"Test Obj" forKey:@"testKey"];
        expect([engageCache objectForKey:@"testKey"]).to.beNil();
    });
    
});

SpecEnd
