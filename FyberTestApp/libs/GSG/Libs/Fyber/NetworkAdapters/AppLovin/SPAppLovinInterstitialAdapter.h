//
//  SPAppLovingInterstitialAdapter.h
//  SponsorPayTestApp
//
//  Copyright (c) 2013 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPInterstitialNetworkAdapter.h"
#import "ALSdk.h"

@class SPAppLovinNetwork;

@interface SPAppLovinInterstitialAdapter : NSObject<SPInterstitialNetworkAdapter, ALAdLoadDelegate, ALAdDisplayDelegate>

@property (weak, nonatomic) SPAppLovinNetwork *network;

@end
