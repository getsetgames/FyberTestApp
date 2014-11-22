//
//  SPSSInterstitialDelegate.h
//  SponsorPaySDK
//
//  Created by tito on 18/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPInterstitialOffer.h"

@protocol SPSSInterstitialDelegate<NSObject>

@optional

/**
 *  Called when the UIWebView fails to load the interstitial
 *
 *  @param offer The interstitial that should have been displayed
 *  @param error The error
 */
- (void)interstitial:(SPInterstitialOffer *)offer didFailToLoadAdWithError:(NSError *)error;


/**
 *  Called the interstitial has been presented
 *
 *  @param offer The interstitial that is currently being presented
 */
- (void)interstitialDidPresentScreen:(SPInterstitialOffer *)offer;


/**
 *  Called whenever the user closes the interstitial by tappin gon the close button
 *
 *  @param offer The interstitial that was being presented
 */
- (void)interstitialDidDismissScreen:(SPInterstitialOffer *)offer;


/**
 *  Called whenever the user taps the ad
 *
 *  @param offer The interstitial that was tapped
 */
- (void)interstitialWillLeaveApplication:(SPInterstitialOffer *)offer;

@end
