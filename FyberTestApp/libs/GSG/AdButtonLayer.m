//
//  AdButtonLayer.m
//  Mega Run
//
//  Created by Robert Segal on 2014-10-04.
//
//

#import "AdButtonLayer.h"

#import "GSGAdManager.h"
//#import "OFInventory.h"
//#import "OFReachability.h"

const int kTagAlertViewOffersAvailable = 0;
const int kTagAlertViewOfferError      = 1;

@interface AdButtonLayer()

@property (nonatomic, readwrite, assign) BOOL              isShowing;
@property (nonatomic, readwrite, assign) CCNode           *activityIcon;
@property (nonatomic, readwrite, assign) UIViewController *viewController;
@property (nonatomic, readwrite, assign) AdProductConfig  *adConfig;

-(void)safeParentPerformSelector:(SEL)s withObject:(NSObject *)obj;

@end

@implementation AdButtonLayer

-(id)initWithAdConfig:(AdProductConfig *)c viewController:(UIViewController *)vc
{
    self = [super init];
    
    if (self)
    {
        _adConfig           = [c retain];
        _wasButtonPressed   = NO;
        _isShowing          = NO;
        _canShowEngagement  = YES;
        _isAdAvailable      = NO;
        _viewController     = vc;

        _activityIcon       = [CCSprite spriteWithFile:@"activity-indicator.png"];
        
        if (_activityIcon)
        {
            [self addChild:_activityIcon];
            _activityIcon.scale = 0.0f;
        }
        
        _alertTitle   = @"Earn a reward!";
        _alertMessage = @"Would you like to watch a video to receive 10 Free MP?";
        
        _shouldRewardVirtualCurrency = YES;
        _shouldEnableButtonOnHide    = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adProviderAwardVirtualCurrencyReward:)
                                                     name:kAdProviderAwardVirtualCurrencyRewardNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.adConfig = nil;
    self.alertMessage = nil;
    self.alertTitle   = nil;
    self.button       = nil;
    
    [super dealloc];
}

-(void)onEnter
{
    _isShowing        = YES;
    _wasButtonPressed = NO;

    if (_adConfig)
    {
        [[GSGAdManager sharedInstance] setDelegateForConfiguration:_adConfig delegate:self];
        [[GSGAdManager sharedInstance] cacheAd:_adConfig];
    }
    
    [self setVisibilityActivityIndicator:NO];
    
    [super onEnter];
}

-(void)onExit
{
    [self showFreeMp];
    
    _wasButtonPressed = NO;
    _isShowing        = NO;
 
    if (_adConfig)
    {
        [[GSGAdManager sharedInstance] setDelegateForConfiguration:_adConfig delegate:nil];
        [[GSGAdManager sharedInstance] clearRequests:_adConfig];
    }

    [super onExit];
}

-(void)buttonAction
{
    [self setVisibilityActivityIndicator:YES];
    [self enableButtonAndSetVisibilityButtonChildren:NO];
    
    if (_adConfig)
    {
        [self showOfferAvailable];
    }
    else
    {
        [self showNoOffersAvailable:GSG_AD_PROVIDER_STATUS_ERROR];
    }
}

-(void)adProviderIsHidden:(NSDictionary *)d
{
    const GSGGenericAdProviderStatus status = (GSGGenericAdProviderStatus)[((NSNumber *)d[@"status"]) intValue];

    [self setVisibilityActivityIndicator:NO];
    
    if (_shouldEnableButtonOnHide)
    {
        [self enableButtonAndSetVisibilityButtonChildren:YES];
    }
    else
    {
        [self setVisibilityButtonChildren:YES];
    }

    switch (status)
    {
        case GSG_AD_PROVIDER_STATUS_CLOSE_ABORTED:
        case GSG_AD_PROVIDER_STATUS_ERROR:
        {
            if (_wasButtonPressed)
            {
                [self showNoOffersAvailable:status];
            }
            
            break;
        }
            
        default:
            break;
    }

    _wasButtonPressed = NO;
    _isAdAvailable    = NO;

    [self safeParentPerformSelector:@selector(adProviderIsHidden:) withObject:d];
}

