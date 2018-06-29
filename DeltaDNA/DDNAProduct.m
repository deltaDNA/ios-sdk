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

#import "DDNAProduct.h"
#import "DDNALog.h"

@interface DDNAProduct ()

@property (nonatomic, weak) NSMutableArray *virtualCurrencies;
@property (nonatomic, weak) NSMutableArray *items;

@end

@interface XmlParserDelegate : NSObject<NSXMLParserDelegate>

@property (readonly) NSDictionary *dictionary;

@end

@implementation DDNAProduct

static NSDictionary* ISO4217 = nil;
static dispatch_once_t onceToken;

+ (instancetype)product
{
    return [[DDNAProduct alloc] init];
}

- (void)setRealCurrencyType:(NSString *)type amount:(NSInteger)amount
{
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    [self setParam:@{@"realCurrencyType":type, @"realCurrencyAmount":[NSNumber numberWithInteger:amount]} forKey:@"realCurrency"];
}

- (void)addVirtualCurrencyName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount
{
    if (name == nil || name.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"name cannot be nil or empty" userInfo:nil]);
    }
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    
    NSDictionary *virtualCurrency = @{
        @"virtualCurrency": @{
            @"virtualCurrencyName": name,
            @"virtualCurrencyType": type,
            @"virtualCurrencyAmount": [NSNumber numberWithInteger:amount]
        }
    };
    
    if (![self paramForKey:@"virtualCurrencies"]) {
        NSMutableArray *virtualCurrencies = [NSMutableArray arrayWithObject:virtualCurrency];
        [self setParam:virtualCurrencies forKey:@"virtualCurrencies"];
        self.virtualCurrencies = virtualCurrencies;
    } else {
        [self.virtualCurrencies addObject:virtualCurrency];
    }
}

- (void)addItemName:(NSString *)name type:(NSString *)type amount:(NSInteger)amount
{
    if (name == nil || name.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"name cannot be nil or empty" userInfo:nil]);
    }
    if (type == nil || type.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"type cannot be nil or empty" userInfo:nil]);
    }
    
    NSDictionary *item = @{
        @"item": @{
            @"itemName": name,
            @"itemType": type,
            @"itemAmount": [NSNumber numberWithInteger:amount]
        }
    };
    
    if (![self paramForKey:@"items"]) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:item];
        [self setParam:items forKey:@"items"];
        self.items = items;
    } else {
        [self.items addObject:item];
    }
}

+ (NSInteger)convertCurrencyCode:(NSString *)code value:(NSDecimalNumber *)value
{
    if (code == nil || code.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"code cannot be nil or empty" userInfo:nil]);
    }
    if (value == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"value cannot be nil" userInfo:nil]);
    }
    
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *xmlPath = [bundle pathForResource:@"iso_4217" ofType:@"xml"];
        NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
        XmlParserDelegate *xmlParserDelegate = [[XmlParserDelegate alloc] init];
        [xmlParser setDelegate:xmlParserDelegate];
        [xmlParser parse];
        
        ISO4217 = xmlParserDelegate.dictionary;
    });
    
    NSNumber *minorUnits = [ISO4217 objectForKey:code];
    if (minorUnits) {
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithMantissa:pow(10, [minorUnits intValue]) exponent:0 isNegative:NO];
        value = [value decimalNumberByMultiplyingBy:number];
        return (NSInteger)roundf([value floatValue]);
    } else {
        DDNALogWarn(@"Failed to find currency for %@", code);
        return 0;
    }
}

@end

@implementation XmlParserDelegate

NSString *code;
NSNumber *value;
bool expectingCode;
bool expectingValue;

- (id)init {
    self = [super init];
    
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"Ccy"]) {
        expectingCode = YES;
        expectingValue = NO;
    } else if ([elementName isEqualToString:@"CcyMnrUnts"]) {
        expectingCode = NO;
        expectingValue = YES;
    } else {
        expectingCode = NO;
        expectingValue = NO;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    if ([elementName isEqualToString:@"CcyNtry"]) {
        if (code && value) {
            [_dictionary setValue:value forKey:code];
        }
        
        code = nil;
        value = nil;
    }
    
    expectingCode = NO;
    expectingValue = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (expectingCode) {
        code = string;
    } else if (expectingValue) {
        value = [NSNumber numberWithInt:[string intValue]];
    }
}

@end
