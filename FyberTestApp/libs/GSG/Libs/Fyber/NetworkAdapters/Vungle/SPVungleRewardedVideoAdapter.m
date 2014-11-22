//
//  SPVungleAdapter.m
//  SponsorPay iOS SDK
//
//  Created by David Davila on 5/30/13.
// Copyright 2011-2013 SponsorPay. All rights reserved.
//

#import "SPVungleRewardedVideoAdapter.h"
#import "SPVungleNetwork.h"
#import "SPLogger.h"

#define LogInvocation SPLogDebug(@"%s", __PRETTY_FUNCTION__)

@interface SPVungleRewardedVideoAdapter()

@property (assign) BOOL videoDidPlayFull;
@property (copy) SPTPNVideoEventsHandlerBlock videoEventsCallback;

- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)sendCloseEvent;

@end

@implementation SPVungleRewardedVideoAdapter

- (BOOL)startAdapterWithDictionary:(NSDictionary *)dict
{
    return YES;
}

- (NSString *)networkName
{
    return self.network.name;
}

- (void)videosAvailable:(SPTPNValidationResultBlock)callback
{
    BOOL isVideoAvailable = [[VungleSDK sharedSDK] isCachedAdAvailable];
    
    SPTPNValidationResult validationResult = isVideoAvailable ? SPTPNValidationSuccess : SPTPNValidationNoVideoAvailable;

    callback(self.networkName, validationResult);
}

- (void)playVideoWithParentViewController:(UIViewController *)parentVC
                        notifyingCallback:(SPTPNVideoEventsHandlerBlock)eventsCallback
{
    self.videoDidPlayFull = NO;
    self.videoEventsCallback = eventsCallback;
    [[VungleSDK sharedSDK] setDelegate:self];
    
    //additional configuration
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (self.network.orientation.length) {
        [options setObject:@(self.network.orientationMask) forKey:VunglePlayAdOptionKeyOrientations];
    }
    if (self.network.showClose) {
        [options setObject:self.network.showClose forKey:VunglePlayAdOptionKeyShowClose];
    }
    
    [[VungleSDK sharedSDK] playAd:parentVC withOptions:options];
}

#pragma mark - VGVunglePubDelegate protocol implementation

// Called immeddiately before Vungle's ad view controller appears.
// It's the closest we have to the video started event
- (void)vungleSDKwillShowAd
{
    LogInvocation;
    
    self.videoEventsCallback(self.networkName, SPTPNVideoEventStarted);
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    LogInvocation;

    self.videoDidPlayFull = [viewInfo[@"completedView"] boolValue];

    SPTPNVideoEvent event = self.videoDidPlayFull ? SPTPNVideoEventFinished : SPTPNVideoEventAborted;
    self.videoEventsCallback(self.networkName, event);
    
    if (willPresentProductSheet) {
        //register for UIApplicationWillResignActiveNotification notification
        //reason: when the ProductSheet is displayed and the app is minimized the vungleSDKwillCloseProductSheet method is never called
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    } else {
        [self sendCloseEvent];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    LogInvocation;
    
    [self sendCloseEvent];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    LogInvocation;
    
    //unregister from UIApplicationWillResignActiveNotification notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [self sendCloseEvent];
}

- (void)sendCloseEvent
{
    LogInvocation;

    if (self.videoDidPlayFull) {
        self.videoEventsCallback(self.networkName, SPTPNVideoEventClosed);
    }
    [[VungleSDK sharedSDK] setDelegate:nil];
}

@end
