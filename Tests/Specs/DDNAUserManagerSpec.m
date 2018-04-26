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

#import "DDNAUserManager.h"

SpecBegin(DDNAUserManagerTest)

NSString * const SUITE_NAME = @"com.deltadna.test.UserManager";

describe(@"user manager", ^{
    
    __block NSUserDefaults *userDefaults;
    __block DDNAUserManager *userManager;
    
    beforeEach(^{
        [[[NSUserDefaults alloc] init] removePersistentDomainForName:SUITE_NAME];
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:SUITE_NAME];
        userManager = [[DDNAUserManager alloc] initWithUserDefaults:userDefaults];
    });
    
    it(@"generates a new user id with nil", ^{
        
        expect(userManager.userId).to.beNil();
        expect(userManager.newPlayer).to.beFalsy();
        userManager.userId = nil;
        
        NSString *generatedUserId = userManager.userId;
        expect(generatedUserId).notTo.beNil();
        expect(userManager.isNewPlayer).to.beTruthy();
        
        // can't reset this with nil
        userManager.userId = nil;
        expect(userManager.userId).to.equal(generatedUserId);
        expect(userManager.isNewPlayer).to.beFalsy();
    });
    
    it(@"uses a passed in user id", ^{
        
        expect(userManager.userId).to.beNil();
        userManager.userId = @"user123";
        
        expect(userManager.userId).to.equal(@"user123");
        expect(userManager.isNewPlayer).to.beTruthy();
        
        // can't reset this with same id
        userManager.userId = @"user123";
        expect(userManager.isNewPlayer).to.beFalsy();
    });
    
    it(@"can change the user id", ^{
       
        expect(userManager.userId).to.beNil();
        userManager.userId = nil;

        expect(userManager.isNewPlayer).to.beTruthy();
        
        // can't reset this with a different id
        userManager.userId = @"user123";
        expect(userManager.isNewPlayer).to.beTruthy();
        
    });
    
    it(@"clears the persisted data", ^{
       
        userManager.userId = @"user123";
        
        expect(userManager.userId).to.equal(@"user123");
        expect(userManager.newPlayer).to.beTruthy();
        expect(userManager.doNotTrack).to.beFalsy();
        expect(userManager.forgotten).to.beFalsy();
        
        userManager.doNotTrack = YES;
        expect(userManager.doNotTrack).to.beTruthy();
        userManager.forgotten = YES;
        expect(userManager.forgotten).to.beTruthy();
        
        [userManager clearPersistentData];
        
        expect(userManager.userId).to.beNil();
        expect(userManager.newPlayer).to.beFalsy();
        expect(userManager.doNotTrack).to.beFalsy();
        expect(userManager.forgotten).to.beFalsy();
    });
});

SpecEnd
