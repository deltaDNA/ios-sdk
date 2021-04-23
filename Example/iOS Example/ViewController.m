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

#import "ViewController.h"
@import DeltaDNA;

@interface SdkConfig: NSObject
@property (nonatomic, copy, readonly) NSString *environmentKey;
@property (nonatomic, copy, readonly) NSString *collectUrl;
@property (nonatomic, copy, readonly) NSString *engageUrl;
@end

@implementation SdkConfig

+ (NSString *)environmentKey {
    if ([[NSProcessInfo processInfo] environment][@"ENVIRONMENT_KEY"]) {
        return [[NSProcessInfo processInfo] environment][@"ENVIRONMENT_KEY"];
    }
    return @"55822530117170763508653519413932";
}

+ (NSString *)collectUrl {
    if ([[NSProcessInfo processInfo] environment][@"COLLECT_URL"]) {
        return [[NSProcessInfo processInfo] environment][@"COLLECT_URL"];
    }
    return @"https://collect2010stst.deltadna.net/collect/api";
}

+ (NSString *)engageUrl {
    if ([[NSProcessInfo processInfo] environment][@"ENGAGE_URL"]) {
        return [[NSProcessInfo processInfo] environment][@"ENGAGE_URL"];
    }
    return @"https://engage2010stst.deltadna.net";
}

@end

@interface ViewController () <DDNASDKDelegate, DDNAImageMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.labelSDK.text = DDNA_SDK_VERSION;
    
    // Test DD SDK
    
    // Set a logging level (default warning)
    [DDNASDK setLogLevel:DDNALogLevelDebug];
    
    // Grab a handle to the singleton.
    DDNASDK *sdk = [DDNASDK sharedInstance];
    sdk.delegate = self;
    
    //[sdk clearPersistentData];
    
    // Optionally configure additional behaviour.
    //sdk.settings.backgroundEventUploadStartDelaySeconds = 10;
    //sdk.settings.backgroundEventUploadRepeatRateSeconds = 15;
    //sdk.settings.httpRequestTimeoutSeconds = 1;
    //sdk.settings.onFirstRunSendNewPlayerEvent = NO;
    //sdk.settings.onStartSendClientDeviceEvent = NO;
    //sdk.settings.onStartSendGameStartedEvent = NO;
    
    // Set client external information.
    sdk.clientVersion = @"1.0";
    
    // Enable event hashing.
    sdk.hashSecret = @"KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw";
    
    // Start the SDK.
    [sdk startWithEnvironmentKey:[SdkConfig environmentKey]
                      collectURL:[SdkConfig collectUrl]
                       engageURL:[SdkConfig engageUrl]];
    
    // Default behaviour will automatically send 'newPlayer' if a new user id is used
    // and will send 'clientInfo' and 'gameStarted'.
    sdk.appStoreId = @"1234567890";
    sdk.appleDeveloperId = @"test@example.com";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)basicEvent:(id)sender {
    [[DDNASDK sharedInstance] recordEvent:[DDNAEvent eventWithName:@"basicEvent"]];
}

- (IBAction)customEvent:(id)sender {
    DDNAEvent *event = [DDNAEvent eventWithName:@"keyTypes"];
    [event setParam:@5 forKey:@"userLevel"];
    [event setParam:@YES forKey:@"isTutorial"];
    [event setParam:[NSDate date] forKey:@"exampleTimestamp"];
    
    [[DDNASDK sharedInstance] recordEvent:event];
}

- (IBAction)achievementEvent:(id)sender {
    DDNAProduct *product = [DDNAProduct product];
    [product setRealCurrencyType:@"USD" amount:[DDNAProduct convertCurrencyCode:@"USD" value:[NSDecimalNumber decimalNumberWithString:@"4.99"]]]; // 4.99 USD
    [product addVirtualCurrencyName:@"VIP Points" type:@"GRIND" amount:20];
    [product addItemName:@"Sunday Showdown Medal" type:@"Victory Badge" amount:1];
    
    DDNAParams *reward = [DDNAParams params];
    [reward setParam:@"Medal" forKey:@"rewardName"];
    [reward setParam:product forKey:@"rewardProducts"];
    
    DDNAEvent *event = [DDNAEvent eventWithName:@"achievement"];
    [event setParam:@"Sunday Showdown Tournament Win" forKey:@"achievementName"];
    [event setParam:@"SS-2014-03-02-01" forKey:@"achievementID"];
    [event setParam:reward forKey:@"reward"];
    
    [[DDNASDK sharedInstance] recordEvent:event];
}

- (IBAction)transactionEvent:(id)sender {
    DDNAProduct *productsReceived = [DDNAProduct product];
    [productsReceived addItemName:@"WeaponMaxCondition:11" type:@"WeaponMaxConditionRepair" amount:5];
    
    DDNAProduct *productsSpent = [DDNAProduct product];
    [productsSpent addVirtualCurrencyName:@"Credit" type:@"GRIND" amount:710];
    
    DDNATransaction *event = [DDNATransaction transactionWithName:@"Weapon type 11 manual repair" type:@"PURCHASE" productsReceived:productsReceived productsSpent:productsSpent];
    [event setTransactionId:@"47891208312996456524019-178.149.115.237:51787"];
    [event setTransactorId:@"62.212.91.84:15116"];
    [event setProductId:@"4019"];
    [event setParam:@"GB" forKey:@"paymentCountry"];
    
    [[DDNASDK sharedInstance] recordEvent:event];
}

