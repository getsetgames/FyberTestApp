//
// Created by Jan on 03/09/14.
// Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPCloseButton.h"

@interface SPCloseButton (SPFrameHelper)

- (CGRect)frameForCloseButtonInVideoPlayerInFrame:(CGRect)frame;

- (CGRect)frameForCloseButtonInInterstitialInFrame:(CGRect)frame;

@end