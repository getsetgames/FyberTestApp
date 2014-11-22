//
//  GSGAdManager.m
//  GSG
//
//  Created by BLG Mac3 on 8/29/13.
//  Copyright (c) 2013 Get Set Games. All rights reserved.
//

#import "GSGAdManager.h"
#import "Singleton.h"
#import "GSGGenericAdProvider.h"
//#import "FlurryAdProvider.h"
//#import "ChartBoostAdProvider.h"
//#import "AdColonyAdProvider.h"
//#import "AppLovinAdProvider.h"
#import "FyberAdProvider.h"
#import "FyberInterstitialAdProvider.h"
//#import "NewsAdProvider.h"
//#import "OFInventory.h"
//#import "SettingsManager.h"

@implementation GSGAdManager

@synthesize currentProviders;
@synthesize adInProgress;
@synthesize suppressInterstitial;

@synthesize lastAdConfiguration;
@synthesize lastAdView;
//CLASS_SINGLETON(GSGAdManager)

static GSGAdManager* instance = NULL;

+(GSGAdManager*)sharedInstance
{
  if(instance == NULL)
  {
    instance = [[GSGAdManager alloc]init];
  }
  return instance;
}

-(void)initializeWithView:(UIViewController*)viewController
     //  withFlurryDelegate:(id)flurryDelegate
    //  andAdColonyDelegate:(id)adColonyDelegate
//    andChartBoostDelegate:(id)chartBoostDelegate
          andNewsDelegate:(id)newsDelegate
            andIapProduct:(NSString*)iap
{
  
//	FlurryAdProvider *flurry = [[FlurryAdProvider alloc] init];
//	AdColonyAdProvider *adColony = [[AdColonyAdProvider alloc] init];
//	ChartBoostAdProvider *chartBoost = [[ChartBoostAdProvider alloc] init];
//	AppLovinAdProvider *applovin = [[AppLovinAdProvider alloc] init];
    FyberAdProvider *fyber = [[FyberAdProvider alloc] init];
    FyberInterstitialAdProvider *fyberInterstitial = [[FyberInterstitialAdProvider alloc] init];
//	NewsAdProvider *news = [[NewsAdProvider alloc] init];

//	flurry.delegate = flurryDelegate;
//	adColony.delegate = adColonyDelegate;
//	chartBoost.delegate = chartBoostDelegate;
    iapProduct = iap;
	
	NSArray *objects = [NSArray arrayWithObjects:
						/*flurry, chartBoost,*/ /*adColony,*/ /*applovin,*/ fyber, fyberInterstitial/*, news*/, nil];
	
	NSArray *keys = [NSArray arrayWithObjects:
//					 GSG_AD_FLURRY
//					 GSG_AD_CHARTBOOST
//					 , GSG_AD_ADCOLONY
//					 , GSG_AD_APPLOVIN
                     GSG_AD_FYBER
                     , GSG_AD_FYBER_INTERSTITIAL
  //                   , GSG_AD_NEWS
					 , nil];
	
	for(GSGGenericAdProvider *provider in objects)
	{
		provider.viewController = viewController;
		[provider initialize];
	}
	
	self.currentProviders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
//	[flurry release];
//	[adColony release];
	//[chartBoost release];
//	[applovin release];
    [fyber release];
    [fyberInterstitial release];
  //  [news release];
}

