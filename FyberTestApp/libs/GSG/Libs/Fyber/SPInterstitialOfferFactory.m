//
//  NSInterstitialOfferFactory.m
//  SponsorPaySDK
//
//  Created by Johannes Semmler on 08.07.14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPInterstitialOfferFactory.h"
#import "SPInterstitialHTMLOffer.h"
#import "SPInterstitialOffer.h"

static NSString *const SPInterstitialOfferJSONKeyProviderType = @"provider_type";
static NSString *const SPInterstitialOfferJSONKeyAdId = @"ad_id";
static NSString *const SPInterstitialOfferJSONKeyHTML = @"html";
static NSString *const SPInterstitialOfferJSONKeyOrientation = @"orientation";
static NSString *const SPInterstitialOfferJSONKeyTrackingParams = @"tracking_params";

// TODO: Update key when backend is ready
static NSString *const SPInterstitialOfferJSONKeyBackgroundTracking = @"background_tracking_enabled";
static NSString *const SPInterstitialOfferJSONKeyAppId = @"app_id";


@implementation SPInterstitialOfferFactory

+ (SPInterstitialOffer *)interstitialOfferWithDictionary:(NSDictionary *)dictionary
{
    SPInterstitialOffer *interstitialOffer = nil;
    NSString *networkName = dictionary[SPInterstitialOfferJSONKeyProviderType];
    NSString *adId = dictionary[SPInterstitialOfferJSONKeyAdId];
    NSString *html = dictionary[SPInterstitialOfferJSONKeyHTML];
    NSString *orientation = dictionary[SPInterstitialOfferJSONKeyOrientation];
    NSDictionary *trackingParams = dictionary[SPInterstitialOfferJSONKeyTrackingParams];
    NSDictionary *offerExtras = dictionary;

    // look if we have any html content
    if (html.length > 0) {
        interstitialOffer = [[SPInterstitialHTMLOffer alloc] initWithNetworkName:networkName
                                                                            adId:adId
                                                                            html:html
                                                                     orientation:orientation
                                                                  trackingParams:trackingParams
                                                                   arbitraryData:offerExtras];
    } else {
        interstitialOffer = [[SPInterstitialOffer alloc] initWithNetworkName:networkName
                                                                        adId:adId
                                                                 orientation:orientation
                                                              trackingParams:trackingParams
                                                               arbitraryData:offerExtras];
    }

    return interstitialOffer;
}

@end
