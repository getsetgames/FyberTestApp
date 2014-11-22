//
//  SPOrientationProvider.m
//  SponsorPaySDK
//
//  Created by tito on 31/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPOrientationProvider.h"
#import <UIKit/UIKit.h>

static NSString *const kSPURLParamKeyOrientation = @"orientation";

@implementation SPOrientationProvider

- (NSDictionary *)dictionaryWithKeyValueParameters
{
    NSString *orientation = @"";

    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    switch (currentInterfaceOrientation) {
    case UIInterfaceOrientationPortrait:
        orientation = @"portrait";
        break;
    case UIInterfaceOrientationPortraitUpsideDown:
        orientation = @"portrait_upside_down";
        break;
    case UIInterfaceOrientationLandscapeLeft:
        orientation = @"landscape_left";
        break;
    case UIInterfaceOrientationLandscapeRight:
        orientation = @"landscape_right";
        break;

    default:
        break;
    }

    NSDictionary *orientationParameters = @{ kSPURLParamKeyOrientation: orientation };

    return orientationParameters;
}


@end
