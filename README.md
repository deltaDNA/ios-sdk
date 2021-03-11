![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA Analytics iOS SDK

[![Build Status](https://travis-ci.org/deltaDNA/ios-sdk.svg?branch=master)](https://travis-ci.org/deltaDNA/ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Installation

#### XCFramework (Recommended, Xcode 11 or later)

The recommended way to install the SDK as of version 4.12.5 is to install using our XCFramework. This can be found on the Releases tab in the GitHub repository. 

* Download the archive from the version you want to install
* Extract it
* Drag the DeltaDNA.xcframework bundle out from the `builds/Framework/` folder into your Xcode project.
* When prompted, choose "Copy Files If Needed" and ensure that the checkbox by your target name is checked
* The framework should now be available to use

#### Framework (Recommended, Xcode 10 or earlier)

You can also include the individual frameworks from within the XCFramework, if you are using an older version of Xcode that doesn't support this format. The steps are as above, but drag the individual frameworks out of the main framework folder instead.

Note that when using individual frameworks, you will need both the iOS device and simulator frameworks provided in order to use the SDK in both environments.

#### Cocoapods

If you have an existing Cocoapods project you can also install the SDK using Cocoapods. A sample Podfile is listed below.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

target 'MyApp' do
# Uncomment this line if you're using Swift or would like to use dynamic frameworks
use_frameworks!

pod 'DeltaDNA', '~> 4.13.0'

target 'MyAppTests' do
inherit! :search_paths
# Pods for testing
end

end
```

The deltaDNA SDKs are available from our private spec repository, its url must be added as a source to your podfile.

### Usage

Include the SDK header files.

```objective-c
#include <DeltaDNA/DeltaDNA.h>
```

Start the analytics SDK.

```objective-c
[DDNASDK sharedInstance].clientVersion = @"1.0";

[[DDNASDK sharedInstance] startWithEnvironmentKey:@"YOUR_ENVIRONMENT_KEY"
collectURL:@"YOUR_COLLECT_URL"
engageURL:@"YOUR_ENGAGE_URL"];

```

On the first run it will create a new user id and send a `newPlayer` event.  On every call it will send a `gameStarted` and `clientDevice` event.

#### iOS 9 Support

Since iOS 9, all HTTP connections are forced to be HTTPS.  To allow HTTP to be used you need to add the following key to your Info.plist file.

```xml
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

### Example

The DeltaDNA Example project shows how to use our analytics platform within your game.  The iOS example shows how to call it from Objective-C, the tvOS example with Swift.

### Custom Events

You can easily record custom events by using the `DDNAEvent` class.  Create a `DDNAEvent` with the name of your event schema.  Call `setParam:forKey` to add event parameters.  For example:

```objective-c
DDNAEvent *event = [DDNAEvent eventWithName:@"keyTypes"];
[event setParam:@5 forKey:@"userLevel"];
[event setParam:@YES forKey:@"isTutorial"];
[event setParam:[NSDate date] forKey:@"exampleTimestamp"];

[[DDNASDK sharedInstance] recordEvent:event];
```

### Revenue Tracking

Revenue and IAP data should be tracked on the `transaction` event. This event contains nested objects that allow for the tracking of both virtual and real currency spending. As detailed in the [ISO 4217 standard](https://en.wikipedia.org/wiki/ISO_4217#Active_codes "ISO 4217 standard"), not all real currencies have 2 minor units and thus require conversion into a common form. The `DDNAProduct.ConvertCurrency()` method can be used to ensure the correct currency value is sent. 

For example, to track a purchase made with 550 JP¥: 

```objective-c
DDNAProduct *productsSpent = [DDNAProduct product];
[productsSpent setRealCurrencyType:@"JPY" amount: [DDNAProduct convertCurrencyCode:@"JPY" value: 550]] // realCurrencyAmount: 550
```

And to track a $4.99 purchase: 

```objective-c
DDNAProduct *productsSpent = [DDNAProduct product];
[productsSpent setRealCurrencyType:@"USD" amount: [DDNAProduct convertCurrencyCode:@"USD" value: 4.99]] // realCurrencyAmount: 499
```

These will be converted automatically into a `convertedProductAmount` parameter that is used as a common currency for reporting. 

Receipt validation can also be performed against purchases made via the Apple App Store. To validate in-app purchases made through the Apple App Store the following parameters should be added to the `transaction` event:

* `transactionServer` - the server for which the receipt should be validated against, in this case 'APPLE'
* `transactionReceipt` - the purchase data as a string not as nested JSON 
* `transactionID` - the ID of the in-app purchase e.g 100000576198248

When a `transaction` event is received with the above parameters, the receipt will be checked against the store and the resulting event will be tagged with a `revenueValidated` parameter to allow for the filtering out of invalid revenue.


### Event Triggers

All `recordEvent:` methods return a `DDNAEventAction` instance that accepts `DDNAEventActionHandler` callbacks via `addHandler:`.  If a corresponding event-triggered campaign has been setup, the handler that matches the trigger will be actioned as soon as `run` is called on the action.  The current supported actions are Game Parameters and Image Messages.  

```objective-c
DDNAEvent *event = [[DDNAEvent alloc] initWithName:@"matchStarted"];
[event setParam:@1 forKey:@"matchID"];
[event setParam:@"Blue Meadow" forKey:@"matchName"];
[event setParam:@10 forKey:@"userLevel"];

DDNAEventAction *eventAction = [[DDNASDK sharedInstance] recordEvent:event];

DDNAGameParametersHandler *gameParametersHandler = [[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *gameParameters) {
// do something with the game parameters
}];

[eventAction addHandler:gameParametersHandler];

DDNAImageMessageHandler *imageHandler = [[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAImageMessage *imageMessage){
// the image message is already prepared so show instantly
imageMessage.delegate = self;
[imageMessage showFromRootViewController:self];
}];

[eventAction addHandler:imageHandler];
[eventAction run];
```

In Addition to the above mechanism, default handlers can be specified. These will be used every time `run()` is called on an EventAction, after any handlers which have been registered via the `add` method.
These should be Specified before the SDK is started so they can be used to handle internal events such as `newPlayer` and `gameStarted` but they must be registered after the SDK is initialized. 
You can specify these handlers like so:
```objective-c

//Game Parameters Handler
[[DDNASDK sharedInstance].settings setDefaultGameParametersHandler:[[DDNAGameParametersHandler alloc] initWithHandler:^(NSDictionary *gameParameters){
// do something with game parameters here
}]];

//Image Message Handler
[[DDNASDK sharedInstance].settings setDefaultImageMessageHandler:[[DDNAImageMessageHandler alloc] initWithHandler:^(DDNAIMageMessage * imageMessage) {
imageMessage.delegate = self;
[imageMessage showFromRootViewController:self];
}]];


### Engage

Change the behaviour of the game with an engagement.  Create a `DDNAEngagement` with the name of your decision point.  Engage will respond with a dictionary of key values for your player.  Depending on how the Engage campaign has been built on the platform, the response will look something like:

```json
{
"parameters":{},
"image":{},
"heading":"An optional heading",
"message":"An optional message"
}
```

The `parameters` key is always present if the request to Engage was successful, but will be empty if no parameters were returned.  The image, heading and message are optional.  The game can look in the parameters to customise it's behaviour for the player.

For example:

```objective-c
DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"gameLoaded"];
[engagement setParam:@4 forKey:@"userLevel"];
[engagement setParam:@1000 forKey:@"experience"];
[engagement setParam:@"Disco Volante" forKey:@"missionName"];

[[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary* parameters, NSInteger statusCode, NSError* error) {
NSLog(@"Engagement request returned the following parameters:\n%@", parameters[@"parameters"]);
}];
```

If you're only interested in receiving game parameters from Engage, this can be simplified by using the `DDNAEngageFactory`:

```objective-c
DDNAParams *customParams = [[DDNAParams alloc] init];
[customParams setParam:@4 forKey:@"userLevel"];
[customParams setParam:@1000 forKey:@"experience"];
[customParams setParam:@"Disco Volante" forKey:@"missionName"];

[[DDNASDK sharedInstance].engageFactory requestGameParametersForDecisionPoint:@"gameLoaded" parameters:customParams handler:^(NSDictionary * gameParameters) {
NSLog(@"The following game parameters were returned:\n%@", gameParameters);
}];
```

#### Image Message

One of the actions Engage supports is an Image Message.  This displays a custom popup on the game screen.  To ask Engage for an image message use the `DDNAEngageFactory`:

```objective-c
[[DDNASDK sharedInstance].engageFactory requestImageMessageForDecisionPoint:@"imageMessage" handler:^(DDNAImageMessage * _Nullable imageMessage) {
if (imageMessage != nil) {
imageMessage.delegate = self;
[imageMessage fetchResources];
} else {
NSLog(@"Engage response did not contain an image message.");
}
}];
```

### Cross Promotion

To register a user for cross promotion between multiple games the user needs to sign into a service which can provide user identification. Once the user has been signed in the ID can be set in the SDK:
```objective-c
[[DDNASDK sharedInstance] setCrossGameUserId:crossGameUserId];
```
On the next session the SDK will download a new configuration with cross promotion campaigns relevant to the user.

When a cross promotion campaign with a store action has been acted on by the user, the SDK will return the store link for the iOS platform.

### Forget Me API

In order to help with GDPR compliance, calling `forgetMe` on the sdk sends an event to the platform indicating the user wishes their previously collected data to be deleted.  Once called the sdk will no longer record events and Engage requests will return empty responses.  No additional calls are required on the sdk since it will appear to work correctly from the caller's point of view.  The sdk can be reset by either calling `clearPersistantData` or starting with a new user id.


### Push Notifications
In order to enable receive notifications you will need to send the deviceToken received in the didRegisterForRemoteNotificationsWithDeviceToken method in your AppDelegate.m to deltaDNA
```objective-c
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // From iOS13 onward, setting the pushNotificationToken from the description property no longer works
    // Please update your app to set the deviceToken instead.
    [DDNASDK sharedInstance].deviceToken = deviceToken;
}
```

### Rich Push Notifications
To support rich push notifications for devices running iOS10 or greater you will need to include a Notification Service Extension in your project.  To do this within XCode you should select File -> New -> Target...  You will then be presented with a dialogue to "Choose a template for your new target".  Select the "Notification Service Extension" option and choose "Next".  You will need to provide a name (e.g. {YourAppName}NotificationExtension).  It is assumed for these instructions that you select Objective-C as your language.

Once you click finish you will find that 2 files have been added to your project; NotificationService.h and NotificationService.m.  All that remains is to modify these to use the default implementations provided by the DeltaDNA SDK.

For the NotificationService.h file change it as follows:

```objective-c
#import <DeltaDNA/DeltaDNA.h>

@interface NotificationService : DDNANotificationService

@end
```

For the NotificationService.m file change it as follows:

```objective-c
#import "NotificationService.h"

@implementation NotificationService

@end
```

### Further Integration

Refer to our [documentation](http://docs.deltadna.com/advanced-integration/ios-sdk/) site for more details on how to use the SDK.

## License

The sources are available under the Apache 2.0 license.

## Contact Us

For more information, please visit [deltadna.com](https://deltadna.com/). For questions or assistance, please email us at [support@deltadna.com](mailto:support@deltadna.com).

