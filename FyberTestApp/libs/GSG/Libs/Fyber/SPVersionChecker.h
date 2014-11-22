//
//  SPVersionChecker.h
//  SponsorPaySDK
//
//  Created by tito on 20/08/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SPFoundationVersionNumber [SPVersionChecker overridenVersion]

#ifndef NSFoundationVersionNumber_iOS_7_0
#define NSFoundationVersionNumber_iOS_7_0 1047.20
#endif

#ifndef NSFoundationVersionNumber_iOS_7_1
#define NSFoundationVersionNumber_iOS_7_1 1047.25
#endif

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_iOS_8_0 1134.10
#endif

@interface SPVersionChecker : NSObject

+ (CGFloat)overridenVersion;
+ (void)setOverridenVersion:(NSString *)overridenVersion;

@end
