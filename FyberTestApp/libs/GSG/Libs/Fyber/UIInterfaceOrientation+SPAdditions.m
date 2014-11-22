//
//  UIInterfaceOrientation+SPAdditions.m
//  SponsorPaySDK
//
//  Created by tito on 11/09/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "UIInterfaceOrientation+SPAdditions.h"

BOOL UIInterfaceOrientationIsSupported(UIInterfaceOrientation orientation) {
    static NSString *_orientationFlagNames[] = {
        Nil,                                        // UIDeviceOrientationUnknown
        @"UIInterfaceOrientationPortrait",          // UIDeviceOrientationPortrait,
        @"UIInterfaceOrientationPortraitUpsideDown",// UIDeviceOrientationPortraitUpsideDown,
        @"UIInterfaceOrientationLandscapeRight",    // UIDeviceOrientationLandscapeLeft [sic]
        @"UIInterfaceOrientationLandscapeLeft"      // UIDeviceOrientationLandscapeRight [sic]
    };

    NSArray *supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];

    return [supportedOrientations containsObject:_orientationFlagNames[orientation]];
}

