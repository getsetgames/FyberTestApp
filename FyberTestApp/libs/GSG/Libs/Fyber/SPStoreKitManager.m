//
//  SPStoreKitManager.m
//  SponsorPaySDK
//
//  Created by tito on 30/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPStoreKitManager.h"
#import "SPLogger.h"
#import "SPVersionChecker.h"

// TODO: These variables are defined with the values of SPStoreProductParameterAffiliateToken and
// SPStoreProductParameterCampaignToken. Remove these values and use the official ones once we can assume that
// iOS 8 is used as base SDK. Hopefully, soon.
static NSString *const SPStoreProductParameterAffiliateToken = @"at";
static NSString *const SPStoreProductParameterCampaignToken = @"ct";

@interface SPStoreKitManager ()<SKStoreProductViewControllerDelegate>

@property (nonatomic, copy, readwrite) SPStoreKitManagerDidFinish didFinish;

@end


@implementation SPStoreKitManager

+ (SPStoreKitManager *)sharedInstance
{
    static SPStoreKitManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPStoreKitManager alloc] init];
    });

    return sharedInstance;
}


#pragma mark -

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (void)openStoreWithAppId:(NSString *)appId
               trackingURL:(NSURL *) trackingURL
            affiliateToken:(NSString *)affiliateToken
             campaignToken:(NSString *)campaignToken
                   success:(SPStoreKitManagerSuccess)success
                   failure:(SPStoreKitManagerFailure)failure
                 didFinish:(SPStoreKitManagerDidFinish)didFinish
         didOpenWithSafari:(SPStoreKitManagerDidOpenWithSafari)didOpenWithSafari
{
    [self handleTrackingURL:trackingURL];
    
    // If StoreKit not present: Open Safari and call didOpenWithSafari callback
    if (![SKStoreProductViewController class]) {
        NSURL *offerURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appId]];
        [[UIApplication sharedApplication] openURL:offerURL];
        if (didOpenWithSafari) {
            didOpenWithSafari(offerURL);
        }
        return;
    }

    SPLogDebug(@"Opening StoreKit with App Id: %@", appId);
    SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
    productViewController.delegate = self;

    self.didFinish = didFinish;

    NSMutableDictionary *mutableParams = [@{ SKStoreProductParameterITunesItemIdentifier:appId } mutableCopy];

    if (SPFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {

        if (!affiliateToken) {
            affiliateToken = @"";
        }

        if (!campaignToken) {
            campaignToken = @"";
        }

        NSDictionary *params = @{
                                 SPStoreProductParameterAffiliateToken:affiliateToken,
                                 SPStoreProductParameterCampaignToken:campaignToken
                                 };

        [mutableParams addEntriesFromDictionary:params];
    }

    // loadProductWithParameters never completes on the Simulator so fake it here
#if (TARGET_IPHONE_SIMULATOR)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        dispatch_async(dispatch_get_main_queue(), ^{
        success(YES, productViewController);
        });
    });
#endif

    [productViewController loadProductWithParameters:mutableParams completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            failure(error);
            return;
        }

        success(result, productViewController);
    }];
}
#pragma clang diagnostic pop


#pragma mark - SKStoreProductViewControllerDelegate


- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    if (self.didFinish) {
        self.didFinish(viewController);
        self.didFinish = nil;
    }
}

#pragma mark - Private Helpers

/**
 *  Just sends a async request to the URL if not nil
 */
- (void)handleTrackingURL:(NSURL *)trackingURL {
  if (trackingURL) {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:trackingURL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:nil];
  }
}

@end
