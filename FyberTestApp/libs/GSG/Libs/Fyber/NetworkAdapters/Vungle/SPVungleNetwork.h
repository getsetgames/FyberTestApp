//
//  SponsorPay iOS SDK - Vungle Adapter v.2.1.0
//
//  Created by Daniel Barden on 13/01/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>
#import "SPBaseNetwork.h"

@interface SPVungleNetwork : SPBaseNetwork

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *orientation;
@property (nonatomic, readonly) UIInterfaceOrientationMask orientationMask;
@property (nonatomic, copy) NSNumber *showClose;

@end
