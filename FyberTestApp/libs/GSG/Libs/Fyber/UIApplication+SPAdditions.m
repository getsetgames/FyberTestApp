//
//  UIApplication+SPAdditions.m
//  SponsorPaySDK
//
//  Created by tito on 29/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "UIApplication+SPAdditions.h"

@implementation UIApplication (SPAdditions)

- (void)safelyOpenUrl:(NSURL *)url success:(void (^)(void))success failure:(void (^)(void))failure
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (success) {
            success();
        }
        [[UIApplication sharedApplication] openURL:url];
    } else {
        if (failure) {
            failure();
        }
    }
}


- (void)safelyOpenUrlString:(NSString *)urlString success:(void (^)(void))success failure:(void (^)(void))failure
{
    [self safelyOpenUrl:[NSURL URLWithString:urlString] success:success failure:failure];
}

@end
