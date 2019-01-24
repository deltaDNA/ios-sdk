//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#import "DDNAEventTrigger.h"
#import "DDNALog.h"

@interface DDNAEventTrigger ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, strong) NSDictionary *response;
@property (nonatomic, assign) NSUInteger campaignId;
@property (nonatomic, assign) NSUInteger variantId;
@property (nonatomic, copy) NSString *campaignName;
@property (nonatomic, copy) NSString *variantName;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) NSNumber *limit;
@property (nonatomic, strong) NSArray<NSDictionary *> *condition;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation DDNAEventTrigger

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        self.eventName = dictionary[@"eventName"];
        self.response = [NSDictionary dictionaryWithDictionary:dictionary[@"response"]];
        self.campaignId = [dictionary[@"campaignID"] unsignedIntegerValue];
        self.variantId = [dictionary[@"variantID"] unsignedIntegerValue];
        self.campaignName = self.response[@"eventParams"][@"responseEngagementName"];
        self.variantName = self.response[@"eventParams"][@"responseVariantName"];
        self.priority = [dictionary[@"priority"] integerValue];
        self.limit = dictionary[@"limit"];
        self.condition = [NSArray arrayWithArray:dictionary[@"condition"]];
        self.count = 0;
    }
    return self;
}

- (NSString *)actionType
{
    // TODO: action isn't being passed down initially, it has to be
    // inferred from the parameters as with old engagements.
    if (self.response && self.response[@"image"] != nil) return @"imageMessage";
    return @"gameParameters";
}

- (BOOL)respondsToEventSchema:(NSDictionary *)eventSchema
{
    if (self.eventName && ![eventSchema[@"eventName"] isEqualToString:self.eventName]) return NO;
    if (self.limit && [self.limit unsignedIntegerValue] <= self.count) return NO;
    
    NSDictionary *params = eventSchema[@"eventParams"];
    
    NSMutableArray *stack = [NSMutableArray array];
    for (NSDictionary *token in self.condition) {
        if (token[@"o"]) {
            NSString *op = [token[@"o"] lowercaseString];
            NSDictionary *rightToken = [stack lastObject];
            [stack removeLastObject];
            NSDictionary *leftToken = [stack lastObject];
            [stack removeLastObject];
            
            // substitute parameter from event
            if (leftToken[@"p"]) {
                if (params[leftToken[@"p"]]) {
                    leftToken = @{ rightToken.allKeys[0]: params[leftToken[@"p"]]};
                } else {
                    DDNALogWarn(@"Failed to find '%@' in parameters", leftToken[@"p"]);
                    return NO;
                }
            }
            
            @try {
                // assume that left and right are matching types to succeed
                if (leftToken[@"b"] && rightToken[@"b"]) {
                    [stack addObject:@{@"b": [self compareWithBoolOp:op left:leftToken[@"b"] right:rightToken[@"b"]]}];
                }
                else if (leftToken[@"i"] && rightToken[@"i"]) {
                    [stack addObject:@{@"b": [self compareWithIntOp:op left:leftToken[@"i"] right:rightToken[@"i"]]}];
                }
                else if (leftToken[@"f"] && rightToken[@"f"]) {
                    [stack addObject:@{@"b": [self compareWithFloatOp:op left:leftToken[@"f"] right:rightToken[@"f"]]}];
                }
                else if (leftToken[@"s"] && rightToken[@"s"]) {
                    [stack addObject:@{@"b": [self compareWithStrOp:op left:leftToken[@"s"] right:rightToken[@"s"]]}];
                }
                else if (leftToken[@"t"] && rightToken[@"t"]) {
                    [stack addObject:@{@"b": [self compareWithTimeOp:op left:leftToken[@"t"] right:rightToken[@"t"]]}];
                }
                else {
                    DDNALogWarn(@"Unexpected token type");
                    return NO;
                }
            }
            @catch (NSException *exception) {
                DDNALogWarn(@"Unexpected value evaluating trigger: %@", exception);
                return NO;
            }
            
        } else {
            [stack addObject:token];
        }
    }
    
    BOOL responding = (stack.count == 0) || ([stack.lastObject[@"b"] boolValue]);
    if (responding) self.count++;
    return responding;
}

- (NSNumber *)compareWithBoolOp:(NSString *)op left:(NSNumber *)left right:(NSNumber *)right
{
    if (left == nil || right == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil or empty" userInfo:nil]);
    }
    
    BOOL leftValue = [left boolValue];
    BOOL rightValue = [right boolValue];
    
    if ([op isEqualToString:@"and"]) {
        return [NSNumber numberWithBool:leftValue && rightValue];
    }
    else if ([op isEqualToString:@"or"]) {
        return [NSNumber numberWithBool:leftValue || rightValue];
    }
    else if ([op isEqualToString:@"equal to"]) {
        return [NSNumber numberWithBool:leftValue == rightValue];
    }
    else if ([op isEqualToString:@"not equal to"]) {
        return [NSNumber numberWithBool:leftValue != rightValue];
    }
    return nil;
}

