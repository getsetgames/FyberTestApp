//
//  EbzBanner.h
//  EbuzzingSDK
//
//  Created by Ibrahim Ennafaa on 22/11/2013.
//  Copyright (c) 2013 Ebuzzing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EbzError.h"
#import "EbzLog.h"


@protocol EbzBannerDelegate;

@interface EbzBanner : NSObject

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
/////////////////////////////////////////////////////////////

@property (nonatomic) BOOL isLoaded;

@property (nonatomic) BOOL isExpanded;

@property (nonatomic, weak) UIView *bannerView;

@property (nonatomic, weak) id rootViewController;

@property (nonatomic, weak) id<EbzBannerDelegate> delegate;

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods
#pragma mark -
/////////////////////////////////////////////////////////////

- (id)initWithPlacementTag:(NSString*)placementTag frame:(CGRect)bannerFrame rootViewController:(id)viewController delegate:(id<EbzBannerDelegate>)ebzDelegate;

- (void)load;

- (void)setKeywords:(NSArray *)keywords;

- (NSString*)getPlacementTag;

- (void)forcePlacementTag:(NSString *)placementTag;

- (void)forceCreativeUrl:(NSString*)creativeURL;

@end

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark EbzBanner Delegate
#pragma mark -
/////////////////////////////////////////////////////////////

/**
 * Delegate about EbzBanner object: gives information about EbzBanner lifecycle
 */
@protocol EbzBannerDelegate <NSObject>


@optional

/**
 * Banner Failed to Load
 *
 * @param banner    : the EbzBanner object
 * @param error     : the EbzError object
 */
- (void)ebzBanner:(EbzBanner *)banner didFailLoading:(EbzError *)error;

/**
 * Banner Will Load (loading)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerWillLoad:(EbzBanner *)banner;

/**
 * Banner Did Load (loaded successfully)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerDidLoad:(EbzBanner *)banner;

/**
 * Banner Will Take Over Fullscreen (expanding)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerWillTakeOverFullScreen:(EbzBanner *)banner;

/**
 * Banner Did Take Over Fullscreen (expanded)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerDidTakeOverFullScreen:(EbzBanner *)banner;

/**
 * Banner Will Dismiss Fullscreen (closing)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerWillDismissFullScreen:(EbzBanner *)banner;

/**
 * Banner Did Dismiss Fullscreen (closed)
 *
 * @param banner    : the EbzBanner object
 */
- (void)ebzBannerDidDismissFullScreen:(EbzBanner *)banner;

@end
