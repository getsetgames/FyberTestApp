//
//  SPInterstitialHTMLOffer.h
//  SponsorPaySDK
//
//  Created by Johannes Semmler on 08.07.14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPInterstitialOffer.h"

@interface SPInterstitialHTMLOffer : SPInterstitialOffer

@property (nonatomic, strong) NSString *html;

- (instancetype)initWithNetworkName:(NSString *)name
                               adId:(NSString *)adId
                               html:(NSString *)html
                        orientation:(NSString *)orientation
                     trackingParams:(NSDictionary *)trackingParams
                      arbitraryData:(NSDictionary *)dictionary;


@end
