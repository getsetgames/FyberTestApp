//
//  AppDelegate.h
//  FyberTestApp
//
//  Created by Robert Segal on 2014-11-21.
//  Copyright __MyCompanyName__ 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, CCProjectionProtocol> {
	UIWindow			*window;
	RootViewController	*viewController;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) RootViewController *viewController;
@property (readonly) UINavigationController *navigationController;

-(void)updateProjection;

@end
