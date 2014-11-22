//
//  RootViewController.m
//  Mega Run
//
//  Created by Derek van Vliet on 11-01-31.
//  Copyright Get Set Games 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"
#import "GSGCocos2d.h"
//#import "Analytics.h"
//#import "OpenFeint.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    //
    // There are 2 ways to support auto-rotation:
    //  - The OpenGL / cocos2d way
    //     - Faster, but doesn't rotate the UIKit objects
    //  - The ViewController way
    //    - A bit slower, but the UiKit objects are placed in the right place
    //
    
#if GAME_AUTOROTATION==kGameAutorotationNone
    //
    // EAGLView won't be autorotated.
    // Since this method should return YES in at least 1 orientation,
    // we return YES only in the Portrait orientation
    //
    return ( interfaceOrientation == UIInterfaceOrientationPortrait );
    
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
    //
    // EAGLView will be rotated by cocos2d
    //
    // Sample: Autorotate only in landscape mode
    //
    if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
        [[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
    } else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
    }
    
    // Since this method should return YES in at least 1 orientation,
    // we return YES only in the Portrait orientation
    return ( interfaceOrientation == UIInterfaceOrientationPortrait );
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
    //
    // EAGLView will be rotated by the UIViewController
    //
    // Sample: Autorotate only in landscpe mode
    //
    // return YES for the supported orientations
    
    UIInterfaceOrientation myOrientations[2] = { UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight };
    
//    return [OpenFeint shouldAutorotateToInterfaceOrientation:interfaceOrientation withSupportedOrientations:myOrientations andCount:2];
    return [RootViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation withSupportedOrientations:myOrientations andCount:2];
#else
#error Unknown value in GAME_AUTOROTATION
    
#endif // GAME_AUTOROTATION
    
    // Shold not happen
    return NO;
}

// iOS > 6.0 //
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape; // hardcoded for now :( // -Dario //
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[GSGCocos2d sharedInstance] initialized] && ([GSGCocos2d sharedInstance].viewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight || [GSGCocos2d sharedInstance].viewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
    {
        return [GSGCocos2d sharedInstance].viewController.interfaceOrientation;
    }
    return UIInterfaceOrientationLandscapeRight;
}

-(BOOL) shouldAutorotate
{
    return YES;
}
/////////////////

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[OpenFeint setDashboardOrientation:self.interfaceOrientation];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Reference bug 914 for autorotation fix.  Also details in Cocos2D wiki...
    //
    //   http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:autorotation
    //
    
    CGRect rect = CGRectMake(0,0,0,0);
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            rect = CGRectMake(0, 0, 768, 1024);
        else
            rect = CGRectMake(0, 0, 320, [GSGCocos2d isDeviceWideScreen] ? 568 : 480);
        
    } else if( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            rect = CGRectMake(0, 0, 1024, 768);
        else
            rect = CGRectMake(0, 0, [GSGCocos2d isDeviceWideScreen] ? 568 : 480, 320);
    } else
        NSAssert(NO, @"Invalid orientation");
    
    [[CCDirector sharedDirector] openGLView].frame = rect;
    
//    if ([GSGCocos2d sharedInstance].initialized) {
//        [[Analytics sharedInstance] trackPage:@"/app/OrientationChanged/"
//                                   ParamValue:toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? @"Left" : @"Right"
//                                     ParamKey:@"Orientation"];
//    }
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesBegan:touches withEvent:event];
}


- (void)dealloc {
    [super dealloc];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [self.navigationController setNavigationBarHidden:YES];
 }
 
 
 #pragma mark - Presenting UIViewController
 
 - (void)_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion
 {
 GSGLOG(@"%s :: %@", __PRETTY_FUNCTION__, [viewControllerToPresent class]);
 // add the view controller to the queue //
 
 [super presentViewController:viewControllerToPresent animated:flag completion:completion];
 }
 
 - (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion
 {
 GSGLOG(@"%s :: %@", __PRETTY_FUNCTION__, [viewControllerToPresent class]);
 // add the view controller to the queue //
 [m_viewsQueue addObject:viewControllerToPresent];
 if ([m_viewsQueue objectAtIndex:0] == viewControllerToPresent)
 {
 [self _presentViewController:viewControllerToPresent animated:flag completion:completion];
 }
 }
 
 - (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
 {
 GSGLOG(@"%s :: %@", __PRETTY_FUNCTION__, [modalViewController class]);
 [self presentViewController:modalViewController animated:animated completion:nil];
 }
 
 #pragma mark - Dismissing UIViewController
 - (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion
 {
 GSGLOG(@"%s", __PRETTY_FUNCTION__);
 [super dismissViewControllerAnimated:flag completion:^(void){
 [self popObjectFromViewsQueue];
 if (completion)
 {
 completion();
 }
 }];
 }
 
 - (void)dismissModalViewControllerAnimated:(BOOL)animated
 {
 GSGLOG(@"%s", __PRETTY_FUNCTION__);
 [self dismissViewControllerAnimated:animated completion:nil];
 }
 
 #pragma mark - UINavigationControllerDelegate
 // Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
 - (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
 {
 GSGLOG(@"%s", __PRETTY_FUNCTION__);
 }
 
 - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
 {
 GSGLOG(@"%s", __PRETTY_FUNCTION__);
 }
 
 
 -(void) addObjectToViewsQueue:(id)obj
 {
 [m_viewsQueue addObject:obj];
 }
 
 -(void) popObjectFromViewsQueue
 {
 if (m_viewsQueue.count > 0) {
 [m_viewsQueue removeObjectAtIndex:0];
 }
 if (m_viewsQueue.count && [[[m_viewsQueue objectAtIndex:0] class] isSubclassOfClass:[UIViewController class]])
 {
 [self _presentViewController:[m_viewsQueue objectAtIndex:0] animated:YES completion:nil];
 }
 
 }*/

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation withSupportedOrientations:(UIInterfaceOrientation*)nullTerminatedOrientations andCount:(unsigned int)numOrientations
{
//    if([OpenFeint isShowingFullScreen] && ![OpenFeint isLargeScreen])
//    {
//        return NO;
//    }
    
    for(unsigned int i = 0; i < numOrientations; ++i)
    {
        if(interfaceOrientation == nullTerminatedOrientations[i])
        {
            return YES;
        }
    }
    
    return NO;
}

@end

