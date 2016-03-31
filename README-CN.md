![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA分析iOS SDK

### 使用CocoaPods安装

[CocoaPods](https://cocoapods.org/)是一个独立的Objective-C管理器，可以非常简便的自动使用第三方库。

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNA', '~> 4.0'
```

deltaDNA的SDK可以直接从我们的私有项目库中找到，其URL必须作为一个源路径添加到你的Podfile。

### 作为一个框架安装

打开DeltaDNA.xcworkspace。这个DeltaDNA的项目包括创建iOS和tvOS框架的所有对象。创建以后，将这个框架拖拽到你的项目中。案例项目展示了如何在XCode中做到这一点。

### 用法

将SDK的头文件包括进来。

```objective-c
#include <DeltaDNA/DeltaDNA.h>
```

启用分析SDK。

```objective-c
[DDNASDK sharedInstance].clientVersion = @"1.0";

[[DDNASDK sharedInstance] startWithEnvironmentKey:@"YOUR_ENVIRONMENT_KEY"
                                       collectURL:@"YOUR_COLLECT_URL"
                                        engageURL:@"YOUR_ENGAGE_URL"];

```

第一次运行时，这将创建新用户的id并发送一个`newPlayer`事件。每次调用时，它将发送一个`gameStarted`和`clientDevice`事件。

#### iOS 9支持

从iOS 9起，所有的HTTP连接都被迫改为HTTPS。为了允许HTTP使用，你需要将下述的键添加到你的Info.plist文件。

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 案例

这个DeltaDNA案例项目展示了如何在你的游戏中使用我们的分析平台。这个iOS的案例展示了如何从Objective-C中调用它，这个tvOS的案例则展示了如何从Swift中调用它。

### 自定义事件

你可以轻松的通过使用`DDNAEvent`类标记自定义事件。使用你的事件项目名称创建一个`DDNAEvent`方法。调用`setParam:forKey`函数来添加事件属性。例如：

```objective-c
DDNAEvent *event = [DDNAEvent eventWithName:@"keyTypes"];
[event setParam:@5 forKey:@"userLevel"];
[event setParam:@YES forKey:@"isTutorial"];
[event setParam:[NSDate date] forKey:@"exampleTimestamp"];

[[DDNASDK sharedInstance] recordEvent:event];
```

### 吸引（Engage）

通过一个吸引（Engagement）改变游戏的行为。使用你的决策点的名字创建一个`DDNAEngagement`方法。吸引（Engage）将会通过一个键值字典为你的玩家做出响应。例如：

```objective-c
DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"gameLoaded"];
[engagement setParam:@4 forKey:@"userLevel"];
[engagement setParam:@1000 forKey:@"experience"];
[engagement setParam:@"Disco Volante" forKey:@"missionName"];

[[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary* parameters, NSInteger statusCode, NSError* error) {
    NSLog(@"Engagement request returned the following parameters:\n%@", parameters);
}];
```

### 进一步整合

请参阅我们的[文档](http://docs.deltadna.com/advanced-integration/ios-sdk/)网站以了解如何使用这个SDK的更多细节。

## 授权

该资源适用于Apache 2.0授权。
