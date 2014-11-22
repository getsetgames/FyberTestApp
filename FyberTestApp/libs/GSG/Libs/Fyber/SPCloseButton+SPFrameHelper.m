//
// Created by Jan on 03/09/14.
// Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPCloseButton+SPFrameHelper.h"

static const CGFloat SPTappablePaddingForCloseButton = 15.0;

@implementation SPCloseButton (SPFrameHelper)

// Based on the requirements, the video player will only be displayed using the
// landscape orientation
- (CGRect)frameForCloseButtonInVideoPlayerInFrame:(CGRect)frame
{
    return [self frameForCloseButtonForceLandscape:YES containedInFrame:frame];
}

- (CGRect)frameForCloseButtonInInterstitialInFrame:(CGRect)frame
{
    return [self frameForCloseButtonForceLandscape:NO containedInFrame:frame];
}

- (CGRect)frameForCloseButtonForceLandscape:(BOOL)forceLandscape containedInFrame:(CGRect)parentFrame
{

    CGRect frame = CGRectZero;
    CGFloat padding = SPTappablePaddingForCloseButton;
    CGFloat doublePadding = 2 * padding;
    CGFloat baseRectSide = 30 + doublePadding;
    CGFloat borderOffset = 16 - padding;

    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (forceLandscape) {
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            frame = CGRectMake(parentFrame.size.width - (baseRectSide + borderOffset),
                               parentFrame.size.height - (baseRectSide + borderOffset),
                               baseRectSide,
                               baseRectSide);
        } else {
            frame = CGRectMake(parentFrame.size.width - (baseRectSide + borderOffset),
                               0,
                               baseRectSide,
                               baseRectSide);
        }
    } else { // always top right of the parent frame
        frame = CGRectMake(parentFrame.size.width - (baseRectSide + borderOffset),
                           parentFrame.origin.y + borderOffset,
                           baseRectSide,
                           baseRectSide);
    }

    return frame;
}
@end