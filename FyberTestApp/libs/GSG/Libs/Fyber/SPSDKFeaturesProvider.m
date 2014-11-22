//
//  SPSDKFeaturesProvider.m
//  SponsorPayTestApp
//
//  Created by Daniel Barden on 12/03/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPSDKFeaturesProvider.h"

@implementation SPSDKFeaturesProvider

static NSString *const SPSDKSupportsInstall = @"INS";
static NSString *const SPSDKSupportsVideo = @"VPL";
static NSString *const SPSDKInterstitials = @"MPI";

- (NSDictionary *)dictionaryWithKeyValueParameters
{
    NSArray *capabilities = @[
        SPSDKSupportsInstall, // SDK Supports the install command
        SPSDKSupportsVideo,
        SPSDKInterstitials
    ];

    NSString *capabilitiesString = [capabilities componentsJoinedByString:@","];
    NSDictionary *features = @{ @"sdk_features": capabilitiesString };

    return features;
}

@end
