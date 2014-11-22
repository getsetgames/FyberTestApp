//
//  SPFyberNetwork.m
//  NetworkAdapters
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 sponsorpay. All rights reserved.
//

// Adapter versioning - Remember to update the header

#import "SPFyberNetwork.h"
#import "SPFyberInterstitialAdapter.h"
#import "SPSemanticVersion.h"

static const NSInteger SPFyberVersionMajor = 3;
static const NSInteger SPFyberVersionMinor = 0;
static const NSInteger SPFyberVersionPatch = 0;

@interface SPFyberNetwork ()

@property (strong, nonatomic) SPFyberInterstitialAdapter *interstitialAdapter;

@end

@implementation SPFyberNetwork

@synthesize interstitialAdapter = _interstitialAdapter;


#pragma mark - Class Methods

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion versionWithMajor:SPFyberVersionMajor
                                         minor:SPFyberVersionMinor
                                         patch:SPFyberVersionPatch];
}


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self) {
        _interstitialAdapter = [[SPFyberInterstitialAdapter alloc] init];
    }
    return self;
}


#pragma mark - Private

- (BOOL)startSDK:(NSDictionary *)data
{
    return YES;
}


- (void)startInterstitialAdapter:(NSDictionary *)data
{
    [super startInterstitialAdapter:data];
}

@end
