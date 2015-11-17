//
//  DDNADecisionPoint.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDNADecisionPointFlavour) {
    DDNADecisionPointFlavourEngagement,
    DDNADecisionPointFlavourInternal,
    DDNADecisionPointFlavourAdvertising
};

@interface NSString (DeltaDNA)

+ (NSString *)stringWithDDNADecisionPointFlavour: (DDNADecisionPointFlavour)flavour;

@end

@interface DDNADecisionPoint : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) DDNADecisionPointFlavour flavour;

- (instancetype)initWithName: (NSString *)name;

- (instancetype)initWithName: (NSString *)name andFlavour: (DDNADecisionPointFlavour)flavour;

@end