-(BOOL)showAdForConfiguration:(AdProductConfig*)identifier onViewController:(UIViewController *)viewController withFirstRun:(BOOL)firstRun
{
  
  if(self.adInProgress == YES || !identifier)
  {
    return NO;
  }
  
  self.lastAdConfiguration = identifier;
//  self.lastAdView = view;
  _firstRun = firstRun;
  
  //1. Increment the current hit for the product
  identifier.currentCount += 1;
  [identifier persistCount];
 
  NSLog(@"Identifier Id: %@, Frequency %i, Current Count %i", identifier.productId, identifier.frequency, identifier.currentCount);
 
  if(![self canShowInterstitial])
  {
    return NO;
  }
  
  //2. Check if the ad frequency is correct
  if(identifier.visible && identifier.frequency <=  identifier.currentCount)
  {
    NSLog(@"Frequency is less than current hit count, processing ads");
    
    //3. Get The Correct Provider for the order
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString*)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //Get the provider
        GSGGenericAdProvider *provider = currentProviders[orderProvider];

        if (provider != NULL)
        {
            BOOL canShowInterstial = [self canShowInterstitial];
            
            // If global show intersitial settings say an ad can't be displayed check if the provider has an override
            //
            if ( !canShowInterstial )
            {
                if ( [provider respondsToSelector:@selector(canShowInterstitial:)] )
                    canShowInterstial = [provider canShowInterstitial:firstRun];
            }

            if (canShowInterstial)
            {
                NSLog(@"Found provider With Id %@", orderProvider);
                
                //Get the provider
                GSGGenericAdProvider *provider = [currentProviders objectForKey:orderProvider];
              //  provider.currentHook = identifier.productId;
                provider.viewController = viewController;
                
                if([provider hasCachedAd])
                {
                  //4. Show the corresponding ad
                  if([provider showAd])
                  {
                    self.adInProgress = YES;
                    //5. Reset the counter
                    identifier.currentCount = 0;
                    [identifier persistCount];
                    NSLog(@"Provider Had Cached Ad showing add");
                    return YES;
                  }
                }
                else
                {
                  NSLog(@"Provider doesn't have a Cached Add, Find next provider");
                }
            }
        }
    }
  }
  //Else Do nothing, no ad should be shown
  return NO;
}

-(BOOL)showAdForConfiguration:(AdProductConfig*)identifier onViewController:(UIViewController*)viewController withDelegate:(id)delegate
{
    if ( self.adInProgress == YES || !identifier )
    {
        return NO;
    }
    
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString*)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            NSLog(@"Found provider With Id %@", orderProvider);
            
            GSGGenericAdProvider *provider = currentProviders[orderProvider];
//            provider.currentHook           = identifier.productId;
            provider.viewController        = viewController;
            provider.delegate               = delegate;
            
            if([provider hasCachedAd])
            {
                if([provider showAd])
                {
                    NSLog(@"Provider Had Cached Ad showing add");
                    return YES;
                }
            }
            else
            {
                NSLog(@"Provider doesn't have a Cached Add, Find next provider");
            }
        }
    }
    
    return NO;
}

-(BOOL)canShowInterstitial {
  
 // BOOL iapBuyer = ([OFInventory numberOfItem:iapProduct] > 0);
 // BOOL disabledPopups = ([[[SettingsManager sharedSettingsManager] getString:@"popups"] isEqualToString:@"NO"]);
  
//  if (_firstRun || self.suppressInterstitial || iapBuyer || disabledPopups)
//    return NO;
//  
//  for (UIWindow* window in [UIApplication sharedApplication].windows) {
//    NSArray* subviews = window.subviews;
//    if ([subviews count] > 0)
//      if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
//        return NO;
//  }
  
  return YES;
}

//-(BOOL)repeatLastAd
//{
//  return [self showAdForConfiguration:self.lastAdConfiguration onView:self.lastAdView withFirstRun:_firstRun];
//}

- (void)dealloc
{
  [currentProviders release];
  [super dealloc];
}

-(void)cacheAd:(AdProductConfig *)identifier
{
    if (!identifier)
        return;
    
    // Make sure there is at least one ad cache'd for the next time user views
    //
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString *)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            if( [provider hasCachedAd] )
            {
                break;
            }
            else
            {
                [provider cacheAd];
            }
        }
    }
}

-(BOOL)hasCachedAd:(AdProductConfig *)identifier
{
    BOOL isAdCached = NO;
    
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString *)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            isAdCached = [provider hasCachedAd];
            
            if (isAdCached)
            {
                break;
            }
        }
    }
    
    return isAdCached;
}

-(void)setDelegateForConfiguration:(AdProductConfig *)identifier delegate:(id)delegate
{
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString *)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            provider.delegate = delegate;
        }
    }
}

-(void)flush:(AdProductConfig *)identifier
{
    if (!identifier)
        return;
    
    // Make sure there is at least one ad cache'd for the next time user views
    //
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString *)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            [provider flush];
        }
    }
}

-(void)clearRequests:(AdProductConfig *)identifier
{
    if (!identifier)
        return;
    
    // Make sure there is at least one ad cache'd for the next time user views
    //
    for(int i=0; i < identifier.orderList.count; i++)
    {
        NSString* orderProvider = (NSString *)identifier.orderList[i];
        orderProvider = [orderProvider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        GSGGenericAdProvider *provider = currentProviders[orderProvider];
        
        if (provider != NULL)
        {
            [provider clearRequests];
        }
    }
}



@end
