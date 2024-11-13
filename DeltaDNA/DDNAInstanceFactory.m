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

#import "DDNAInstanceFactory.h"
#import "DDNASDK.h"
#import "DDNASettings.h"
#import "DDNAClientInfo.h"
#import "DDNANetworkRequest.h"
#import "DDNAEngageService.h"
#import "DDNACollectService.h"

@implementation DDNAInstanceFactory

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (DDNANetworkRequest *)buildNetworkRequestWithURL: (NSURL *)URL jsonPayload: (NSString *)jsonPayload delegate:(id<DDNANetworkRequestDelegate>)delegate
{
    DDNANetworkRequest *networkRequest = [[DDNANetworkRequest alloc] initWithURL:URL jsonPayload:jsonPayload];
    networkRequest.delegate = delegate;
    
    return networkRequest;
}

- (DDNAEngageService *)buildEngageService
{
    DDNASDK *ddnasdk = [DDNASDK sharedInstance];
    DDNAClientInfo *ddnaci = [DDNAClientInfo sharedInstance];
    
    DDNAEngageService *engageService = [[DDNAEngageService alloc] initWithEnvironmentKey:ddnasdk.environmentKey
                                                                               projectID:ddnasdk.projectID
                                                                               engageURL:ddnasdk.engageURL
                                                                              hashSecret:ddnasdk.hashSecret
                                                                              apiVersion:DDNA_ENGAGE_API_VERSION
                                                                              sdkVersion:DDNA_SDK_VERSION
                                                                                platform:ddnaci.platform
                                                                                  locale:ddnaci.locale
                                                                          timezoneOffset:ddnaci.timezoneOffset
                                                                            manufacturer:ddnaci.manufacturer
                                                                  operatingSystemVersion:ddnaci.operatingSystemVersion
                                                                          timeoutSeconds:ddnasdk.settings.httpRequestEngageTimeoutSeconds
                                                                     cacheExpiryInterval:ddnasdk.settings.engageCacheExpirySeconds];
    
    engageService.factory = self;
    return engageService;
}

- (DDNACollectService *)buildCollectService
{
    DDNASDK *ddnasdk = [DDNASDK sharedInstance];
    
    DDNACollectService *collectService = [[DDNACollectService alloc] initWithEnvironmentName:ddnasdk.environmentName projectID:ddnasdk.projectID collectURL:ddnasdk.collectURL hashSecret:ddnasdk.hashSecret];
    
    collectService.factory = self;
    return collectService;
}

@end
