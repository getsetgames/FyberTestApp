//
//  SPFyberInterstitialAdapter.m
//  NetworkAdapters
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 sponsorpay. All rights reserved.
//
#import "SPFyberNetwork.h"

@class SPFyberInterstitialAdapter;

@interface SPFyberInterstitialAdapter : NSObject<SPInterstitialNetworkAdapter>

@property (weak, nonatomic) SPFyberNetwork *network;

@end
