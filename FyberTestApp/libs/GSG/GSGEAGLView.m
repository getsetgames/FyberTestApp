//
//  GSGEAGLView.m
//  Mega Run
//
//  Created by Robert Segal on 11-09-10.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import "GSGEAGLView.h"
#import "GSGCocos2d.h"

#if INCLUDE_RUNTIME_TOOLS == 1
#import "ToolSelectorContainer.h"
#endif

//#import "Game.h"

@implementation GSGEAGLView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    #if INCLUDE_RUNTIME_TOOLS == 1
    
    const CGFloat DEV_DASHBOARD_ENABLE_TOUCH_AREA = 25.0f;
    
	for (UITouch* t in touches)
	{
		CGPoint pt = [t locationInView:self];
		
		if (pt.x < DEV_DASHBOARD_ENABLE_TOUCH_AREA && pt.y < DEV_DASHBOARD_ENABLE_TOUCH_AREA)
		{
			ToolSelectorContainer* editorViewController = [[ToolSelectorContainer alloc] initWithNibName:@"ToolSelectorContainer" bundle:nil]; 
			
			if (editorViewController != nil)
			{
                CCScene* g = [CCDirector sharedDirector].runningScene;
                
                // Pause the game if we're in it playing
                //
                if ([g isKindOfClass:[Game class]])
                    [((Game *)g) menuPause];
                
				[[GSGCocos2d sharedInstance].navigationController pushViewController:editorViewController animated:YES];
				[editorViewController release];
				
				break;
			}
		}
	}
    
    #endif

	[super touchesBegan:touches withEvent:event];
}


@end
