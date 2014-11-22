//
// Created by Jan on 25/08/14.
// Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (SPLocation)

/**
 *  Helper method to determine if the location is available
 *
 *  @return YES if the location services are enabled and the user did authorize the location usage.
 */
+ (BOOL)locationServicesEnabledAndAuthorized;

@end