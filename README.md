SmartAds from deltaDNA.

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplfies using 3rd party libraries.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNA', '~> 4.0'
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

Refer to our main [documentation](http://docs.deltadna.com/advanced-integration/ios-sdk/) site for more details how to use the SDK.