//
//  SPInterstitialHTMLOffer.m
//  SponsorPaySDK
//
//  Created by Johannes Semmler on 08.07.14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPInterstitialHTMLOffer.h"

@interface SPInterstitialHTMLOffer ()

@property (nonatomic, assign, readwrite) SPSSInterstitialType type;

@end

@implementation SPInterstitialHTMLOffer

@synthesize type;

- (instancetype)initWithNetworkName:(NSString *)name
                               adId:(NSString *)adId
                               html:(NSString *)html
                        orientation:(NSString *)orientation
                     trackingParams:(NSDictionary *)trackingParams
                      arbitraryData:(NSDictionary *)dictionary
{
    self = [super initWithNetworkName:name
                                 adId:adId
                          orientation:orientation
                       trackingParams:trackingParams
                        arbitraryData:dictionary];

    if (self) {
        self.html = html;
        NSString *pattern = @"<script\\s+[^>]*\\bsrc\\s*=\\s*([\\\"\\\'])mraid\\.js\\1[^>]*>\\s*</script>\\n*";
        NSError *error = NULL;

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

        NSTextCheckingResult *isMRAID = [regex firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];


        if (isMRAID) {
            self.type = SPSSInterstitialTypeMRAID;
        } else {
            self.type = SPSSInterstitialTypeHTML;
        }
    }

    return self;
}


@end
