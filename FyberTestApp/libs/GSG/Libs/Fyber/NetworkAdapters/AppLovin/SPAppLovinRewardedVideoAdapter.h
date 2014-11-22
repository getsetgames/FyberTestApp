//
//  SPApplovinAdapter.h
//  SponsorPayTestApp
//
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRewardedVideoNetworkAdapter.h"

@class SPAppLovinNetwork;

@interface SPAppLovinRewardedVideoAdapter : NSObject <SPRewardedVideoNetworkAdapter>

@property (nonatomic, weak) SPAppLovinNetwork *network;

@end
