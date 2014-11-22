//
//  GSGCocos2d.m
//  Mega Jump
//
//  Created by Derek van Vliet on 10-12-14.
//  Copyright 2010 Get Set Games. All rights reserved.
//

#import "GSGCocos2d.h"
#import "Singleton.h"
#import "cocos2d.h"
#import "GSGEAGLView.h"

@implementation GSGRootNavigationController

// iOS < 6.0 //
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

// iOS > 6.0 //
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    if ([[GSGCocos2d sharedInstance] initialized] && ([GSGCocos2d sharedInstance].viewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight || [GSGCocos2d sharedInstance].viewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
    {
        return [GSGCocos2d sharedInstance].viewController.interfaceOrientation;
    }
    return UIInterfaceOrientationLandscapeRight;
}

@end

@implementation GSGCocos2d

@synthesize window;
@synthesize viewController;
@synthesize navigationController;
@synthesize sceneScale;
@synthesize tvOut;
@synthesize originalBounds;
@synthesize initialized;
@synthesize avgFPS;
@synthesize launchedURL;

#if INCLUDE_RUNTIME_TOOLS == 1
@synthesize statsWindow;
#endif

CLASS_SINGLETON(GSGCocos2d)

-(id) init
{
    self = [super init];
    if (self)
    {
        launchedURL = nil;
    }
    return self;
}

-(void)initDisplays {
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
		
	[self initCocos2d];
}

-(void)initCocos2d 
{
	sceneScale = 1;

	originalBounds = [[UIScreen mainScreen] bounds];
	
	window = [[UIWindow alloc] initWithFrame:originalBounds];

	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeNSTimer];
	CCDirector *dir = [CCDirector sharedDirector];
    dir.projectionDelegate = self;
    [dir setProjection:kCCDirectorProjectionCustom];
  
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[dir setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[dir setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
//	[dir setDisplayFPS:YES];

#if GSG_FPS_60
	[dir setAnimationInterval:1.0/60];
#elif GSG_FPS_30
	[dir setAnimationInterval:1.0/30];
#else
	[dir setAnimationInterval:1.0/30];
#endif
    
	glView = [GSGEAGLView viewWithFrame:[window bounds]
						 pixelFormat:kEAGLColorFormatRGB565
						 depthFormat:0
			  ];

    [glView setMultipleTouchEnabled:NO];

	[dir setOpenGLView:glView];
	
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
#if INCLUDE_RUNTIME_TOOLS == 1
    statsWindow                = [[StatsWindow alloc] initWithNibName:@"StatsWindow" bundle:nil];
    statsWindow.view.hidden    = YES;
    statsWindow.view.center    = CGPointMake(statsWindow.view.frame.size.width / 2.0f, statsWindow.view.frame.size.height / 2.0f);    
    glView.autoresizesSubviews = NO;
    
    [statsWindow showHideHUD];
    
    [glView addSubview:statsWindow.view];
#endif
    
	navigationController = [[GSGRootNavigationController alloc] initWithRootViewController:viewController];
	navigationController.navigationBar.hidden = YES;
    navigationController.delegate = self;
	
	[viewController setView:glView];

    if ([window respondsToSelector:@selector(setRootViewController:)]) {
        [window setRootViewController:navigationController];
    }
    else {
        [window addSubview:navigationController.view];
    }

	[window makeKeyAndVisible];
        
    initialized = YES;
}

-(void)dealloc
{
#if INCLUDE_RUNTIME_TOOLS == 1
    [statsWindow release];
#endif
    
    [viewController release];
    [navigationController release];
    [window release];
    
    [super dealloc];
}

-(void)setExternalDisplay:(UIScreen*)screen {

}

-(void)screenConnected:(id)obj {

}

-(void)screenDisconnected:(id)obj {
	sceneScale = 1;

	// resize gl view
	[glView setFrame:[window bounds]];
	glView.center = window.center;
	
	[glView removeFromSuperview];
	[window addSubview:glView];

	[viewController.view removeFromSuperview];
	[window addSubview:viewController.view];

	[window makeKeyAndVisible];	

	tvOut = NO;

	[[NSNotificationCenter defaultCenter] postNotificationName:GSGScreenDisconnectedNotification object:nil];
}

-(void)screenModeChanged:(id)obj {
	UIScreen *screen = [obj object];
	[self setExternalDisplay:screen];

	[[NSNotificationCenter defaultCenter] postNotificationName:GSGScreenModeChangedNotification object:nil];
}

- (void)navigationController:(UINavigationController *)nController willShowViewController:(UIViewController *)vController animated:(BOOL)animated
{

}

-(void)updateProjection {
    CGSize size = [[CCDirector sharedDirector] winSizeInPixels];
    
    glViewport(0, 0, size.width, size.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60, (GLfloat)size.width/size.height, 0.5f, 3000.0f * [CCDirector sharedDirector].contentScaleFactor);
    
    glMatrixMode(GL_MODELVIEW);	
    glLoadIdentity();
    gluLookAt( size.width/2, size.height/2, [[CCDirector sharedDirector] getZEye],
              size.width/2, size.height/2, 0,
              0.0f, 1.0f, 0.0f);
}

+(CGSize)winSize
{
    // @hack: The way we're doing our iPad retina scaling currently breaks CCDirector winSize. Use this instead.
    
    CGSize winSizePt;
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        winSizePt = [[CCDirector sharedDirector] winSize];    
    }
    else
    {
        winSizePt.width = 512.f;
        winSizePt.height = 384.f;
    }
    return winSizePt;
}

+(CGSize)winSizeInPixels
{
    CGSize winSizePt = [GSGCocos2d winSize];
    CGSize winSizePx;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        winSizePx.width = 2.f * winSizePt.width;
        winSizePx.height = 2.f * winSizePt.height;
    }
    else
    {
        winSizePx = [[CCDirector sharedDirector] winSizeInPixels];
    }
    return winSizePx;
}

+(BOOL) hasInternet
{
    return NO;
}

-(void)updateAvgFPS:(ccTime)dt
{    
	frames_++;
	accumDt_ += dt;
	
	if ( accumDt_ > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate_ = frames_/accumDt_;
		frames_ = 0;
		accumDt_ = 0;
		
		avgFPS = (avgFPS + frameRate_) / 2;
	}
}

-(void)resetAvgFPS
{
	avgFPS = 0.0f;
}

+(BOOL)isDeviceWideScreen
{
    CGRect b = CGRectZero;
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 )
    {
        b = [UIScreen mainScreen].bounds;
    }
    else
    {
        b = [UIScreen mainScreen].nativeBounds;
        
        b.size.width  *= (3.0f / [UIScreen mainScreen].nativeScale);
        b.size.height *= (3.0f / [UIScreen mainScreen].nativeScale);
        
        b.size.width  *= 0.5f;
        b.size.height *= 0.5f;
    }

    return fabs((double)b.size.height - (double)568) < DBL_EPSILON ||
           fabs((double)b.size.height - (double)852) < DBL_EPSILON;
}

@end

@implementation CCTexture2D (Trilinear)
-(void)setTrilinearTexParameters
{
    // MIPmapping...
    [self generateMipmap];

    ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
    [self setTexParameters: &texParams];
}

@end
