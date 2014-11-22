//
//  AdProductConfig.m
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import "AdProductConfig.h"
//#import "SettingsManager.h"

@implementation AdProductConfig

@synthesize productId;
@synthesize currentCount;
@synthesize frequency;
@synthesize orderList;
@synthesize visible;

-(id)initWithProductId:(NSString*)product andFrequency:(int)freq
{
  self = [super init];
  if (self)
  {
    self.productId = product;
//    currentCount = [[SettingsManager sharedSettingsManager] getInt:[NSString stringWithFormat:@"%@-count",product]];
    frequency = freq;
  }
  return self;
}


-(void)persistCount
{
//  [[SettingsManager sharedSettingsManager] setValue:[NSString stringWithFormat:@"%@-count",productId] newInt:currentCount];
//  [[SettingsManager sharedSettingsManager] save];
}

- (void)dealloc
{
  [productId release];
  [orderList release];
  [super dealloc];
}

@end
