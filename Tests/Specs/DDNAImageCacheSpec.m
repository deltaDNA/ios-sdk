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

#import "DDNAImageCache.h"

SpecBegin(DDNAImageCacheTest)

describe(@"image cache", ^{
    
    __block NSURLSession *mockSession;
    __block DDNAImageCache *imageCache;
    __block NSURL *mockURL;
    __block NSURL *mockURL2;
    __block UIImage *testImage;
    __block NSString *base64testImage = @"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
    __block UIImage *testImage2;
    __block NSString *base64testImage2 = @"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=";
    
    beforeEach(^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [[documentsDirectory stringByAppendingPathComponent:@"DeltaDNA"] stringByAppendingString:@"ImageCache"];
        [[NSFileManager defaultManager] removeItemAtPath:documentsDirectory error:nil];
        
        mockSession = mock([NSURLSession class]);
        imageCache = [[DDNAImageCache alloc] initWithURLSession:mockSession cacheDir:@"ImageCache"];
        
        mockURL = mock([NSURL class]);
        [given([mockURL lastPathComponent]) willReturn:@"test-image.png"];
        mockURL2 = mock([NSURL class]);
        [given([mockURL2 lastPathComponent]) willReturn:@"test-image2.png"];
        
        testImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:base64testImage options:0]];
        testImage2 = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:base64testImage2 options:0]];
    });
    
    it(@"stores images", ^{
        
        UIImage *image = [imageCache imageForURL:mockURL];
        expect(image).to.beNil();
        
        [imageCache setImage:testImage forURL:mockURL];
        
        UIImage *image2 = [imageCache imageForURL:mockURL];
        expect(UIImagePNGRepresentation(image2)).to.equal(UIImagePNGRepresentation(testImage));
    });
    
    it(@"fetches from the cache", ^{
        
        [imageCache setImage:testImage forURL:mockURL];
        
        __block UIImage *image2 = nil;
        [imageCache requestImageForURL:mockURL completionHandler:^(UIImage * _Nullable image) {
            image2 = image;
        }];
        
        expect(image2).willNot.beNil();
        expect(UIImagePNGRepresentation(image2)).will.equal(UIImagePNGRepresentation(testImage));
        
        [verifyCount(mockSession, never()) downloadTaskWithRequest:anything() completionHandler:anything()];
    });
    
    it(@"fetches and stores image if not in cache", ^{
        
        UIImage *image = [imageCache imageForURL:mockURL];
        expect(image).to.beNil();
        
        [givenVoid([mockSession downloadTaskWithRequest:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(NSURL * location, NSURLResponse * response, NSError * error) = [invocation mkt_arguments][1];
            completionHandler([NSURL URLWithString:[NSString stringWithFormat:@"data:image/png;base64,%@", base64testImage]], nil, nil);
            return nil;
        }];
        
        __block UIImage *image2 = nil;
        [imageCache requestImageForURL:mockURL completionHandler:^(UIImage * _Nullable image) {
            image2 = image;
        }];
        
        expect(image2).willNot.beNil();
        expect(UIImagePNGRepresentation(image2)).will.equal(UIImagePNGRepresentation(testImage));
        
        // will be available immediately
        UIImage *image3 = [imageCache imageForURL:mockURL];
        expect(image3).willNot.beNil();
        expect(UIImagePNGRepresentation(image3)).will.equal(UIImagePNGRepresentation(testImage));
    });
    
    it(@"returns nil if the image request fails", ^{
        
        UIImage *image = [imageCache imageForURL:mockURL];
        expect(image).to.beNil();
        
        [givenVoid([mockSession downloadTaskWithRequest:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(NSURL * location, NSURLResponse * response, NSError * error) = [invocation mkt_arguments][1];
            completionHandler(nil, nil, [NSError errorWithDomain:@"" code:1001 userInfo:nil]);
            return nil;
        }];
        
        
        __block UIImage *image2 = nil;
        [imageCache requestImageForURL:mockURL completionHandler:^(UIImage * _Nullable image) {
            image2 = image;
        }];
        
        expect(image2).will.beNil();
        
    });
    
    it(@"prefetches multiple images", ^{
        
        UIImage *image = [imageCache imageForURL:mockURL];
        expect(image).to.beNil();
        __block NSInteger tasks = 0;
        
        [givenVoid([mockSession downloadTaskWithRequest:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^completionHandler)(NSURL * location, NSURLResponse * response, NSError * error) = [invocation mkt_arguments][1];
            completionHandler([NSURL URLWithString:[NSString stringWithFormat:@"data:image/png;base64,%@", (tasks++ % 2) == 0 ? base64testImage : base64testImage2]], nil, nil);
            return nil;
        }];
        
        NSArray<NSURL *> *urls = @[mockURL, mockURL2];
        __block BOOL cached = NO;
        [imageCache prefechImagesForURLs:urls completionHandler:^{
            cached = YES;
        }];
        expect(cached).will.beTruthy();
        
        // will be available immediately
        UIImage *image1 = [imageCache imageForURL:mockURL];
        expect(image1).willNot.beNil();
        expect(UIImagePNGRepresentation(image1)).will.equal(UIImagePNGRepresentation(testImage));
        
        // will be available immediately
        UIImage *image2 = [imageCache imageForURL:mockURL2];
        expect(image2).willNot.beNil();
        expect(UIImagePNGRepresentation(image2)).will.equal(UIImagePNGRepresentation(testImage2));
        
    });
});

SpecEnd
