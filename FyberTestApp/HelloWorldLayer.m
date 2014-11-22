//
//  HelloWorldLayer.m
//  FyberTestApp
//
//  Created by Robert Segal on 2014-11-21.
//  Copyright __MyCompanyName__ 2014. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "GSGAdManager.h"
#import "GSGCocos2d.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
   
		// create and initialize a Label
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        b = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"Icon-72.png"]
                                                      selectedSprite:[CCSprite spriteWithFile:@"Icon-72.png"]
                                                               block:^(id sender) {
                                                                   
                                                                   
                                                                   
                                                                   [adLayer buttonAction];
                                                                   
                                                                   NSLog(@"Sup");
                                                               }];
        
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		//b.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		//[self addChild:b];
        
        CCMenu *m = [CCMenu menuWithItems:b, nil];
        
        [self addChild:m];
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        
        UIViewController *vc = (UIViewController *)app.viewController;

        
        [[GSGAdManager sharedInstance] initializeWithView:vc
         //                                   withFlurryDelegate:[Analytics sharedInstance]
         //                                andAdColonyDelegate:[Analytics sharedInstance]
         //                                andChartBoostDelegate:nil//[GSGChartboost sharedInstance]
                                          andNewsDelegate:nil
                                            andIapProduct:@"com.getsetgames.megarun.iapbuyer"];
        
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)onEnter
{
    if (!adLayer)
    {
        AdProductConfig *adConfig = [[[AdProductConfig alloc] init] autorelease];
        
        adConfig.productId = @"com.getsetgames.freemp";
        adConfig.orderList = @[@"fyber", @"fyber-interstitial"];
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        
        //UIViewController *vc = (UIViewController *)app.viewController;
        
        adLayer = [[[AdButtonLayer alloc] initWithAdConfig:adConfig viewController:[GSGCocos2d sharedInstance].viewController] autorelease];
        adLayer.button = b;
        [self addChild:adLayer];
    }

    [super onEnter];
}

@end