- (IBAction)eventTrigger:(id)sender
{
    DDNAEvent *event = [[DDNAEvent alloc] initWithName:@"matchStarted"];
    [event setParam:@"1" forKey:@"matchID"];
    [event setParam:@"Blue Meadow" forKey:@"matchName"];
    [event setParam:@10 forKey:@"userLevel"];

    DDNAEventAction *eventAction = [[DDNASDK sharedInstance] recordEvent:event];
    
    DDNAGameParametersHandler *gameParametersHandler = [[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *gameParameters) {
        // do something with the game parameters
        NSLog(@"The following game parameters were returned:\n%@", gameParameters);
    }];
    
    [eventAction addHandler:gameParametersHandler];
    
    DDNAImageMessageHandler *imageHandler = [[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAImageMessage *imageMessage){
        // the image message is already prepared so show instantly
        imageMessage.delegate = self;
        [imageMessage showFromRootViewController:self];
    }];
    
    [eventAction addHandler:imageHandler];
    [eventAction run];
}

- (IBAction)engage:(id)sender
{
    DDNAParams *customParams = [[DDNAParams alloc] init];
    [customParams setParam:@4 forKey:@"userLevel"];
    [customParams setParam:@1000 forKey:@"experience"];
    [customParams setParam:@"Disco Volante" forKey:@"missionName"];
    
    [[DDNASDK sharedInstance].engageFactory requestGameParametersForDecisionPoint:@"gameLoaded" parameters:customParams handler:^(NSDictionary * gameParameters) {
        NSLog(@"The following game parameters were returned:\n%@", gameParameters);
    }];
}

- (IBAction)imageMessage:(id)sender
{
    [[DDNASDK sharedInstance].engageFactory requestImageMessageForDecisionPoint:@"imageMessage" handler:^(DDNAImageMessage * _Nullable imageMessage) {
        if (imageMessage != nil) {
            imageMessage.delegate = self;
            [imageMessage fetchResources];
        } else {
            NSLog(@"Engage response did not contain an image message.");
        }
    }];
}

- (IBAction)uploadEvents:(id)sender {
    [[DDNASDK sharedInstance] upload];
}

- (IBAction)startSDK:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    [sdk startWithEnvironmentKey:[SdkConfig environmentKey]
                      collectURL:[SdkConfig collectUrl]
                       engageURL:[SdkConfig engageUrl]];
    sdk.appStoreId = @"1234567890";
    sdk.appleDeveloperId = @"test@example.com";
}

- (IBAction)stopSDK:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    if (sdk.hasStarted) {
        [sdk stop];
    }
}

- (IBAction)newSession:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    [sdk newSession];
}

- (IBAction)forgetMe:(id)sender {
    [[DDNASDK sharedInstance] forgetMe];
}

- (IBAction)newUser:(id)sender {
    [[DDNASDK sharedInstance] clearPersistentData];
}

- (IBAction)setCrossGameUserId:(id)sender {
    NSString* crossId = [self.crossGameUserId text];
    [[DDNASDK sharedInstance] setCrossGameUserId:crossId];
}

- (IBAction)sendPinpointerEvents:(id)sender {
    [[DDNASDK sharedInstance] recordSignalTrackingSessionEvent];
    [[DDNASDK sharedInstance] recordSignalTrackingInstallEvent];
    [[DDNASDK sharedInstance] recordSignalTrackingPurchaseEventWithRealCurrencyAmount :@100 realCurrencyType:@"GBP" transactionID:@"mySuperAwesomeTransactionID" transactionReceipt:@"someReceiptData"];
    NSLog(@"Uploaded Pinpointer Signal Events");
}

#pragma mark - DDNASDKDelegate

- (void)didStartSdk
{
    NSLog(@"deltaDNA started.");
}

- (void)didStopSdk
{
    NSLog(@"deltaDNA stopped.");
}

- (void)didConfigureSessionWithCache:(BOOL)cache
{
    NSLog(@"Session configuration completed.");
}

- (void)didFailToConfigureSessionWithError:(NSError *)error
{
    NSLog(@"Failed to fetch session configuration.");
}

- (void)didPopulateImageMessageCache
{
    NSLog(@"Populated image message cache.");
}

- (void)didFailToPopulateImageMessageCacheWithError:(NSError *)error
{
    NSLog(@"Failed to populate image message cache.");
}

#pragma mark - ImageMessageDelegate

- (void)didReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage
{
    [imageMessage showFromRootViewController:self];
}

- (void)didFailToReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage withReason:(NSString *)reason
{
    NSLog(@"Failed to download resources for the image message: %@", reason);
}

- (void)onDismissImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name
{
    NSLog(@"ImageMessage dismissed by %@", name);
}

- (void)onActionImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name type:(NSString *)type value:(NSString *)value
{
    NSLog(@"ImageMessage action from %@ with type %@ value %@", name, type, value);
}


@end
