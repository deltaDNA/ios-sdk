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

#import "DDNAImageMessage.h"
#import "DDNAEngagement.h"
#import "DDNASDK.h"
#import "DDNASettings.h"
#import "DDNACache.h"
#import "NSString+DeltaDNA.h"

@interface DDNAImageMessage ()

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, assign) BOOL resourcesDownloaded;
@property (nonatomic, strong) UIImage *spriteMap;
@property (nonatomic, strong) UIView *shimView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSDictionary *shimAction;
@property (nonatomic, strong) NSDictionary *backgroundAction;
@property (nonatomic, strong) NSArray *buttonActions;
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, assign) BOOL isShowing;

@end

BOOL validConfiguration(NSDictionary *configuration)
{
    if (![configuration.allKeys containsObject:@"url"] ||
        ![configuration.allKeys containsObject:@"height"] ||
        ![configuration.allKeys containsObject:@"width"] ||
        ![configuration.allKeys containsObject:@"spritemap"] ||
        ![configuration.allKeys containsObject:@"layout"]) return NO;
    
    NSDictionary *layout = configuration[@"layout"];
    if (![layout.allKeys containsObject:@"landscape"] && ![layout.allKeys containsObject:@"portrait"]) return NO;
    
    NSDictionary *spritemap = configuration[@"spritemap"];
    if (![spritemap.allKeys containsObject:@"background"]) return NO;
    
    return YES;
}


@implementation DDNAImageMessage

+ (instancetype)imageMessageWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNAImageMessageDelegate>)delegate
{
    DDNAImageMessage *imageMessage = [[DDNAImageMessage alloc] initWithEngagement:engagement];
    if (imageMessage != nil) {
        imageMessage.delegate = delegate;
    }
    return imageMessage;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithEngagement:(DDNAEngagement *)engagement
{
    return [self initWithFrame:[[UIScreen mainScreen] bounds] engagement:engagement];
}

- (instancetype)initWithFrame:(CGRect)frame engagement:(DDNAEngagement *)engagement
{
    if (engagement == nil ||
        engagement.json == nil ||
        engagement.json[@"image"] == nil ||
        !validConfiguration(engagement.json[@"image"])) {
        return nil;
    }

    if ((self = [super initWithFrame:frame])) {
        self.configuration = [NSDictionary dictionaryWithDictionary:engagement.json[@"image"]];
        self.parameters = engagement.json[@"parameters"] != nil ? [NSDictionary dictionaryWithDictionary:engagement.json[@"parameters"]] : [NSDictionary dictionary];
        self.dimmedMaskAlpha = 0.5f;
        self.backgroundScale = 1.0f;
        self.shimView = [[UIView alloc] init];
        self.backgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void)fetchResources
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        if (self.configuration[@"url"]) {

            NSURL *url = [NSURL URLWithString:self.configuration[@"url"]];
            NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[DDNASDK sharedInstance].settings.httpRequestEngageTimeoutSeconds];

            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            
            [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                if (data == nil) {
                    // try and load from cache
                    data = [[DDNACache sharedCache] objectForKey:self.configuration[@"url"]];
                }

                if (data != nil) {
                    [[DDNACache sharedCache] setObject:data forKey:self.configuration[@"url"]];
                    self.spriteMap = [UIImage imageWithData:data];
                    self.resourcesDownloaded = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate didReceiveResourcesForImageMessage:self];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *reason = error == nil ? @"Failed to download" : error.localizedDescription;
                        [self.delegate didFailToReceiveResourcesForImageMessage:self withReason:reason];
                    });
                }
            }] resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFailToReceiveResourcesForImageMessage:self withReason:@"Invalid configuration, missing \"url\" key"];
            });
        }
    });
}

