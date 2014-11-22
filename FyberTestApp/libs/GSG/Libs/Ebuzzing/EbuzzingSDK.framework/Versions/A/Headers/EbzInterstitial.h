//
//  EbzInterstitialViewController.h
//  EbuzzingSDKDemo
//
//  Created by Ibrahim Ennafaa on 27/11/2013.
//  Copyright (c) 2013 Ebuzzing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EbzRewardInfo.h"
#import "EbzError.h"
#import "EbzLog.h"

@protocol EbzInterstitialDelegate;

@interface EbzInterstitial : UIViewController

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
/////////////////////////////////////////////////////////////

@property (nonatomic) BOOL isHidden;

@property (nonatomic) BOOL isClosed;

@property (nonatomic) BOOL isLoaded;

@property (nonatomic, weak) id rootViewController;

@property (nonatomic, weak) id<EbzInterstitialDelegate> delegate;

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods
#pragma mark -
/////////////////////////////////////////////////////////////

- (id)initWithPlacementTag:(NSString*)pTag rootViewController:(id)viewController delegate:(id<EbzInterstitialDelegate>)ebzDelegate;

- (void)load;

- (void)show;

- (void)setRewardEnabled:(BOOL)enabled;

- (BOOL)isRewardEnabled;

- (void)setRewardInfo:(NSString*)userId withDebug:(BOOL)debug;

- (EbzRewardInfo *)getRewardInfo;

- (void)setKeywords:(NSArray *)keywords;

- (NSString*)getPlacementTag;

- (void)forcePlacementTag:(NSString *)placementTag;

- (void)forceCreativeUrl:(NSString*)creativeURL;

@end

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark EbzInterstitial Delegate
#pragma mark -
/////////////////////////////////////////////////////////////

/**
 * Delegate about EbzInterstitial object: set the viewController responsible of modal presentation
 * and gives information about EbzInterstitial lifecycle
 */
@protocol EbzInterstitialDelegate <NSObject>

@required

/**
 * Mandatory: return the viewController that will be used for modal presentation
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (UIViewController*)viewControllerForModalPresentation:(EbzInterstitial *)interstitial;

@optional

/**
 * Interstitial Failed to Load
 *
 * @param interstitial  : the EbzInterstitial object
 * @param error         : the EbzError object
 */
- (void)ebzInterstitial:(EbzInterstitial *)interstitial didFailLoading:(EbzError *)error;

/**
 * Interstitial Will Load (loading)
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialWillLoad:(EbzInterstitial *)interstitial;

/**
 * Interstitial Did Load (loaded successfully)
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialDidLoad:(EbzInterstitial *)interstitial;

/**
 * Interstitial Will Take Over Fullscreen (showing)
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialWillTakeOverFullScreen:(EbzInterstitial *)interstitial;

/**
 * Interstitial Did Take Over Fullscreen (shown)
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialDidTakeOverFullScreen:(EbzInterstitial *)interstitial;

/**
 * Interstitial Will Dismiss Fullscreen (closing)
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialWillDismissFullScreen:(EbzInterstitial *)interstitial;

/**
 * Interstitial Did Dismiss Fullscreen (closed)
 *
 * @param interstitial The EbzInterstitial object
 */
- (void)ebzInterstitialDidDismissFullScreen:(EbzInterstitial *)interstitial;

/**
 * Interstitial Unlocked Reward
 *
 * @param interstitial  : the EbzInterstitial object
 */
- (void)ebzInterstitialRewardUnlocked:(EbzInterstitial *)interstitial;

@end