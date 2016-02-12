//
//  ViewController.h
//  DeltaDNA iOS Example
//
//  Created by David White on 17/11/2015.
//  Copyright © 2015 deltaDNA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *labelSDK;

- (IBAction)basicEvent:(id)sender;
- (IBAction)customEvent:(id)sender;
- (IBAction)achievementEvent:(id)sender;
- (IBAction)transactionEvent:(id)sender;
- (IBAction)engage:(id)sender;
- (IBAction)imageMessage:(id)sender;
- (IBAction)pushNotification:(id)sender;
- (IBAction)uploadEvents:(id)sender;
- (IBAction)startSDK:(id)sender;
- (IBAction)stopSDK:(id)sender;
- (IBAction)newSession:(id)sender;

@end

