//
//  HelloWorldLayer.h
//  FyberTestApp
//
//  Created by Robert Segal on 2014-11-21.
//  Copyright __MyCompanyName__ 2014. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "AdButtonLayer.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
     //CCMenuItemSprite *b;
    AdButtonLayer *adLayer;
    CCMenuItemSprite *b;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
