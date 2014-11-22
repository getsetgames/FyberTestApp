//
//  SPAdColonyRewardedVideoAdapter.h
//
//  Created on 07/05/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRewardedVideoNetworkAdapter.h"
#import <AdColony/AdColony.h>

@class SPAdColonyNetwork;


/**
 Implementation of AdColony network for Rewarded Video demand
 
 ## Version compatibility
 
 - Adapter version: 2.1.1
 - Fyber SDK version: 6.5.2
 - AdColony SDK version: 2.4.12
 
 */

@interface SPAdColonyRewardedVideoAdapter : NSObject <SPRewardedVideoNetworkAdapter, AdColonyDelegate, AdColonyAdDelegate>

@property (nonatomic, weak) SPAdColonyNetwork *network;

@end
