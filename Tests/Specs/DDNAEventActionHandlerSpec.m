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

#import "DDNAEventAction.h"
#import "DDNAEvent.h"
#import "DDNAEventTrigger.h"
#import "DDNAEventActionHandler.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNAImageCache.h"


SpecBegin(DDNAEventActionHandlerTest)

describe(@"event action handler", ^{
    
    it(@"handles game parameters", ^{
        
        __block BOOL called = NO;
        __block NSDictionary *returnedParameters = nil;
        DDNAGameParametersHandler *h = [[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *parameters) {
            called = YES;
            returnedParameters = [NSDictionary dictionaryWithDictionary:parameters];
        }];
        
        expect(h.type).to.equal(@"gameParameters");
        
        DDNAEventTrigger *mockTrigger = mock([DDNAEventTrigger class]);
        [given([mockTrigger actionType]) willReturn:@"imageMessage"];
        
        // ignores triggers for non matching actions
        [h handleEventTrigger:mockTrigger];
        expect(called).to.beFalsy();
        
        [given([mockTrigger actionType]) willReturn:@"gameParameters"];
        [given([mockTrigger response]) willReturn:@{@"parameters":@{@"a":@1}}];
        
        [h handleEventTrigger:mockTrigger];
        expect(called).to.beTruthy();
        expect(returnedParameters).to.equal(@{@"a":@1});
    });
    
    it(@"handles image messages", ^{
        
        __block BOOL called = NO;
        __block DDNAImageMessage *returnedImageMessage = nil;
        DDNAImageMessageHandler *h = [[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAImageMessage *imageMessage) {
            called = YES;
            returnedImageMessage = imageMessage;
        }];
        
        expect(h.type).to.equal(@"imageMessage");
        
        DDNAEventTrigger *mockTrigger = mock([DDNAEventTrigger class]);
        [given([mockTrigger actionType]) willReturn:@"gameParameters"];
        
        // ignores triggers for non matching actions
        [h handleEventTrigger:mockTrigger];
        expect(called).to.beFalsy();
        
        [given([mockTrigger actionType]) willReturn:@"imageMessage"];
        [given([mockTrigger response]) willReturn:@{@"parameters":@{@"a":@1},
                                                    @"image":@{
                                                            @"url":@"/image",
                                                            @"height":@1,
                                                            @"width":@1,
                                                            @"spritemap":@{
                                                                @"background":@{}
                                                            },
                                                            @"layout":@{
                                                                @"landscape":@{}
                                                            }
                                                            }}];
        
        __strong Class mockImageCacheClass = mockClass([DDNAImageCache class]);
        DDNAImageCache *mockImageCache = mock([DDNAImageCache class]);
        stubSingleton(mockImageCacheClass, sharedInstance);
        [given([DDNAImageCache sharedInstance]) willReturn:mockImageCache];
        UIImage *mockImage = mock([UIImage class]);
        [givenVoid([mockImageCache requestImageForURL:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(UIImage * _Nullable image) = [invocation mkt_arguments][1];
            completionHandler(mockImage);
            return nil;
        }];
        [given([mockImageCache imageForURL:anything()]) willReturn:mockImage];
        
        [h handleEventTrigger:mockTrigger];
        expect(called).will.beTruthy();
        expect(returnedImageMessage).willNot.beNil();
        expect(returnedImageMessage.parameters).will.equal(@{@"a":@1});
    });
    
    it(@"handles empty responses", ^{
        
        __block BOOL called = NO;
        __block NSDictionary *returnedParameters = nil;
        DDNAGameParametersHandler *h = [[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *parameters) {
            called = YES;
            returnedParameters = [NSDictionary dictionaryWithDictionary:parameters];
        }];
        
        DDNAEventTrigger *mockTrigger = mock([DDNAEventTrigger class]);
        [given([mockTrigger actionType]) willReturn:@"gameParameters"];
        [given([mockTrigger response]) willReturn:@{}];
        
        [h handleEventTrigger:mockTrigger];
        expect(called).to.beTruthy();
        expect(returnedParameters).to.equal(@{});
    });
    
    it(@"doesn't return an image message if resources are missing", ^{
        
        __block BOOL called = NO;
        __block DDNAImageMessage *returnedImageMessage = nil;
        DDNAImageMessageHandler *h = [[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAImageMessage *imageMessage) {
            called = YES;
            returnedImageMessage = imageMessage;
        }];
        
        expect(h.type).to.equal(@"imageMessage");
        
        DDNAEventTrigger *mockTrigger = mock([DDNAEventTrigger class]);
        [given([mockTrigger actionType]) willReturn:@"gameParameters"];
        
        // ignores triggers for non matching actions
        [h handleEventTrigger:mockTrigger];
        expect(called).to.beFalsy();
        
        [given([mockTrigger actionType]) willReturn:@"imageMessage"];
        [given([mockTrigger response]) willReturn:@{@"parameters":@{@"a":@1},
                                                    @"image":@{
                                                            @"url":@"/image",
                                                            @"height":@1,
                                                            @"width":@1,
                                                            @"spritemap":@{
                                                                    @"background":@{}
                                                                    },
                                                            @"layout":@{
                                                                    @"landscape":@{}
                                                                    }
                                                            }}];
        
        __strong Class mockImageCacheClass = mockClass([DDNAImageCache class]);
        DDNAImageCache *mockImageCache = mock([DDNAImageCache class]);
        stubSingleton(mockImageCacheClass, sharedInstance);
        [given([DDNAImageCache sharedInstance]) willReturn:mockImageCache];
        UIImage *mockImage = mock([UIImage class]);
        [givenVoid([mockImageCache requestImageForURL:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(UIImage * _Nullable image) = [invocation mkt_arguments][1];
            completionHandler(mockImage);
            return nil;
        }];
        [given([mockImageCache imageForURL:anything()]) willReturn:nil];
        
        [h handleEventTrigger:mockTrigger];
        expect(called).will.beFalsy();
        expect(returnedImageMessage).will.beNil();
    });
});

SpecEnd