- (BOOL)isReady
{
    return self.resourcesDownloaded;
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    NSLog(@"Show image message");
        
    self.hidden = NO;
    self.alpha = 1.0;
    
    UIImage* backgroundImage;
    NSMutableArray* buttonImages = [[NSMutableArray alloc] init];
    
    // sprite map
    
    if (self.configuration[@"spritemap"]) {
        NSDictionary* spritemap = self.configuration[@"spritemap"];
        
        if (spritemap[@"background"]) {
            NSDictionary* bg = spritemap[@"background"];
            CGRect cropRect = CGRectMake(
                                         [bg[@"x"] integerValue],
                                         [bg[@"y"] integerValue],
                                         [bg[@"width"] integerValue],
                                         [bg[@"height"] integerValue]);
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([_spriteMap CGImage], cropRect);
            
            backgroundImage = [UIImage imageWithCGImage:imageRef];
        }
        
        if (spritemap[@"buttons"]) {
            NSArray* btns = spritemap[@"buttons"];
            for (NSDictionary *btn in btns) {
                CGRect cropRect = CGRectMake(
                                             [btn[@"x"] integerValue],
                                             [btn[@"y"] integerValue],
                                             [btn[@"width"] integerValue],
                                             [btn[@"height"] integerValue]);
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([_spriteMap CGImage], cropRect);
                UIImage* buttonImage = [UIImage imageWithCGImage:imageRef];
                
                [buttonImages addObject:buttonImage];
            }
        }
        
    }
    
    // shim
    
    if (self.configuration[@"shim"]) {
        NSDictionary* shim = self.configuration[@"shim"];
        if (shim[@"mask"]) {
            NSString* mask = shim[@"mask"];
            if ([mask isEqualToStringCaseInsensitive:@"dimmed"]) {
                _shimView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:_dimmedMaskAlpha];
            } else if ([mask isEqualToStringCaseInsensitive:@"clear"]) {
                _shimView.backgroundColor = [UIColor clearColor];
            }
            if (![mask isEqualToStringCaseInsensitive:@"none"]) {
                _shimView.userInteractionEnabled = YES;
                _shimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _shimView.frame = self.bounds;
                
                [self addSubview:_shimView];
            }
        }
        if (shim[@"action"]) {
            _shimAction = [NSDictionary dictionaryWithDictionary:shim[@"action"]];
        }
    }
    
    // background
    
    if (self.configuration[@"layout"]) {
        NSDictionary* layout = self.configuration[@"layout"];
        
        BOOL landscape = YES;
#ifndef TARGET_OS_TV
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        landscape = (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight);
#endif
        
        NSDictionary * orientationDict = nil;
        if (layout[@"landscape"] && landscape) {
            orientationDict = layout[@"landscape"];
        } else if (layout[@"portrait"] && !landscape) {
            orientationDict = layout[@"portrait"];
        } else if (layout[@"landscape"]) {
            orientationDict = layout[@"landscape"];
        } else if (layout[@"portrait"]) {
            orientationDict = layout[@"portrait"];
        }
        
        if (orientationDict != nil) {
            
            if (orientationDict[@"background"]) {
                NSDictionary* background = orientationDict[@"background"];
                CGRect dim;
                if (background[@"cover"]) {
                    dim = [self renderAsCoverWithConstraints:background[@"cover"] andImage:backgroundImage];
                }
                else if (background[@"contain"]) {
                    dim = [self renderAsContainWithConstraints:background[@"contain"] andImage:backgroundImage];
                }
                
                _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];  // build the background before defining constraints on it
                _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
                _backgroundView.autoresizesSubviews = NO;
                _backgroundView.userInteractionEnabled = YES;
                
                NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:dim.origin.x];
                NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:dim.origin.y];
                NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:dim.size.width];
                NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:dim.size.height];
                
                
                [self addSubview:_backgroundView];  // must do this before adding constraints
                
                [self addConstraint:leftConstraint];
                [self addConstraint:topConstraint];
                [_backgroundView addConstraint:widthConstraint];
                [_backgroundView addConstraint:heightConstraint];
                
                if (background[@"action"]) {
                    _backgroundAction = [NSDictionary dictionaryWithDictionary:background[@"action"]];
                }
            }
            
            if (orientationDict[@"buttons"]) {
                NSArray* buttons = orientationDict[@"buttons"];
                
                NSMutableArray* buttonActions = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [buttons count]; ++i) {
                    
                    UIImage* btnImage = buttonImages[i];
                    NSDictionary* btnDict = buttons[i];
                    
                    CGRect dim = CGRectMake([btnDict[@"x"] integerValue] * _backgroundScale,
                                            [btnDict[@"y"] integerValue] * _backgroundScale,
                                            btnImage.size.width * _backgroundScale,
                                            btnImage.size.height * _backgroundScale);
                    
                    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.translatesAutoresizingMaskIntoConstraints = NO;
                    btn.contentEdgeInsets = UIEdgeInsetsZero;
                    [btn setBackgroundImage:buttonImages[i] forState:UIControlStateNormal];
                    [btn setTag:i+1];   // help identify the button when clicked
#ifdef TARGET_OS_TV
                    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventPrimaryActionTriggered];
#else
                    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
#endif
                    
                    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:dim.origin.x];
                    NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeTop multiplier:1.0f constant:dim.origin.y];
                    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:dim.size.width];
                    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:dim.size.height];
                    
                    [_backgroundView addSubview:btn];
                    [_backgroundView addConstraint:leftConstraint];
                    [_backgroundView addConstraint:topConstraint];
                    [btn addConstraint:widthConstraint];
                    [btn addConstraint:heightConstraint];
                    
                    // action
                    if (btnDict[@"action"]) {
                        [buttonActions addObject:btnDict[@"action"]];
                    }
                }
                
                _buttonActions = [NSArray arrayWithArray:buttonActions];
            }
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController.view addSubview:self];
        self.isShowing = YES;
    });
}


- (void)close
{
    if (self.isShowing) {
        [self removeFromSuperview];
        self.isShowing = NO;
    }
}


#pragma mark - Private Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView* viewYouWishToObtain = [self hitTest:locationPoint withEvent:event];
    
    if (viewYouWishToObtain == _shimView) {
        [self actionHandlerFor:@"shim" withAction:_shimAction];
    }
    
    if (viewYouWishToObtain == _backgroundView) {
        [self actionHandlerFor:@"background" withAction:_backgroundAction];
    }
}

