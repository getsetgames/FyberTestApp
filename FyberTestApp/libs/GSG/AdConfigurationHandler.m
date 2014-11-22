//
//  AdConfigurationHandler.m
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import "AdConfigurationHandler.h"

//#import "OFInAppPurchaseCatalog.h"
//#import "OFXStore+Private.h"


@implementation AdConfigurationHandler

@synthesize configurationValues;

static AdConfigurationHandler* instance = NULL;

+(AdConfigurationHandler*)sharedInstance
{
  if(instance == NULL)
  {
    instance = [[AdConfigurationHandler alloc] init];
  }
  return instance;
}

-(void)initializeConfiguration
{
  configurationValues = [[NSMutableDictionary alloc] init];
  
//  NSArray *iaps = [OFInAppPurchaseCatalog inAppPurchasesForCategory:@"Ads"];
//  for (OFInAppPurchase *i in iaps)
//  {
//    AdProductConfig *adConfig = [[AdProductConfig alloc] initWithProductId:[i deliverableIdentifier] andFrequency:[[i.customParameters objectForKey:@"frequency"] intValue]];
//    adConfig.visible = [[i.customParameters objectForKey:@"visible"] isEqualToString:@"1"];
//    adConfig.orderList = [[i.customParameters objectForKey:@"order"] componentsSeparatedByString:@","];
//    
//    [configurationValues setObject:adConfig forKey:[i deliverableIdentifier]];
//    [adConfig release];
//  }
}

-(AdProductConfig*)getConfigForId:(NSString*)element
{
  return [configurationValues objectForKey:element];
}

- (void)dealloc
{
  [configurationValues release];
  [super dealloc];
}

@end
