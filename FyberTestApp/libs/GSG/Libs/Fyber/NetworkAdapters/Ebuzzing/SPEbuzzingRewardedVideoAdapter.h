//
//  SPEbuzzingRewardedVideoAdapter.m
//
//  Created on 07/05/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPRewardedVideoNetworkAdapter.h"

@class SPEbuzzingNetwork;

@interface SPEbuzzingRewardedVideoAdapter : NSObject <SPRewardedVideoNetworkAdapter>

@property (nonatomic, weak) SPEbuzzingNetwork *network;

@end
