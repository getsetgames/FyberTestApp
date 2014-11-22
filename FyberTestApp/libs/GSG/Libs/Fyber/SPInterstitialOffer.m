//
//  SPInterstitialOffer.m
//  SponsorPayTestApp
//
//  Created by David Davila on 27/10/13.
//  Copyright (c) 2013 SponsorPay. All rights reserved.
//

#import "SPInterstitialOffer.h"
#import "UIInterfaceOrientation+SPAdditions.h"

@interface SPInterstitialOffer ()

@property (nonatomic, strong, readwrite) NSString *networkName;
@property (nonatomic, strong, readwrite) NSString *adId;
@property (nonatomic, strong, readwrite) NSDictionary *arbitraryData;
@property (nonatomic, strong, readwrite) NSDictionary *trackingParams;
@property (nonatomic, strong, readwrite) NSString *orientation;
@property (nonatomic, assign, readwrite) SPSSInterstitialType type;

@end

static NSString *const SPInterstitialOrientationLandscape = @"landscape";
static NSString *const SPInterstitialOrientationPortrait = @"portrait";

@implementation SPInterstitialOffer

- (instancetype)initWithNetworkName:(NSString *)name
                               adId:(NSString *)adId
                        orientation:(NSString *)orientation
                     trackingParams:(NSDictionary *)trackingParams
                      arbitraryData:(NSDictionary *)dictionary
{
    self = [super init];

    if (self) {
        self.networkName = name;
        self.adId = adId;
        self.arbitraryData = dictionary;
        self.trackingParams = trackingParams ? trackingParams : @{};
        self.orientation = orientation;
    }

    return self;
}

#pragma mark - Helpers

- (BOOL)isLandscape
{
    return [self.orientation isEqualToString:SPInterstitialOrientationLandscape];
}


- (BOOL)isPortrait
{
    return [self.orientation isEqualToString:SPInterstitialOrientationPortrait];
}

- (BOOL)isOrientationSupported
{
    if (self.orientation) {
        if ([self isPortrait]) {
            return UIInterfaceOrientationIsSupported(UIInterfaceOrientationPortrait);
        } else if ([self isLandscape]) {
            return UIInterfaceOrientationIsSupported(UIInterfaceOrientationLandscapeRight);
        }
    }

    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Network: %@ - Ad id: @ - Data: %@", self.networkName, self.arbitraryData];
}

@end
