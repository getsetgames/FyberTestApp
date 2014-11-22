//
//  GSGCocos2d.h
//  Mega Jump
//
//  Created by Derek van Vliet on 10-12-14.
//  Copyright 2010 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RootViewController.h"

#define GSGScreenConnectedNotification    @"GSGScreenConnectedNotification"
#define GSGScreenDisconnectedNotification @"GSGScreenDisconnectedNotification"
#define GSGScreenModeChangedNotification  @"GSGScreenModeChangedNotification"

#define GSG_IPAD_TO_RETINA_SCALE (1)

@interface GSGRootNavigationController : UINavigationController
@end


@interface GSGCocos2d : NSObject <UINavigationControllerDelegate,CCProjectionProtocol> {
	UIWindow *window;

	CGRect originalBounds;
	
	RootViewController     *viewController;
	UINavigationController *navigationController;
	
	EAGLView    *glView;
    
	CGFloat sceneScale;
	BOOL    tvOut;	
    BOOL initialized;
    NSString *launchedURL;
    
    CGFloat avgFPS;
    
	NSUInteger frames_;
	ccTime accumDt_;
	ccTime frameRate_;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) RootViewController *viewController;
@property (readonly) UINavigationController *navigationController;
@property (readonly) BOOL initialized;
@property (nonatomic, copy) NSString *launchedURL;

@property (readonly) CGRect originalBounds;
@property (readonly) CGFloat sceneScale;
@property (readonly) BOOL tvOut;

@property (readonly) CGFloat avgFPS;

+(GSGCocos2d*)sharedInstance;

/// Window size in points. Use this instead of CCDirector winSize.
+(CGSize)winSize;
+(CGSize)winSizeInPixels;

-(void)initDisplays;
-(void)initCocos2d;
-(void)setExternalDisplay:(UIScreen*)screen;

-(void)screenConnected:(id)obj;
-(void)screenDisconnected:(id)obj;
-(void)screenModeChanged:(id)obj;

-(void)updateAvgFPS:(ccTime)dt;
-(void)resetAvgFPS;
+(BOOL) hasInternet;

+(BOOL)isDeviceWideScreen;

@end

@interface CCTexture2D (Trilinear)
-(void)setTrilinearTexParameters;
@end

