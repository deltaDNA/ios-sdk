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
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNAActionStore.h"
#import "DDNAEventTrigger.h"
#import "DDNASettings.h"

void cleanup() {
    NSString *actionStoragePath = [[DDNA_ACTION_STORAGE_PATH stringByReplacingOccurrencesOfString:@"{persistent_path}" withString:[DDNASettings getPrivateSettingsDirectoryPath]] stringByAppendingPathComponent:@"ActionStore.plist"];
    [[NSFileManager defaultManager] removeItemAtPath:actionStoragePath error:nil];
}

SpecBegin(DDNAActionStoreTest)

describe(@"action store", ^{
    
    __block DDNAActionStore *uut;
    
    beforeEach(^{
        uut = [[DDNAActionStore alloc] initWithPath:[DDNA_ACTION_STORAGE_PATH stringByReplacingOccurrencesOfString:@"{persistent_path}" withString:[DDNASettings getPrivateSettingsDirectoryPath]]];
    });
    
    afterEach(^{
        //cleanup();
    });
    
    it(@"saves and retrieves parameters for trigger", ^{
        DDNAEventTrigger *trigger = mock([DDNAEventTrigger class]);
        [given([trigger campaignId]) willReturn:@1];
        NSDictionary *params = @{@"a":@1};
        
        expect([uut parametersForTrigger:trigger]).to.beNil();
        
        [uut setParameters:params forTrigger:trigger];
        
        expect([uut parametersForTrigger:trigger]).to.equal(params);
    });
    
    it(@"removes parameters for trigger", ^{
        DDNAEventTrigger *trigger = mock([DDNAEventTrigger class]);
        [given([trigger campaignId]) willReturn:@1];
        [uut setParameters:@{@"a":@1} forTrigger:trigger];
        
        [uut removeForTrigger:trigger];
        
        expect([uut parametersForTrigger:trigger]).to.beNil();
    });
    
    it(@"store can be cleared", ^{
        DDNAEventTrigger *trigger = mock([DDNAEventTrigger class]);
        [given([trigger campaignId]) willReturn:@1];
        [uut setParameters:@{@"a":@1} forTrigger:trigger];
        
        [uut clear];
        
        expect([uut parametersForTrigger:trigger]).to.beNil();
    });
    
    it(@"changes are persisted", ^{
        DDNAEventTrigger *trigger1 = mock([DDNAEventTrigger class]);
        [given([trigger1 campaignId]) willReturn:@1];
        DDNAEventTrigger *trigger2 = mock([DDNAEventTrigger class]);
        [given([trigger2 campaignId]) willReturn:@2];
        DDNAEventTrigger *trigger3 = mock([DDNAEventTrigger class]);
        [given([trigger3 campaignId]) willReturn:@3];
        
        [uut setParameters:@{@"a":@1} forTrigger:trigger1];
        [uut setParameters:@{@"a":@2} forTrigger:trigger2];
        [uut clear];
        [uut setParameters:@{@"b":@2} forTrigger:trigger2];
        [uut setParameters:@{@"b":@3} forTrigger:trigger3];
        [uut removeForTrigger:trigger2];
        
        expect([uut parametersForTrigger:trigger1]).to.beNil();
        expect([uut parametersForTrigger:trigger2]).to.beNil();
        expect([uut parametersForTrigger:trigger3]).to.equal(@{@"b":@3});
    });
});

SpecEnd
