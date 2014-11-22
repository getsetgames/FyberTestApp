//
//  SPVungleAdapter.h
//  SponsorPay iOS SDK
//
//  Created by David Davila on 5/30/13.
// Copyright 2011-2013 SponsorPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>
#import "SPTPNVideoAdapter.h"

@class SPVungleNetwork;

@interface SPVungleRewardedVideoAdapter : NSObject <SPTPNVideoAdapter, VungleSDKDelegate>

@property (nonatomic, weak) SPVungleNetwork *network;

@end
