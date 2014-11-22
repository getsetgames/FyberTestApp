//
//  SPStoreKitManager.h
//  SponsorPaySDK
//
//  Created by tito on 30/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

typedef void (^SPStoreKitManagerSuccess)(BOOL result, SKStoreProductViewController *productViewController);
typedef void (^SPStoreKitManagerFailure)(NSError *error);
typedef void (^SPStoreKitManagerDidFinish)(SKStoreProductViewController *productViewController);
typedef void (^SPStoreKitManagerDidOpenWithSafari)(NSURL *openedURL);


@interface SPStoreKitManager : NSObject

+ (SPStoreKitManager *)sharedInstance;

/**
 *  Opens the the app specified by its id either in StoreKit or in iTunes depending on what the current iOS version supports
 *
 *  @param appId             The id of the app to open
 *  @param trackingURL       If supplied, a request to the URL will be sent just before opening the app id
 *  @param params            Additional parameters directly passed to the SKStoreProductViewController
 *  @param success           Called when the SKStoreProductViewController loaded the app id with success
 *  @param failure           Called when the SKStoreProductViewController could not load the app id
 *  @param didFinish         Called when the SKStoreProductViewController did finish
 *  @param didOpenWithSafari Called when the app id was opened in iTunes via Safari
 */
- (void)openStoreWithAppId:(NSString *)appId
               trackingURL:(NSURL *) trackingURL
            affiliateToken:(NSString *)affiliateToken
             campaignToken:(NSString *)campaignToken
                   success:(SPStoreKitManagerSuccess)success
                   failure:(SPStoreKitManagerFailure)failure
                 didFinish:(SPStoreKitManagerDidFinish)didFinish
         didOpenWithSafari:(SPStoreKitManagerDidOpenWithSafari)didOpenWithSafari;

@end
