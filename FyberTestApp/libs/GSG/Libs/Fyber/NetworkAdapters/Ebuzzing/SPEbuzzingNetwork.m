//
//  SPEbuzzingNetwork.m
//
//  Created on 07/05/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

// Adapter versioning - Remember to update the header

#import "SPEbuzzingNetwork.h"
#import "SPEbuzzingRewardedVideoAdapter.h"
#import "SPTPNGenericAdapter.h"
#import "SPSemanticVersion.h"

static const NSInteger SPEbuzzingVersionMajor = 2;
static const NSInteger SPEbuzzingVersionMinor = 0;
static const NSInteger SPEbuzzingVersionPatch = 0;

static NSString *const SPRewardedVideoAdapterClassName = @"SPEbuzzingRewardedVideoAdapter";

@interface SPEbuzzingNetwork ()

@property (nonatomic, strong) SPTPNGenericAdapter *rewardedVideoAdapter;

@end

@implementation SPEbuzzingNetwork

@synthesize rewardedVideoAdapter = _rewardedVideoAdapter;

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion versionWithMajor:SPEbuzzingVersionMajor
                                         minor:SPEbuzzingVersionMinor
                                         patch:SPEbuzzingVersionPatch];
}

- (id)init
{
    self = [super init];
    if (self) {
        Class RewardedVideoAdapterClass = NSClassFromString(SPRewardedVideoAdapterClassName);
        if (RewardedVideoAdapterClass) {
            self.rewardedVideoAdapter = [[SPTPNGenericAdapter alloc] init];
        }

        _rewardedVideoAdapter = [[SPTPNGenericAdapter alloc] init];
    }
    return self;
}

- (BOOL)startSDK:(NSDictionary *)data
{
    // Validates the necessary inputs and return YES if the adapter was initialized
    // successfully or NO in case of failure
    return YES;
}

- (void)startRewardedVideoAdapter:(NSDictionary *)data
{
    Class RewardedVideoAdapterClass = NSClassFromString(SPRewardedVideoAdapterClassName);
    if (!RewardedVideoAdapterClass) {
        return;
    }

    id<SPRewardedVideoNetworkAdapter> eBuzzingLovinRewardedVideoAdapter = [[RewardedVideoAdapterClass alloc] init];

    SPTPNGenericAdapter *eBuzzingLovinRewardedVideoAdapterWrapper = [[SPTPNGenericAdapter alloc] initWithVideoNetworkAdapter:eBuzzingLovinRewardedVideoAdapter];
    eBuzzingLovinRewardedVideoAdapter.delegate = eBuzzingLovinRewardedVideoAdapterWrapper;

    self.rewardedVideoAdapter = eBuzzingLovinRewardedVideoAdapterWrapper;

    [super startRewardedVideoAdapter:data];
}

@end
