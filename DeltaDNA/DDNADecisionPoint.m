//
//  DDNADecisionPoint.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNADecisionPoint.h"

@implementation NSString (DeltaDNA)

+ (NSString *)stringWithDDNADecisionPointFlavour: (DDNADecisionPointFlavour)flavour
{
    switch (flavour) {
        case DDNADecisionPointFlavourEngagement:
            return @"engagement";
        case DDNADecisionPointFlavourAdvertising:
            return @"advertising";
        case DDNADecisionPointFlavourInternal:
            return @"internal";
        default:
            return nil;
    }
}

@end

@interface DDNADecisionPoint ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) DDNADecisionPointFlavour flavour;

@end

@implementation DDNADecisionPoint

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name andFlavour:DDNADecisionPointFlavourEngagement];
}

- (instancetype)initWithName:(NSString *)name andFlavour:(DDNADecisionPointFlavour)flavour
{
    if (self = ([super init])) {
        self.name = name;
        self.flavour = flavour;
    }
    return self;
}

@end
