//
//  GSGAdManager.m
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import "GSGGenericAdProvider.h"

NSString *kAdProviderIsHiddenNotification        = @"AdProvider_IsHidden_Notification";
NSString *kAdProviderDidCacheAdNotification      = @"AdProvider_DidCacheAd_Notification";
NSString *kAdProviderShowAdNotification          = @"AdProvider_ShowAd_Notification";
NSString *kAdProviderAwardVirtualCurrencyRewardNotification  = @"AdProvider_AwardVirtualCurrencyReward_Notification";

@implementation GSGGenericAdProvider

//@synthesize videoHooks;
//@synthesize currentHook;
//@synthesize view;
//@synthesize delegate;
//@synthesize protocolDelegate;

-(BOOL)showAd { return NO; }

-(BOOL)hasCachedAd { return NO; }

-(BOOL)canRequestAd { return NO; }

-(void)cacheAd { }

-(void)initialize { }

//-(NSString*)translatedHook
//{
//  return [self.videoHooks objectForKey:currentHook];
//}

- (void)dealloc
{
//  [videoHooks release];
//  [currentHook release];
//  [view release];
    self.viewController = nil;
    self.delegate = nil;
    
//  [delegate release];
//  [protocolDelegate release];

  [super dealloc];
}

-(BOOL)canShowInterstitial:(BOOL)firstRun
{
    return NO;
}

-(void)flush
{
    // Can be used by derived classes to flush any server awards that might be used scrupulously
}

-(void)clearRequests
{
    // Can be used to cancel/clear active ad requests that hasn't finished asynchronously and you don't want
    // it causing trouble popping up later on
}


@end
