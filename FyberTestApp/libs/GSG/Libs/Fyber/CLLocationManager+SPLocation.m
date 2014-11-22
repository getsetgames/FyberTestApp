//
// Created by Jan on 25/08/14.
// Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "CLLocationManager+SPLocation.h"


@implementation CLLocationManager (SPLocation)

+ (BOOL)locationServicesEnabledAndAuthorized {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    return ([CLLocationManager locationServicesEnabled] &&
            ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
             [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways));
#else
    return ([CLLocationManager locationServicesEnabled] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);

#endif

}

@end