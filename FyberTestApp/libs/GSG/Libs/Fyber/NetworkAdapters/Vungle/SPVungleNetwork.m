//
//  SPVungleProvider.m
//  SponsorPayTestApp - Vungle Adapter v.2.1.0
//
//  Created by Daniel Barden on 13/01/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPVungleNetwork.h"
#import "SPVungleRewardedVideoAdapter.h"
#import "SPLogger.h"
#import "SPSemanticVersion.h"
#import "SPConstants.h"

static NSString *const SPVungleAppId = @"SPVungleAppId";
static NSString *const SPVungleOrientation = @"SPVungleOrientation";
static NSString *const SPVungleShowClose = @"SPVungleShowClose";

static const NSInteger SPVungleVersionMajor = 2;
static const NSInteger SPVungleVersionMinor = 1;
static const NSInteger SPVungleVersionPatch = 0;

// Screen orientation Constatns
NSString *const SPVungleInterfaceOrientationMaskPortrait = @"portrait";
NSString *const SPVungleInterfaceOrientationMaskLandscapeLeft = @"landscapeLeft";
NSString *const SPVungleInterfaceOrientationMaskLandscapeRight = @"landscapeRight";
NSString *const SPVungleInterfaceOrientationMaskPortraitUpsideDown = @"portraitUpsideDown";
NSString *const SPVungleInterfaceOrientationMaskLandscape = @"landscape";
NSString *const SPVungleInterfaceOrientationMaskAll = @"all";
NSString *const SPVungleInterfaceOrientationMaskAllButUpsideDown = @"allButUpsideDown";


@interface SPVungleNetwork()

@property (nonatomic, assign) SPNetworkSupport supportedServices;
@property (nonatomic, copy) NSString *providerName;
@property (nonatomic, strong) SPVungleRewardedVideoAdapter *rewardedVideoAdapter;

@end

@implementation SPVungleNetwork

@synthesize supportedServices;
@synthesize rewardedVideoAdapter;

#pragma mark - Class Methods

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion versionWithMajor:SPVungleVersionMajor minor:SPVungleVersionMinor patch:SPVungleVersionPatch];
}


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rewardedVideoAdapter = [[SPVungleRewardedVideoAdapter alloc] init];
    }
    return self;
}


- (BOOL)startSDK:(NSDictionary *)data
{
    NSString *appId = data[SPVungleAppId];

    if (!appId.length) {
        SPLogError(@"Could not start %@ Provider. %@ empty or missing.", self.name, SPVungleAppId);
        return NO;
    }
    
    self.orientation = data[SPVungleOrientation];
    self.showClose = data[SPVungleShowClose];

    self.appId = appId;
    [[VungleSDK sharedSDK] startWithAppId:self.appId];
    return YES;
}

#pragma mark - Helper methods

- (UIInterfaceOrientationMask)orientationMask
{
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskPortrait]) return UIInterfaceOrientationMaskPortrait;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskLandscapeLeft]) return UIInterfaceOrientationMaskLandscapeLeft;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskLandscapeRight]) return UIInterfaceOrientationMaskLandscapeRight;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskPortraitUpsideDown]) return UIInterfaceOrientationMaskPortraitUpsideDown;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskLandscape]) return UIInterfaceOrientationMaskLandscape;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskAll]) return UIInterfaceOrientationMaskAll;
    if ([self.orientation isEqualToString:SPVungleInterfaceOrientationMaskAllButUpsideDown]) return UIInterfaceOrientationMaskAllButUpsideDown;
    return UIInterfaceOrientationMaskAll;
}

@end
