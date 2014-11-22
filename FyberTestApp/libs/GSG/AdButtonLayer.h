//
//  AdButtonLayer.h
//  Mega Run
//
//  Created by Robert Segal on 2014-10-04.
//
//

#import "cocos2d.h"
#import "GSGGenericAdProvider.h"
#import "AdConfigurationHandler.h"

extern const int kTagAlertViewOffersAvailable;
extern const int kTagAlertViewOfferError;

@interface AdButtonLayer : CCLayer<GSGGenericAdProviderDelegate, UIAlertViewDelegate>

-(id)initWithAdConfig:(AdProductConfig *)c viewController:(UIViewController *)vc;
-(void)buttonAction;
-(void)enableButtonAndSetVisibilityButtonChildren:(BOOL)visibilty;
-(void)setVisibilityButtonChildren:(BOOL)visibilty;
-(void)resetButtonAppearanceAndState;

@property (nonatomic, readwrite, retain) CCMenuItemSprite *button;
@property (nonatomic, readwrite, assign) BOOL             wasButtonPressed;
@property (nonatomic, readwrite, copy  ) NSString         *alertTitle;
@property (nonatomic, readwrite, copy  ) NSString         *alertMessage;
@property (nonatomic, readwrite, assign) BOOL             shouldRewardVirtualCurrency;
@property (nonatomic, readwrite, assign) BOOL             shouldEnableButtonOnHide;
@property (nonatomic, readwrite, assign) BOOL             canShowEngagement;
@property (nonatomic, readonly)          BOOL             isAdAvailable;

@end
