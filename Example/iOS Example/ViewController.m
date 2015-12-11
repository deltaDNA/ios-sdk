//
//  ViewController.m
//  DeltaDNA iOS Example
//
//  Created by David White on 17/11/2015.
//  Copyright © 2015 deltaDNA. All rights reserved.
//

#import "ViewController.h"
@import DeltaDNA;

@interface ViewController ()

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
    
    // Configure additional behaviour.
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


- (IBAction)simpleEvent:(id)sender {
    // Send an Achievement event
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    DDNAEventBuilder * achievementParams = [DDNAEventBuilder new];
    [achievementParams setString:@"Sunday Showdown Tournament Win" forKey:@"achievementName"];
    [achievementParams setString:@"SS-2014-03-02-01" forKey:@"achievementID"];
    
    DDNAProductBuilder * achievementProductParams = [DDNAProductBuilder new];
    [achievementProductParams setRealCurrency:@"USD" withAmount:5000 ];
    [achievementProductParams addVirtualCurrency:@"GRIND" withAmount:20 andName:@"VIP Points"];
    [achievementProductParams addItem:@"Victory Badge" withAmount:1 andName:@"Sunday Showdown Medal"];
    
    DDNAEventBuilder * achievementRewardParams = [DDNAEventBuilder new];
    [achievementRewardParams setProductBuilder:achievementProductParams forKey:@"rewardProducts"];
    [achievementRewardParams setString:@"Medal" forKey:@"rewardName"];
    [achievementParams setEventBuilder:achievementRewardParams forKey:@"reward"];
    
    [sdk recordEvent:@"achievement" withEventBuilder:achievementParams];
}

- (IBAction)complexEvent:(id)sender {
    // Send a Transaction Event.
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    DDNAEventBuilder * transactionParams = [DDNAEventBuilder new];
    [transactionParams setString:@"Weapon type 11 manual repair" forKey:@"transactionName"];
    [transactionParams setString:@"47891208312996456524019-178.149.115.237:51787" forKey:@"transactionID"];
    [transactionParams setString:@"62.212.91.84:15116" forKey:@"transactorID"];
    [transactionParams setString:@"4019" forKey:@"productID"];
    [transactionParams setString:@"PURCHASE" forKey:@"transactionType"];
    [transactionParams setString:@"GB" forKey:@"paymentCountry"];
    
    DDNAProductBuilder * productsReceivedParams = [DDNAProductBuilder new];
    [productsReceivedParams addItem:@"WeaponMaxConditionRepair" withAmount:5 andName:@"WeaponMaxCondition:11"];
    [transactionParams setProductBuilder:productsReceivedParams forKey:@"productsReceived"];
    
    DDNAProductBuilder * productsSpentParams = [DDNAProductBuilder new];
    [productsReceivedParams addVirtualCurrency:@"GRIND" withAmount:710 andName:@"Credit"];
    [transactionParams setProductBuilder:productsSpentParams forKey:@"productsSpent"];
    
    [sdk recordEvent:@"transaction" withEventBuilder:transactionParams];
}

- (IBAction)customEvent:(id)sender {
    // Send a KeyTypes event.
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    DDNAEventBuilder * keyTypesParams = [DDNAEventBuilder new];
    [keyTypesParams setInteger:5 forKey:@"userLevel"];
    [keyTypesParams setBoolean:YES forKey:@"isTutorial"];
    [keyTypesParams setTimestamp:[NSDate date] forKey:@"exampleTimestamp"];
    
    [sdk recordEvent:@"keyTypes" withEventBuilder:keyTypesParams];
}

- (IBAction)transactionHelper:(id)sender {
    // Try out the Transaction helper
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    [sdk buyVirtualCurrency:@"PREMIUM_GRIND"
            receivingAmount:5
                   withName:@"Gold"
          usingRealCurrency:@"USD"
             spendingAmount:1000
        withTransactionName:@"Buy Gold Coins"
     //andTransactionReceipt:@"12567335-DFEWFG-sdfgr-343"];
      andTransactionReceipt:nil];
}

- (IBAction)engage:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    NSMutableDictionary * engageParams = [NSMutableDictionary dictionary];
    [engageParams setObject:[NSNumber numberWithInt:4] forKey:@"userLevel"];
    [engageParams setObject:[NSNumber numberWithInt:1000] forKey:@"experience"];
    [engageParams setObject:@"Disco Volante" forKey:@"missionName"];
    
    [sdk requestEngagement:@"gameLoaded"
          withEngageParams:engageParams
             callbackBlock:^(NSDictionary * response) {
                 NSLog(@"Engage returned '%@'.",
                       [NSString stringWithContentsOfDictionary:response]);
             } ];
}

- (IBAction)imageMessage:(id)sender {
    DDNASDK * sdk = [DDNASDK sharedInstance];
    
    NSMutableDictionary * engageParams = [NSMutableDictionary dictionary];
    
    DDNABasicPopup* popup = [DDNABasicPopup popup];
    __weak DDNABasicPopup* weakPopup = popup;
    popup.afterPrepare = ^{
        [weakPopup show];
    };
    
    popup.dismiss = ^(NSString *name){
        NSLog(@"Dismiss by %@", name);
    };
    
    popup.onAction = ^(NSString *name, NSString *type, NSString *value){
        NSLog(@"OnAction by %@ type %@ value %@", name, type, value);
    };
    
    [sdk requestImageMessage:@"imageMessage"
            withEngageParams:engageParams
                  imagePopup:popup
               callbackBlock:^(NSDictionary * response) {
                   NSLog(@"Engage returned '%@'.",
                         [NSString stringWithContentsOfDictionary:response]);
               } ];
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


@end
