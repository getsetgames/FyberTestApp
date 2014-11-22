//
//  NSInterstitialOfferFactory.h
//  SponsorPaySDK
//
//  Created by Johannes Semmler on 08.07.14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPInterstitialOffer;

@interface SPInterstitialOfferFactory : NSObject

+ (SPInterstitialOffer *)interstitialOfferWithDictionary:(NSDictionary *)dictionary;

@end
