//
//  SPSSInterstitialClient.h
//  SponsorPaySDK
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SPInterstitialOffer;
@protocol SPSSInterstitialDelegate;

@interface SPSSInterstitialClient : NSObject

@property (nonatomic, assign, readonly) BOOL interstitialAvailable;

@property (nonatomic, weak) id<SPSSInterstitialDelegate> delegate;


- (void)cacheInterstitial:(SPInterstitialOffer *)interstitial;
- (void)showInterstitialFromViewController:(UIViewController *)parentViewController;

@end
