//
//  SPInterstitialViewController.h
//  SponsorPaySDK
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPSSInterstitialType.h"


@class SPCloseButton;
@class SPInterstitialOffer;
@class SPInterstitialHTMLOffer;
@protocol SPSSInterstitialDelegate;


@interface SPSSInterstitialViewController : UIViewController

// Following properties are used for testing purposed
@property (nonatomic, strong) Class alertViewClass;
@property (nonatomic, strong) Class storeKitStoreProductClass;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) SPCloseButton *closeButton;

@property (nonatomic, weak) id<SPSSInterstitialDelegate> delegate;

@property (nonatomic, assign) UIInterfaceOrientation forcedOrientation;

- (id)initWithInterstitialOffer:(SPInterstitialOffer *)interstitial;



@end
