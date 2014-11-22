//
//  SPFyberInterstitialAdapter.m
//  NetworkAdapters
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 sponsorpay. All rights reserved.
//

#import "SPFyberInterstitialAdapter.h"
#import "SPFyberNetwork.h"
#import "SPSSInterstitialClient.h"
#import "SPInterstitialOffer.h"
#import "SPSSInterstitialDelegate.h"
#import "SPLogger.h"
#import "SPInterstitialOfferFactory.h"


@interface SPFyberInterstitialAdapter ()<SPSSInterstitialDelegate>

@property (nonatomic, strong) NSString *contentHTML;
@property (nonatomic, strong) SPSSInterstitialClient *interstitialClient;

@property (nonatomic, weak) id<SPInterstitialNetworkAdapterDelegate> delegate;

@end


@implementation SPFyberInterstitialAdapter

@synthesize offerData;

- (id)init
{
    self = [super init];

    if (self) {
        self.interstitialClient = [[SPSSInterstitialClient alloc] init];
        self.interstitialClient.delegate = self;
    }

    return self;
}

- (NSString *)networkName
{
    return [self.network name];
}


- (BOOL)startAdapterWithDict:(NSDictionary *)dict
{
    return YES;
}


#pragma mark - SPInterstitialNetworkAdapter protocol

- (BOOL)canShowInterstitial
{
    if (!self.offerData) {
        return NO;
    }

    SPInterstitialOffer *interstitial = [SPInterstitialOfferFactory interstitialOfferWithDictionary:self.offerData];

    [self.interstitialClient cacheInterstitial:interstitial];

    return YES;
}


- (void)showInterstitialFromViewController:(UIViewController *)viewController
{
    if (!self.interstitialClient.interstitialAvailable) {
        NSError *error = [NSError errorWithDomain:@"SPInterstitialDomain" code:-8 userInfo:@{ NSLocalizedDescriptionKey: @"No interstitial available" }];

        if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:didFailWithError:)]) {
            [self.delegate adapter:self didFailWithError:error];
        }

        return;
    }

    [self.interstitialClient showInterstitialFromViewController:viewController];
}


#pragma mark - SPSSInterstitialDelegate

- (void)interstitial:(SPInterstitialOffer *)offer didFailToLoadAdWithError:(NSError *)error
{
    LogInvocation;
    [self.delegate adapter:self didFailWithError:error];
}

- (void)interstitialDidPresentScreen:(SPInterstitialOffer *)offer
{
    LogInvocation;
    [self.delegate adapterDidShowInterstitial:self];
}

- (void)interstitialDidDismissScreen:(SPInterstitialOffer *)offer
{
    LogInvocation;
    [self.delegate adapter:self didDismissInterstitialWithReason:SPInterstitialDismissReasonUserClosedAd];
}

- (void)interstitialWillLeaveApplication:(SPInterstitialOffer *)offer
{
    LogInvocation;
    [self.delegate adapter:self didDismissInterstitialWithReason:SPInterstitialDismissReasonUserClickedOnAd];
}

@end
