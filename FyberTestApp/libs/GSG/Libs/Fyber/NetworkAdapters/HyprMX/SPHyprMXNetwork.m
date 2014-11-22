//
//  SPHyprMXNetwork.m
//
//  Created on 22.05.14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPHyprMXNetwork.h"
#import "SPLogger.h"
#import "SPRandomID.h"
#import "SPSemanticVersion.h"
#import "SPTPNGenericAdapter.h"
#import "SPSystemVersionChecker.h"
#import <HyprMX/HyprMX.h>


static const NSInteger SPHyprMXVersionMajor = 2;
static const NSInteger SPHyprMXVersionMinor = 1;
static const NSInteger SPHyprMXVersionPatch = 1;

static NSString *const SPHyprMXDistributorID = @"SPHyprMXDistributorID";
static NSString *const SPHyprMXPropertyID = @"SPHyprMXPropertyID";
static NSString *const SPHyprMXUserID = @"SPHyprMXUserID";

static NSString *const SPRewardedVideoAdapterClassName = @"SPHyprMXRewardedVideoAdapter";


@interface SPHyprMXNetwork ()

@property (nonatomic, copy, readonly) NSString *HyprMXUserID;
@property (nonatomic, strong) id<SPTPNVideoAdapter> rewardedVideoAdapter;

@end


@implementation SPHyprMXNetwork

@synthesize rewardedVideoAdapter = _rewardedVideoAdapter;

#pragma mark - Class Methods

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion
    versionWithMajor:SPHyprMXVersionMajor
               minor:SPHyprMXVersionMinor
               patch:SPHyprMXVersionPatch];
}


#pragma mark - Custom Accessors

- (NSString *)HyprMXUserID
{
    NSUserDefaults *const defaults = [NSUserDefaults standardUserDefaults];

    NSString *result = [defaults objectForKey:SPHyprMXUserID];

    if (![result isKindOfClass:[NSString class]] || ![result length]) {
        SPLogDebug(@"[HyprMX] Creating new user ID.");
        result = [SPRandomID randomIDString];

        [defaults setObject:result forKey:SPHyprMXUserID];
    } else {
        SPLogDebug(@"[HyprMX] Using existing user ID.");
    }

    return result;
}


#pragma mark - Public

- (BOOL)startSDK:(NSDictionary *)data
{
    // The HyprMX Mobile SDK supports iOS 6 or higher. It will not return ads on iOS 5.
    if (![SPSystemVersionChecker runningOniOS6OrNewer]) {
        
        SPLogError(@"[HyprMX] Could not start %@ Provider. The HyprMX Mobile SDK supports iOS 6 or higher.", self.name);
        return NO;
    }
    
    if (![data isKindOfClass:[NSDictionary class]]) {
        SPLogError(@"[HyprMX] data parameter is nil or not a dictionary.");
        return NO;
    }

    NSString *const distributorID = data[SPHyprMXDistributorID];

    if (![distributorID isKindOfClass:[NSString class]] || ![distributorID length]) {
        SPLogError(@"[HyprMX] No or empty value given for key %@.", SPHyprMXDistributorID);

        return NO;
    }


    NSString *const propertyID = data[SPHyprMXPropertyID];

    if (![propertyID isKindOfClass:[NSString class]] || ![propertyID length]) {
        SPLogError(@"[HyprMX] No or empty value given for key %@.", SPHyprMXPropertyID);

        return NO;
    }

    [[HYPRManager sharedManager] initializeWithDistributorId:distributorID propertyId:propertyID userId:self.HyprMXUserID];

    return YES;
}


- (void)startRewardedVideoAdapter:(NSDictionary *)data
{
    Class RewardedVideoAdapterClass = NSClassFromString(SPRewardedVideoAdapterClassName);
    if (!RewardedVideoAdapterClass) {
        return;
    }
    
    id<SPRewardedVideoNetworkAdapter> rewardedVideoAdapter = [RewardedVideoAdapterClass new];
    
    SPTPNGenericAdapter *rewardedVideoAdapterWrapper = [[SPTPNGenericAdapter alloc] initWithVideoNetworkAdapter:rewardedVideoAdapter];
    rewardedVideoAdapter.delegate = rewardedVideoAdapterWrapper;
    
    self.rewardedVideoAdapter = rewardedVideoAdapterWrapper;
    
    [super startRewardedVideoAdapter:data];
}

@end