- (CGRect)renderAsCoverWithConstraints: (NSDictionary*)constraints andImage: (UIImage *)image
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    float scale = MAX(screenWidth / image.size.width, screenHeight / image.size.height);
    float width = image.size.width * scale;
    float height = image.size.height * scale;
    
    float top = screenHeight / 2.0f - height / 2.0f;    // default center
    float left = screenWidth / 2.0f - width / 2.0f;
    
    if (constraints[@"valign"]) {
        NSString * valign = constraints[@"valign"];
        if ([valign isEqualToStringCaseInsensitive:@"top"]) {
            top = 0;
        }
        else if ([valign isEqualToStringCaseInsensitive:@"bottom"]) {
            top = screenHeight - height;
        }
    }
    
    if (constraints[@"halign"]) {
        NSString * halign = constraints[@"halign"];
        if ([halign isEqualToStringCaseInsensitive:@"left"]) {
            left = 0;
        }
        else if ([halign isEqualToStringCaseInsensitive:@"right"]) {
            left = screenWidth - width;
        }
    }
    
    _backgroundScale = scale;
    
    return CGRectMake(left, top, width, height);
}

- (CGRect)renderAsContainWithConstraints: (NSDictionary *)constraints andImage: (UIImage *)image
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    float lc = 0, rc = 0, tc = 0, bc = 0;
    if (constraints[@"left"]) {
        lc = [self readConstraintPixels:constraints[@"left"] screenEdge:screenWidth];
    }
    
    if (constraints[@"right"]) {
        rc = [self readConstraintPixels:constraints[@"right"] screenEdge:screenWidth];
    }
    
    if (constraints[@"top"]) {
        tc = [self readConstraintPixels:constraints[@"top"] screenEdge:screenHeight];
    }
    
    if (constraints[@"bottom"]) {
        bc = [self readConstraintPixels:constraints[@"bottom"] screenEdge:screenHeight];
    }
    
    float ws = (screenWidth - lc - rc) / image.size.width;
    float hs = (screenHeight - tc - bc) / image.size.height;
    float scale = MIN(ws, hs);
    float height = image.size.height * scale;
    float width = image.size.width * scale;
    
    float top = ((screenHeight - tc - bc) / 2.0f - height / 2.0f) + tc; // default "center"
    float left = ((screenWidth - lc - rc) / 2.0f - width / 2.0f) + lc;
    
    if (constraints[@"valign"]) {
        NSString * valign = constraints[@"valign"];
        if ([valign isEqualToStringCaseInsensitive:@"top"]) {
            top = tc;
        }
        else if ([valign isEqualToStringCaseInsensitive:@"bottom"]) {
            top = screenHeight - height - bc;
        }
    }
    
    if (constraints[@"halign"]) {
        NSString * halign = constraints[@"halign"];
        if ([halign isEqualToStringCaseInsensitive:@"left"]) {
            left = lc;
        }
        else if ([halign isEqualToStringCaseInsensitive:@"right"]) {
            left = screenWidth - width - rc;
        }
    }
    
    _backgroundScale = scale;
    
    return CGRectMake(left, top, width, height);
}

- (CGFloat)readConstraintPixels: (NSString *)constraint screenEdge: (CGFloat)screenEdge
{
    CGFloat result = 0;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)(px|%)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regex matchesInString:constraint options:0 range:NSMakeRange(0, [constraint length])];
    
    if ([matches count] > 0) {
        NSTextCheckingResult *match = matches[0];
        NSRange matchValueRange = [match rangeAtIndex:1];
        NSRange matchTypeRange = [match rangeAtIndex:2];
        
        NSString *matchValueString = [constraint substringWithRange:matchValueRange];
        result = matchValueString.intValue;
        
        NSString *matchTypeString = [constraint substringWithRange:matchTypeRange];
        if ([matchTypeString isEqualToString:@"%"]) {
            result = result / 100.0f * screenEdge;
        }
    }
    
    return result;
}

- (void)buttonPressed:(UIButton*)sender
{
    NSString* name = [NSString stringWithFormat:@"button%ld", (long)sender.tag];
    [self actionHandlerFor:name withAction:_buttonActions[sender.tag-1]];
}

- (void)actionHandlerFor:(NSString*)name withAction: (NSDictionary*)action
{
    NSString* type = action[@"type"];
    NSString* value = action[@"value"];
    
    if ([type isEqualToStringCaseInsensitive:@"none"]) {
        return; // do nothing
    }
    else if ([type isEqualToStringCaseInsensitive:@"action"]) {
        if (value != nil) {
            [self.delegate onActionImageMessage:self name:name type:type value:value];
        }
    }
    else if ([type isEqualToStringCaseInsensitive:@"link"]) {
        if (value != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:value]];
        }
        [self.delegate onActionImageMessage:self name:name type:type value:value];
    }
    else if ([type isEqualToStringCaseInsensitive:@"dismiss"]) {
        [self.delegate onDismissImageMessage:self name:name];
    }
    
    [self close];
}

@end
