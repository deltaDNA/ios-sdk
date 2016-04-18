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

@interface ViewController () <DDNAImageMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.labelSDK.text = DDNA_SDK_VERSION;
    
    // Test DD SDK
    
    // Grab a handle to the singleton.
    DDNASDK *sdk = [DDNASDK sharedInstance];
    
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
    [sdk startWithEnvironmentKey:@"55822530117170763508653519413932"
                      collectURL:@"http://collect2010stst.deltadna.net/collect/api"
                       engageURL:@"http://engage2010stst.deltadna.net"];
    
    // Default behaviour will automatically send 'newPlayer' if a new user id is used
    // and will send 'clientInfo' and 'gameStarted'.

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
    [product setRealCurrencyType:@"USD" amount:5000];
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

- (IBAction)engage:(id)sender {
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"gameLoaded"];
    [engagement setParam:@4 forKey:@"userLevel"];
    [engagement setParam:@1000 forKey:@"experience"];
    [engagement setParam:@"Disco Volante" forKey:@"missionName"];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        if (response.json) {
            NSLog(@"Engagement request returned the following parameters:\n%@", response.json[@"parameters"]);
        } else {
            NSLog(@"Engagement failed: %@", response.error);
        }
    }];
    
}

- (IBAction)imageMessage:(id)sender {

    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"imageMessage"];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        
        DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:response delegate:self];
        if (imageMessage != nil) {
          // Engagement contained a valid image message response!
            [imageMessage fetchResources];
        }
        else {
            NSLog(@"Engage response did not contain an image message.");
        }
    }];
    
}

- (IBAction)pushNotification:(id)sender {
    NSDictionary *apnsPayload = @{
        @"aps": @{
            @"alert": @"Play now to collect your reward"
        },
        @"_ddName": @"NotificationName",
        @"_ddId": @"42"
    };
    
    [[DDNASDK sharedInstance] recordPushNotification:apnsPayload didLaunch:YES];
}

- (IBAction)uploadEvents:(id)sender {
    [[DDNASDK sharedInstance] upload];
}

- (IBAction)startSDK:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    [sdk startWithEnvironmentKey:@"55822530117170763508653519413932"
                      collectURL:@"http://collect2010stst.deltadna.net/collect/api"
                       engageURL:@"http://engage2010stst.deltadna.net"];
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
