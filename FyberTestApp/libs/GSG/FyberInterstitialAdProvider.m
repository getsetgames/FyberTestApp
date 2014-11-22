//
//  FyberInterstitialAdProvider.m
//  GSG
//
//  Created by Robert Segal on 2014-10-01.
//  Copyright (c) 2014 Get Set Games. All rights reserved.
//

#import "FyberInterstitialAdProvider.h"
#import "GSGAdManager.h"

@implementation FyberInterstitialAdProvider

-(id)init
{
    self = [super init];
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground) name:@"UIApplicationDidEnterBackgroundNotification"
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)cacheAd
{
    self.client = [SponsorPaySDK interstitialClient];
    
    // Assuming self conforms to the SPInterstitialClientDelegate protocol
    //
    ((SPInterstitialClient *)self.client).delegate = self;
    
    [self.client checkInterstitialAvailable];
}

-(BOOL)hasCachedAd
{
    return self.areOffersAvailable;
}

-(BOOL)showAd
{
    if (self.areOffersAvailable)
    {
        [(SPInterstitialClient *)self.client showInterstitialFromViewController:self.viewController];
    }
    
    return YES;
}

-(void)interstitialClient:(SPInterstitialClient *)client canShowInterstitial:(BOOL)canShowInterstitial
{
    self.areOffersAvailable = canShowInterstitial;
}

-(void)interstitialClientDidShowInterstitial:(SPInterstitialClient *)client
{
    [GSGAdManager sharedInstance].adInProgress = YES;
}

-(void)interstitialClient:(SPInterstitialClient *)client didDismissInterstitialWithReason:(SPInterstitialDismissReason)dismissReason
{
    BOOL completed = NO;

    switch (dismissReason)
    {
        case SPInterstitialDismissReasonUnknown:
        case SPInterstitialDismissReasonUserClickedOnAd:
        case SPInterstitialDismissReasonUserClosedAd:
            completed = YES;
            break;
            
        default:
            break;
    }
    
    if (self.delegate)
    {
        [self.delegate adProviderIsHidden:completed status:(GSGGenericAdProviderStatus)dismissReason];
    }
    
    [GSGAdManager sharedInstance].adInProgress = NO;
}

-(void)interstitialClient:(SPInterstitialClient *)client didFailWithError:(NSError *)error
{
    [GSGAdManager sharedInstance].adInProgress = NO;
}

-(void)applicationDidEnterBackground
{
    [self cacheAd];
}


@end
