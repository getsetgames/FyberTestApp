//
//  AdConfigurationHandler.h
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdProductConfig.h"

@interface AdConfigurationHandler : NSObject
{
  NSMutableDictionary *configurationValues;
}

@property (nonatomic, retain) NSMutableDictionary *configurationValues;

+(AdConfigurationHandler*)sharedInstance;

-(void)initializeConfiguration;
-(AdProductConfig*)getConfigForId:(NSString*)element;

@end
