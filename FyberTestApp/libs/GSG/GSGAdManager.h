//
//  GSGAdManager.h
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdProductConfig.h"

//#define GSG_AD_FLURRY @"flurry"
//#define GSG_AD_ADCOLONY @"adcolony"
#define GSG_AD_CHARTBOOST @"chartboost"
//#define GSG_AD_APPLOVIN @"applovin"
#define GSG_AD_FYBER @"fyber"
#define GSG_AD_FYBER_INTERSTITIAL @"fyber-interstitial"
#define GSG_AD_NEWS @"news"

@interface GSGAdManager : NSObject {
  BOOL _firstRun;
    NSString* iapProduct;
}

@property (nonatomic, retain) NSDictionary *currentProviders;
@property (nonatomic, assign) BOOL adInProgress;
@property (readwrite) BOOL suppressInterstitial;
@property (nonatomic, retain) AdProductConfig* lastAdConfiguration;
@property (nonatomic, retain) UIView* lastAdView;

+(GSGAdManager*)sharedInstance;

-(void)initializeWithView:(UIViewController*)viewController
//       withFlurryDelegate:(id)flurryDelegate
//      andAdColonyDelegate:(id)adColonyDelegate
//    andChartBoostDelegate:(id)chartBoostDelegate
          andNewsDelegate:(id)newsDelegate
            andIapProduct:(NSString*)iap;

-(BOOL)showAdForConfiguration:(AdProductConfig*)identifier onViewController:(UIViewController*)viewController withFirstRun:(BOOL)firstRun;
-(BOOL)showAdForConfiguration:(AdProductConfig*)identifier onViewController:(UIViewController*)viewController withDelegate:(id)delegate;
-(BOOL)hasCachedAd:(AdProductConfig *)identifier;
-(void)cacheAd:(AdProductConfig *)identifier;
-(void)flush:(AdProductConfig *)identifier;
-(void)clearRequests:(AdProductConfig *)identifier;
-(void)setDelegateForConfiguration:(AdProductConfig *)identifier delegate:(id)delegate;

-(BOOL)canShowInterstitial;
//-(BOOL)repeatLastAd;

@end
