//
//  SPSSInterstitialsState.h
//  SponsorPaySDK
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#ifndef SponsorPaySDK_SPInterstitialType_h
#define SponsorPaySDK_SPInterstitialType_h

typedef NS_ENUM(NSInteger, SPSSInterstitialType) {
    // HTML
    SPSSInterstitialTypeMRAID,
    SPSSInterstitialTypeHTML,

    // Only one Image and one link https://github.com/SponsorPay/requirements/blob/master/interstitial/marketplace/v1/v1_ams.md
    SPSSInterstitialTypeImageAndLink
};

#endif
