![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA Analytics iOS SDK

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies using 3rd party libraries.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNA', '~> 4.0'
```

The deltaDNA SDKs are available from our private spec repository, its url must be added as a source to your podfile.  

### Installation as a Framework

Open DeltaDNA.xcworkspace.  The DeltaDNA project contains targets to build iOS and tvOS frameworks.  Once built, drag the framework into your project.  The example project shows how to do this in XCode.

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

### Engage

Change the behaviour of the game with an engagement.  Create a `DDNAEngagement` with the name of your decision point.  Engage will respond with a dictionary of key values for your player.  For example:

```objective-c
DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"gameLoaded"];
[engagement setParam:@4 forKey:@"userLevel"];
[engagement setParam:@1000 forKey:@"experience"];
[engagement setParam:@"Disco Volante" forKey:@"missionName"];

[[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary* parameters, NSInteger statusCode, NSError* error) {
    NSLog(@"Engagement request returned the following parameters:\n%@", parameters);
}];
```

### Further Integration

Refer to our [documentation](http://docs.deltadna.com/advanced-integration/ios-sdk/) site for more details how to use the SDK.

## License

The sources are available under the Apache 2.0 license.
