//
// Copyright (c) 2020 deltaDNA Ltd. All rights reserved.
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
#import "DDNAEvent.h"
#include <ifaddrs.h>
#import <DeltaDNA/DeltaDNA-Swift.h>

@interface DDNAPinpointer : NSObject

@end

@implementation DDNAPinpointer

+ (DDNAEvent*) createSignalTrackingSessionEvent :(NSString *) developerId
{
    return [DDNAPinpointerHelpers createSignalTrackingSessionEventWithDeveloperId:developerId];
}

+ (DDNAEvent*) createSignalTrackingPurchaseEvent :(NSString *) developerId :(NSNumber *) realCurrencyAmount :(NSString *) realCurrencyType
{
    return [DDNAPinpointerHelpers createSignalTrackingPurchaseEventWithRealCurrencyAmount:realCurrencyAmount realCurrencyType:realCurrencyType developerId:developerId];
}

+ (DDNAEvent*) createSignalTrackingAdRevenueEvent :(NSString *) developerId :(NSNumber *) realCurrencyAmount :(NSString *) realCurrencyType
{
    return [DDNAPinpointerHelpers createSignalTrackingAdRevenueEventWithRealCurrencyAmount:realCurrencyAmount realCurrencyType:realCurrencyType developerId:developerId];
}
@end
