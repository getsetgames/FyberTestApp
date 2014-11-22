//
//  SPSSInterstitialClient.m
//  SponsorPaySDK
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "UIApplication+SPAdditions.h"
#import "UIInterfaceOrientation+SPAdditions.h"

#import "SPSSInterstitialClient.h"
#import "SPSSInterstitialDelegate.h"
#import "SPSSInterstitialViewController.h"
#import "SPInterstitialOffer.h"

#import "SPVideoPlayerViewController.h"
#import "SPVideoPlayerStateDelegate.h"

#import "SPLogger.h"
#import "SPInterstitialHTMLOffer.h"


@interface SPSSInterstitialClient ()

@property (nonatomic, strong) SPSSInterstitialViewController *interstitialViewController;
@property (nonatomic, strong) SPVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) UIViewController *parentViewController;

@property (nonatomic, strong) SPInterstitialOffer *interstitial;

@property (nonatomic, assign) UIInterfaceOrientation orientationDuringRequest;

@property (assign, readwrite, nonatomic) BOOL interstitialAvailable;

#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
#else
@property (nonatomic, assign) dispatch_semaphore_t semaphore;
#endif

@end


@implementation SPSSInterstitialClient


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];

    if (self) {
        self.interstitialAvailable = NO;
    }

    return self;
}


#pragma mark - Private

- (void)cacheInterstitial:(SPInterstitialOffer *)interstitial
{
    self.orientationDuringRequest = [[UIApplication sharedApplication] statusBarOrientation];
    self.interstitial = interstitial;
    self.interstitialAvailable = YES;
    [self setupInterstitialViewController];

    // If we want to start loading the interstitial as soon as we get the offer
    // here would be the place
    // [self.interstitialViewController preloadInterstitial];
}

- (void)setupInterstitialViewController
{
    switch (self.interstitial.type) {
            // HTML interstitial requiring MRAID

        case SPSSInterstitialTypeHTML: {
            self.interstitialViewController = [[SPSSInterstitialViewController alloc] initWithInterstitialOffer:self.interstitial];
            self.interstitialViewController.delegate = self.delegate;

            if ([self.interstitial isLandscape]) {
                if (UIInterfaceOrientationIsLandscape(self.orientationDuringRequest)) {
                    self.interstitialViewController.forcedOrientation = self.orientationDuringRequest;
                } else {
                    self.interstitialViewController.forcedOrientation = UIInterfaceOrientationLandscapeRight;
                }
            } else if ([self.interstitial isPortrait]) {
                if (UIInterfaceOrientationIsPortrait(self.orientationDuringRequest)) {
                    self.interstitialViewController.forcedOrientation = self.orientationDuringRequest;
                } else {
                    self.interstitialViewController.forcedOrientation = UIInterfaceOrientationPortrait;
                }
            } else if (!self.interstitial.orientation) {
                self.interstitialViewController.forcedOrientation = self.orientationDuringRequest;
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)parentViewController
{
    // Compaer self.orientationDuringRequest && self.interstitial.orientation

    self.parentViewController = parentViewController;
    [self.parentViewController presentViewController:self.interstitialViewController animated:NO completion:nil];
}

#pragma mark - Helper

- (void)safelyOpenURL:(NSString *)urlString
{
    [[UIApplication sharedApplication] safelyOpenUrlString:urlString success:^{
        if ([self.delegate respondsToSelector:@selector(interstitialWillLeaveApplication:)]) {
            [self.delegate performSelector:@selector(interstitialWillLeaveApplication:) withObject:self.interstitial];
        }
    } failure:nil];
}


@end
