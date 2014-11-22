//
//  SPHyprMXRewardedVideoAdapter.m
//
//  Created on 22.05.14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPHyprMXRewardedVideoAdapter.h"
#import "SPHyprMXNetwork.h"
#import "SPLogger.h"
#import <HyprMX/HyprMX.h>

#ifndef LogInvocation
#define LogInvocation SPLogDebug(@"%s", __PRETTY_FUNCTION__)
#endif

@interface SPHyprMXRewardedVideoAdapter()

@property (nonatomic, assign, getter = isOfferReady) BOOL offerReady;

@end

@implementation SPHyprMXRewardedVideoAdapter

@synthesize delegate;

- (NSString *)networkName
{
    return self.network.name;
}

- (void)checkAvailability
{
    LogInvocation;
    
    [[HYPRManager sharedManager] checkInventory:^(BOOL isOfferReady) {
        self.offerReady = isOfferReady;
        [self.delegate adapter:self didReportVideoAvailable:isOfferReady];
        if (isOfferReady) {
            SPLogDebug(@"[HyprMX] HyprMX reported that offer is ready for display.");
        }
        else {
            SPLogWarn(@"[HyprMX] HyprMX reported that offer cannot be displayed.");
        }
    }];
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
{
    LogInvocation;
    
    if (self.isOfferReady) {
        [self.delegate adapterVideoDidStart:self];
        [[HYPRManager sharedManager] displayOffer:^(BOOL completed, HYPROffer *offer) {
            self.offerReady = NO;
            if (completed) {
                SPLogDebug(@"[HyprMX] HyprMX reported that offer has been completed successfully.");
                [self.delegate adapterVideoDidFinish:self];
                [self.delegate adapterVideoDidClose:self];
            }
            else {
                SPLogWarn(@"[HyprMX] HyprMX reported that offer has been aborted.");
                [self.delegate adapterVideoDidAbort:self];
            }
        }];
    }
}

- (BOOL)startAdapterWithDictionary:(NSDictionary *)dict
{
    // Sets the specific data for rewarded video, such as ad placements.
    // The data dictionary contains the SPNetworkParameters dictionary read from
	// the plist file
	
    return YES;
}

@end
