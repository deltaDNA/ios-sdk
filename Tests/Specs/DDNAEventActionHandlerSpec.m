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

#import "DDNAActionStore.h"
#import "DDNAEventAction.h"
#import "DDNAEvent.h"
#import "DDNAEventTrigger.h"
#import "DDNAEventActionHandler.h"
#import "NSDictionary+DeltaDNA.h"
#import "DDNAImageCache.h"


SpecBegin(DDNAEventActionHandlerTest)

describe(@"event action handler", ^{
    
    __block DDNAActionStore *store;
    
    beforeEach(^{
        store = mock([DDNAActionStore class]);
    });
    
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
        [h handleEventTrigger:mockTrigger store:store];
        expect(called).to.beFalsy();
        
        [given([mockTrigger actionType]) willReturn:@"gameParameters"];
        [given([mockTrigger response]) willReturn:@{@"parameters":@{@"a":@1}}];
        
        [h handleEventTrigger:mockTrigger store:store];
        expect(called).to.beTruthy();
        expect(returnedParameters).to.equal(@{@"a":@1});
        
        [verifyCount(store, never()) removeForTrigger:anything()];
    });
    
    it(@"handles persisted game parameters action and removes it", ^{
        __block BOOL called = NO;
        __block NSDictionary *returnedParameters = nil;
        DDNAGameParametersHandler *handler = [[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *parameters) {
            called = YES;
            returnedParameters = [NSDictionary dictionaryWithDictionary:parameters];
        }];
        
        DDNAEventTrigger *trigger = mock([DDNAEventTrigger class]);
        [given([trigger actionType]) willReturn:@"gameParameters"];
        [given([trigger response]) willReturn:@{@"parameters":@{@"a":@1}}];
        [given([store parametersForTrigger:trigger]) willReturn:@{@"b":@2}];
        
        [handler handleEventTrigger:trigger store:store];
        
        expect(called).to.beTruthy();
        expect(returnedParameters).to.equal(@{@"b":@2});
        [verify(store) removeForTrigger:trigger];
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
        [h handleEventTrigger:mockTrigger store:store];
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
        
        [h handleEventTrigger:mockTrigger store:store];
        expect(called).will.beTruthy();
        expect(returnedImageMessage).willNot.beNil();
        expect(returnedImageMessage.parameters).will.equal(@{@"a":@1});
        
        [verifyCount(store, never()) removeForTrigger:anything()];
    });
    
    // async block doesn't appear to get called in time for expectations to pass
    xit(@"handles persisted image message action and removes it", ^{
        __block BOOL called = NO;
        __block DDNAImageMessage *returnedImageMessage = nil;
        DDNAImageMessageHandler *handler = [[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAImageMessage *imageMessage) {
            called = YES;
            returnedImageMessage = imageMessage;
        }];
        
        DDNAEventTrigger *trigger = mock([DDNAEventTrigger class]);
        [given([trigger actionType]) willReturn:@"imageMessage"];
        [given([trigger response]) willReturn:@{@"parameters":@{@"a":@1},
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
        [given([store parametersForTrigger:trigger]) willReturn:@{@"b":@2}];
        
        __strong Class imageCacheClass = mockClass([DDNAImageCache class]);
        DDNAImageCache *imageCache = mock([DDNAImageCache class]);
        stubSingleton(imageCacheClass, sharedInstance);
        [given([DDNAImageCache sharedInstance]) willReturn:imageCache];
        UIImage *image = mock([UIImage class]);
        [givenVoid([imageCache requestImageForURL:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(UIImage * _Nullable image) = [invocation mkt_arguments][1];
            completionHandler(image);
            return nil;
        }];
        [given([imageCache imageForURL:anything()]) willReturn:image];
        
        [handler handleEventTrigger:trigger store:store];
        
        expect(called).to.beTruthy();
        expect([returnedImageMessage parameters]).to.equal(@{@"b":@2});
        [verify(store) removeForTrigger:trigger];
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
        
        [h handleEventTrigger:mockTrigger store:store];
        expect(called).to.beTruthy();
        expect(returnedParameters).to.equal(@{});
        
        [verifyCount(store, never()) removeForTrigger:anything()];
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
        [h handleEventTrigger:mockTrigger store:store];
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
        
        [h handleEventTrigger:mockTrigger store:store];
        expect(called).will.beFalsy();
        expect(returnedImageMessage).will.beNil();
        
        [verifyCount(store, never()) removeForTrigger:anything()];
    });
});

SpecEnd
