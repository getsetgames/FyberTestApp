//
//  SPInterstitialOffer.h
//  SponsorPayTestApp
//
//  Created by David Davila on 27/10/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSSInterstitialType.h"

@interface SPInterstitialOffer : NSObject

@property (nonatomic, strong, readonly) NSString *networkName;
@property (nonatomic, strong, readonly) NSString *adId;
@property (nonatomic, strong, readonly) NSDictionary *arbitraryData;
@property (nonatomic, strong, readonly) NSDictionary *trackingParams;
@property (nonatomic, strong, readonly) NSString *orientation;
@property (nonatomic, assign, readonly) SPSSInterstitialType type;

- (instancetype)initWithNetworkName:(NSString *)name
                               adId:(NSString *)adId
                        orientation:(NSString *)orientation
                     trackingParams:(NSDictionary *)trackingParams
                      arbitraryData:(NSDictionary *)dictionary;

#pragma mark - Helpers

- (BOOL)isLandscape;
- (BOOL)isPortrait;
- (BOOL)isOrientationSupported;

@end
