![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA分析iOS SDK

[![Build Status](https://travis-ci.org/deltaDNA/ios-sdk.svg)](https://travis-ci.org/deltaDNA/ios-sdk)

### 使用CocoaPods安装

[CocoaPods](https://cocoapods.org/)是一个Objective-C的依赖关系管理器，可以非常简便的自动使用第三方库。

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNA', '~> 4.1'
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

通过一个吸引（Engagement）改变游戏的行为。使用你的决策点的名字创建一个`DDNAEngagement`方法。吸引（Engage）将会通过一个键值字典为你的玩家做出响应。根据在平台上吸引（Engage）活动如何被创建，响应看起来像：

```json
{
    "parameters":{},
    "image":{},
    "heading":"An optional heading",
    "message":"An optional message"
}
```

如果吸引（Engage）的请求成功，`parameters`（参数）键值将一直存在。但是如果没有参数返回，其将为空。图像（image）、标题（heading）和消息（message）都是可选的。游戏可以通过这些参数来为玩家定制其行为。

例如：

```objective-c
DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"gameLoaded"];
[engagement setParam:@4 forKey:@"userLevel"];
[engagement setParam:@1000 forKey:@"experience"];
[engagement setParam:@"Disco Volante" forKey:@"missionName"];

[[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary* parameters, NSInteger statusCode, NSError* error) {
    NSLog(@"Engagement request returned the following parameters:\n%@", parameters[@"parameters"]);
}];
```

#### 图片消息

吸引（Engage）支持的行为之一就是图片消息。其将在游戏屏幕展示一个自定义的弹出内容。你可以用`DDNAEngagement`创建一个来测试是否吸引（Engage）返回了一个图片消息。如果在这个吸引（Engage）中没有图片被定义，那么这个图片消息将为空（NIL）。下面的代码展示了你如何依靠吸引（Engage）的响应动态的显示一张弹出图片。

```objective-c
DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"imageMessage"];

[[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement* response) {

    DDNAImageMessage* imageMessage = [DDNAImageMessage imageMessageWithEngagement:response delegate:self];
    if (imageMessage != nil) {
        // Engagement contained a valid image message response!
        [imageMessage fetchResources];
        // -didReceiveResourcesForImageMessage will be called once the resources are available.
    }
    else {
        NSLog(@"Engage response did not contain an image message.");
    }
}];
```

### 进一步整合

请参阅我们的[文档](http://docs.deltadna.com/zh/advanced-integration/ios-sdk/)网站以了解如何使用这个SDK的更多细节。

## 授权

该资源适用于Apache 2.0授权。