-(void)adProviderAwardVirtualCurrencyReward:(NSNotification *)n
{
    if (_shouldRewardVirtualCurrency)
    {
        double amount = 0;
        
        if (n.userInfo)
        {
            NSNumber *a = n.userInfo[@"delta"];
            
            if (a)
            {
                amount = [a doubleValue];
            }
        }
        
        if (_canShowEngagement && _isShowing && self.parent.visible)
        {
            NSString *title = @"Thanks for watching";
            NSString *msg   = [NSString stringWithFormat:@"Thanks for watching you have been awarded %.0f Mega Points!", amount];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

-(void)adProviderDidCacheAd:(NSDictionary *)d
{
    const BOOL success = [((NSNumber *)d[@"areOffersAvailable"]) boolValue];

    _isAdAvailable = success;
    
    if ( _wasButtonPressed )
    {
        if (success)
        {
            [self showAd];
        }
        else
        {
            [self setVisibilityActivityIndicator:NO];
            [self enableButtonAndSetVisibilityButtonChildren:YES];
            [self showNoOffersAvailable:GSG_AD_PROVIDER_STATUS_ERROR];
        }
    }

    [self safeParentPerformSelector:@selector(adProviderDidCacheAd:) withObject:d];
}

-(void)adProviderShowAd:(NSDictionary *)d
{
    [self safeParentPerformSelector:@selector(adProviderShowAd:) withObject:nil];
}

-(void)showAd
{
    if (_canShowEngagement)
    {
        const BOOL result = [[GSGAdManager sharedInstance] showAdForConfiguration:_adConfig
                                                                 onViewController:_viewController
                                                                     withDelegate:self];
        if (!result)
        {
            [[GSGAdManager sharedInstance] cacheAd:_adConfig];
        }
    }
}

-(void)fetchAd
{
    if (_adConfig)
    {
        [[GSGAdManager sharedInstance] cacheAd:_adConfig];
        
        [self enableButtonAndSetVisibilityButtonChildren:NO];
    }
}

-(void)showFreeMp
{
    [self enableButtonAndSetVisibilityButtonChildren:YES];
}

-(void)setVisibilityButtonChildren:(BOOL)visibilty
{
    if (_button)
    {
        _button.visible = visibilty;
        
        for (CCNode *n in _button.children)
        {
            if ( [n isKindOfClass:[CCSprite class]] )
            {
                n.visible = visibilty;
            }
        }
    }
}

-(void)enableButtonAndSetVisibilityButtonChildren:(BOOL)visibilty
{
    if (_button)
    {
        _button.isEnabled = visibilty;

        for (CCNode *n in _button.children)
        {
            if ( [n isKindOfClass:[CCSprite class]] )
            {
                n.visible = visibilty;
            }
        }
    }
}

-(void)showOfferAvailable
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_alertTitle
                                                    message:_alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"No Thanks"
                                          otherButtonTitles:@"Watch", nil];
    
    
    alert.tag = kTagAlertViewOffersAvailable;
    
    [alert show];
    [alert release];
}

-(void)showNoOffersAvailable:(GSGGenericAdProviderStatus)status
{
    if (_canShowEngagement)
    {
        NSString *msg   = nil;
        NSString *title = nil;

        switch (status)
        {
            case GSG_AD_PROVIDER_STATUS_CLOSE_ABORTED:
            {
                title = @"Offer aborted";
                msg   = @"Offer aborted - please try again later";
                
                break;
            }
                
            default:
            {
                title = @"No offers available";
                
//                if ( OFReachability.isConnectedToInternet )
//                {
//                    msg = @"No offers currently available please try again later";
//                }
//                else
//                {
                    msg = @"No offers available - please ensure you are online and try again later";
               // }
                
                break;
            }
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

        alert.tag = kTagAlertViewOfferError;

        [alert show];
        [alert release];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL shouldResetButtons = NO;
    
    switch (alertView.tag)
    {
        case kTagAlertViewOffersAvailable:
        {
            if (buttonIndex == 1)
            {
                _wasButtonPressed = YES;

                [self enableButtonAndSetVisibilityButtonChildren:NO];
                
                if ( _adConfig && [[GSGAdManager sharedInstance] hasCachedAd:_adConfig] )
                {
                    [self showAd];
                }
                else
                {
                    [self fetchAd];
                }
            }
            else
            {
                shouldResetButtons = YES;
            }
            
            break;
        }
        case kTagAlertViewOfferError:
        {
            shouldResetButtons = YES;
            break;
        }
        
        default:
            break;
    }
    
    if (shouldResetButtons)
    {
        [self resetButtonAppearanceAndState];
    }
    
    [self safeParentPerformSelector:@selector(adProviderAlertViewClosed:)
                         withObject:@{ @"tag"   : [NSNumber numberWithInteger:alertView.tag],
                                       @"index" : [NSNumber numberWithInteger:buttonIndex] }];
}

-(void)safeParentPerformSelector:(SEL)s withObject:(NSObject *)obj
{
    if (self.parent)
    {
        if ([self.parent respondsToSelector:s])
        {
            [self.parent performSelector:s withObject:obj];
        }
    }
}

-(void)setVisibilityActivityIndicator:(BOOL)visibility
{
    if (!visibility)
    {
        [_activityIcon stopAllActions];
    }
    else
    {
        _activityIcon.position = _button ? _button.position : ccp(0.0f, 0.0f);
        _activityIcon.scale    = 1.0f;
 
        [_activityIcon runAction:[CCRepeatForever actionWithAction:
                                  [CCSequence actions:
                                   [CCScaleTo    actionWithDuration:0.0f scale:1.0f],
                                   [CCRotateBy   actionWithDuration:0    angle:30],
                                   [CCDelayTime  actionWithDuration:0.1], nil]]];
    }
    
    _activityIcon.visible = visibility;
}

-(void)resetButtonAppearanceAndState
{
    _canShowEngagement = YES;
    _wasButtonPressed  = NO;
    
    [self setVisibilityActivityIndicator:NO];
    [self enableButtonAndSetVisibilityButtonChildren:YES];
}

@end