- (NSNumber *)compareWithIntOp:(NSString *)op left:(NSNumber *)left right:(NSNumber *)right
{
    if (left == nil || right == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil or empty" userInfo:nil]);
    }
    
    NSInteger leftValue = [left integerValue];
    NSInteger rightValue = [right integerValue];
    
    if ([op isEqualToString:@"greater than"]) {
        return [NSNumber numberWithBool:leftValue > rightValue];
    }
    else if ([op isEqualToString:@"less than"]) {
        return [NSNumber numberWithBool:leftValue < rightValue];
    }
    else if ([op isEqualToString:@"equal to"]) {
        return [NSNumber numberWithBool:leftValue == rightValue];
    }
    else if ([op isEqualToString:@"not equal to"]) {
        return [NSNumber numberWithBool:leftValue != rightValue];
    }
    else if ([op isEqualToString:@"greater than eq"]) {
        return [NSNumber numberWithBool:leftValue >= rightValue];
    }
    else if ([op isEqualToString:@"less than eq"]) {
        return [NSNumber numberWithBool:leftValue <= rightValue];
    }
    return nil;
}

- (NSNumber *)compareWithFloatOp:(NSString *)op left:(NSNumber *)left right:(NSNumber *)right
{
    if (left == nil || right == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil or empty" userInfo:nil]);
    }
    
    NSInteger leftValue = [left doubleValue];
    NSInteger rightValue = [right doubleValue];
    
    if ([op isEqualToString:@"greater than"]) {
        return [NSNumber numberWithBool:leftValue > rightValue];
    }
    else if ([op isEqualToString:@"less than"]) {
        return [NSNumber numberWithBool:leftValue < rightValue];
    }
    else if ([op isEqualToString:@"equal to"]) {
        return [NSNumber numberWithBool:leftValue == rightValue];
    }
    else if ([op isEqualToString:@"not equal to"]) {
        return [NSNumber numberWithBool:leftValue != rightValue];
    }
    else if ([op isEqualToString:@"greater than eq"]) {
        return [NSNumber numberWithBool:leftValue >= rightValue];
    }
    else if ([op isEqualToString:@"less than eq"]) {
        return [NSNumber numberWithBool:leftValue <= rightValue];
    }
    return nil;
}

- (NSNumber *)compareWithStrOp:(NSString *)op left:(NSString *)left right:(NSString *)right
{
    if (left == nil || right == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil or empty" userInfo:nil]);
    }
    
    if ([op isEqualToString:@"equal to"]) {
        return [NSNumber numberWithBool:[left compare:right] == NSOrderedSame];
    }
    else if ([op isEqualToString:@"not equal to"]) {
        return [NSNumber numberWithBool:[left compare:right] != NSOrderedSame];
    }
    else if ([op isEqualToString:@"starts with"]){
        NSRange prefixRange = [left rangeOfString:right options:NSAnchoredSearch range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.location == 0 && prefixRange.length == right.length];
    }
    else if ([op isEqualToString:@"contains"]) {
        NSRange prefixRange = [left rangeOfString:right options:0 range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.length == right.length];
    }
    else if ([op isEqualToString:@"ends with"]) {
        NSRange prefixRange = [left rangeOfString:right options:(NSAnchoredSearch|NSBackwardsSearch) range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.location == left.length - right.length && prefixRange.length == right.length];
    }
    else if ([op isEqualToString:@"equal to ic"]) {
        return [NSNumber numberWithBool:[left caseInsensitiveCompare:right] == NSOrderedSame];
    }
    else if ([op isEqualToString:@"not equal to ic"]) {
        return [NSNumber numberWithBool:[left caseInsensitiveCompare:right] != NSOrderedSame];
    }
    else if ([op isEqualToString:@"starts with ic"]) {
        NSRange prefixRange = [left rangeOfString:right options:(NSAnchoredSearch|NSCaseInsensitiveSearch) range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.location == 0 && prefixRange.length == right.length];
    }
    else if ([op isEqualToString:@"contains ic"]) {
        NSRange prefixRange = [left rangeOfString:right options:NSCaseInsensitiveSearch range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.length == right.length];
    }
    else if ([op isEqualToString:@"ends with ic"]) {
        NSRange prefixRange = [left rangeOfString:right options:(NSAnchoredSearch|NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(0, left.length) locale:[NSLocale currentLocale]];
        return [NSNumber numberWithBool:prefixRange.location == left.length - right.length && prefixRange.length == right.length];
    }
    
    return nil;
}

- (NSNumber *)compareWithTimeOp:(NSString *)op left:(NSString *)left right:(NSString *)right
{
    if (left == nil || right == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil or empty" userInfo:nil]);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *leftValue = [formatter dateFromString:left];
    NSDate *rightValue = [formatter dateFromString:right];
    
    if (leftValue == nil || rightValue == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"non iso 8601 timestamp format" userInfo:nil]);
    }
    
    if ([op isEqualToString:@"greater than"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] > 0];
    }
    else if ([op isEqualToString:@"less than"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] < 0];
    }
    else if ([op isEqualToString:@"equal to"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] == 0];
    }
    else if ([op isEqualToString:@"not equal to"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] != 0];
    }
    else if ([op isEqualToString:@"greater than eq"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] >= 0];
    }
    else if ([op isEqualToString:@"less than eq"]) {
        return [NSNumber numberWithBool:[leftValue timeIntervalSinceDate:rightValue] <= 0];
    }
    return nil;
}

@end
