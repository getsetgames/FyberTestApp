//
//  SPEbuzzingRewardedVideoAdapter.m
//
//  Created on 07/05/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//
#import <EbuzzingSDK/EbuzzingSDK.h>

#import "SPEbuzzingRewardedVideoAdapter.h"
#import "SPEbuzzingNetwork.h"
#import "SPLogger.h"

static NSString *const SPRewardedVideoPlacementTag = @"SPEbuzzingRewardedVideoPlacementTag";
@interface SPEbuzzingRewardedVideoAdapter ()<EbzInterstitialDelegate>

@property (nonatomic, copy) NSString *placementTag;
@property (nonatomic, assign) BOOL videoAvailable;
@property (nonatomic, assign) BOOL userRewarded;
@property (nonatomic, strong) EbzInterstitial *ebuzzingInterstitial;
@property (nonatomic, weak) UIViewController *parentViewController;

@end

@implementation SPEbuzzingRewardedVideoAdapter

@synthesize delegate;

- (NSString *)networkName
{
    return self.network.name;
}

- (BOOL)startAdapterWithDictionary:(NSDictionary *)data
{
    self.placementTag = data[SPRewardedVideoPlacementTag];
    if (!self.placementTag.length) {
        SPLogError(@"Placement tag for Rewarded Video empty");
        return NO;
    }

    return YES;
}

- (void)checkAvailability
{
    if (!self.videoAvailable) {
        self.ebuzzingInterstitial = [[EbzInterstitial alloc] initWithPlacementTag:self.placementTag rootViewController:nil delegate:self];
        [self.ebuzzingInterstitial setRewardEnabled:YES];
        [self.ebuzzingInterstitial load];
    } else {
        [self.delegate adapter:self didReportVideoAvailable:YES];
    }
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
{
    self.videoAvailable = NO;
    self.ebuzzingInterstitial.rootViewController = parentVC;
    self.parentViewController = parentVC;
    [self.ebuzzingInterstitial show];
}

#pragma mark - EBZInterstitialDelegate methods
- (UIViewController *)viewControllerForModalPresentation:(EbzInterstitial *)interstitial
{
    return self.parentViewController;
}

- (void)ebzInterstitialWillLoad:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
}

- (void)ebzInterstitialDidLoad:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
    self.videoAvailable = YES;
    [self.delegate adapter:self didReportVideoAvailable:YES];
}

- (void)ebzInterstitial:(EbzInterstitial *)interstitial didFailLoading:(EbzError *)error
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
    if (error.code == EbzNoAdsAvailable) {
        [self.delegate adapter:self didReportVideoAvailable:NO];
    } else {
        [self.delegate adapter:self didFailWithError:nil];
    }
}

- (void)ebzInterstitialWillTakeOverFullScreen:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
    self.userRewarded = NO;
    [self.delegate adapterVideoDidStart:self];
}

- (void)ebzInterstitialDidTakeOverFullScreen:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
}

- (void)ebzInterstitialWillDismissFullScreen:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
}

- (void)ebzInterstitialDidDismissFullScreen:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);

    if (self.userRewarded) {
        [self.delegate adapterVideoDidClose:self];

    } else {
        [self.delegate adapterVideoDidAbort:self];
    }
}

- (void)ebzInterstitialRewardUnlocked:(EbzInterstitial *)interstitial
{
    SPLogDebug(@"%s", __PRETTY_FUNCTION__);
    self.userRewarded = YES;
    [self.delegate adapterVideoDidFinish:self];
}

@end
