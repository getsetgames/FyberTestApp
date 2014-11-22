//
//  GSGGenericAdProvider.h
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *kAdProviderIsHiddenNotification;
extern NSString *kAdProviderDidCacheAdNotification;
extern NSString *kAdProviderShowAdNotification;
extern NSString *kAdProviderAwardVirtualCurrencyRewardNotification;

typedef enum {
    GSG_AD_PROVIDER_STATUS_STARTED = 0,
    GSG_AD_PROVIDER_STATUS_CLOSE_FINISHED,
    GSG_AD_PROVIDER_STATUS_CLOSE_ABORTED,
    GSG_AD_PROVIDER_STATUS_ERROR
} GSGGenericAdProviderStatus;

@protocol GSGGenericAdProviderDelegate

@optional
-(void)adProviderWillHide;
-(void)adProviderIsHidden:(NSDictionary *)userInfo;
-(void)adProviderAwardVirtualCurrencyReward:(NSNotification *)userInfo;
-(void)adProviderShowAd:(NSDictionary *)userInfo;
-(void)adProviderDidCacheAd:(NSDictionary *)userInfo;

@end


@interface GSGGenericAdProvider : NSObject
{
  //NSDictionary* videoHooks;
}

-(BOOL)showAd;
-(BOOL)hasCachedAd;
-(BOOL)canRequestAd;
-(void)cacheAd;
-(void)initialize;
//-(NSString*)translatedHook;

//@property (nonatomic, retain) NSString *currentHook;
//@property (nonatomic, retain) UIView *view;
@property (nonatomic, readwrite, retain) UIViewController *viewController;
@property (nonatomic, readwrite, copy) NSString  *currencyID;
//@property (nonatomic, retain) NSDictionary* videoHooks;

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id userData;
//@property (nonatomic, retain) id protocolDelegate;

-(BOOL)canShowInterstitial:(BOOL)firstRun;
-(void)flush;
-(void)clearRequests;

@end


