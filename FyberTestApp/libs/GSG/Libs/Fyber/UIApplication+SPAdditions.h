//
//  UIApplication+SPAdditions.h
//  SponsorPaySDK
//
//  Created by tito on 29/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (SPAdditions)

- (void)safelyOpenUrl:(NSURL *)url success:(void (^)(void))success failure:(void (^)(void))failure;
- (void)safelyOpenUrlString:(NSString *)urlString success:(void (^)(void))success failure:(void (^)(void))failure;

@end
