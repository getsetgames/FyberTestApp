//
//  UIScreen+Additions.m
//  SponsorPaySDK
//
//  Created by tito on 21/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "UIScreen+SPAdditions.h"

@implementation UIScreen (SPAdditions)

+ (BOOL)isRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
        return YES;
    }

    return NO;
}

@end
