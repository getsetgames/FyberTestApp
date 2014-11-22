//
//  SPBrandEngageClient.m
//  SponsorPay Mobile Brand Engage SDK
//
//  Copyright (c) 2012 SponsorPay. All rights reserved.
//

#import "SPBrandEngageClient.h"
#import "SPBrandEngageClient_SDKPrivate.h"

// SponsorPay SDK.
#import "SPLogger.h"
#import "SPToast.h"
#import "SPReachability.h"
#import "SPVirtualCurrencyServerConnector.h"
#import "SPVirtualCurrencyServerConnector_SDKPrivate.h"
#import "SPConstants.h"
#import "SPTargetedNotificationFilter.h"
#import "SPLoadingIndicator.h"
#import "SPBrandEngageViewController.h"
#import "SPURLGenerator.h"
#import "SPMediationCoordinator.h"
#import "SPBrandEngageWebView.h"
#import "SPBrandEngageWebViewDelegate.h"
#import "SPConstants.h"
#import "SPCredentials.h"
#import "SPVersionChecker.h"
#import "SPConnectionHelper.h"
#import "SPStoreKitManager.h"
#import "SPURLRequest.h"

NSTimeInterval const SPMBERequestOffersTimeout = (NSTimeInterval)10.0;
NSString *const SPMBERewardNotificationText = @"Thanks! Your reward will be paid out shortly";

NSString *const SPMBEErrorDialogTitle = @"Error";
NSString *const SPMBEErrorDialogMessageDefault = @"We're sorry, something went wrong. Please try again.";
NSString *const SPMBEErrorDialogMessageOffline = @"Your Internet connection has been lost. Please try again later.";
NSString *const SPMBEErrorDialogButtonTitleDismiss = @"Dismiss";

static NSInteger const SPMBEErrorDialogCloseTag = -1;
NSInteger const SPMBEErrorDialogGenericTag = 0;
NSInteger const SPMBEErrorDialogStoreKitTag = 1;

static NSString *const kSPMBEURLParamValueAdFormat = @"video";
static NSInteger const kSPMBEURLParamValueRewarded = 1;

typedef NS_ENUM(NSInteger, SPBEClientOffersRequestStatus) {
    SPBEClientOffersRequestStatusMustQueryServerForOffers,
    SPBEClientOffersRequestStatusQueryingServerForOffers,
    SPBEClientOffersRequestStatusReadyToShowOffers,
    SPBEClientOffersRequestStatusShowingOffers
} SPBrandEngageClientOffersRequestStatus;


@interface SPBrandEngageClient ()<SPBrandEngageWebViewDelegate, UIAlertViewDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) SPBrandEngageWebView *BEWebView;
@property (strong) SPBrandEngageViewController *activeBEViewController;
@property (strong) UIViewController *viewControllerToRestore;

@property (nonatomic, strong) SPCredentials *credentials;
@property (nonatomic, strong, readwrite) NSString *currencyName;

@property (strong) NSTimer *timeoutTimer;
@property (nonatomic, strong, readwrite) SPMediationCoordinator *mediationCoordinator;
@property (assign) BOOL playingThroughTPN;

@property (assign) BOOL playVideoCallbackReceived;

@property (nonatomic, strong) SPLoadingIndicator *loadingStoreKitView;

@property (nonatomic, strong) NSMutableDictionary *customParams;
@property (nonatomic, assign) SPBEClientOffersRequestStatus offersRequestStatus;
@property (nonatomic, assign) BOOL mustRestoreStatusBarOnPlayerDismissal;
@property (nonatomic, strong) SPReachability *internetReachability;
@property (nonatomic, strong) SPLoadingIndicator *loadingProgressView;

@end


@implementation SPBrandEngageClient

#pragma mark - Properties

- (BOOL)setCustomParamWithKey:(NSString *)key value:(NSString *)value
{
    if (self.customParams && [[self.customParams objectForKey:key] isEqualToString:value]) {
        return YES;
    }

    if (![self canChangePublisherParameters]) {
        SPLogError(@"Cannot add custom parameter while a request to the server is going on"
                    " or an offer is being presented to the user.");
    } else {
        if (!self.customParams) {
            self.customParams = [[NSMutableDictionary alloc] init];
        }
        [self.customParams setObject:value forKey:key];
        [self didChangePublisherParameters];
        return YES;
    }

    return NO;
}

- (BOOL)canChangePublisherParameters
{
    return (self.offersRequestStatus == SPBEClientOffersRequestStatusMustQueryServerForOffers) ||
           (self.offersRequestStatus == SPBEClientOffersRequestStatusReadyToShowOffers);
}

- (void)didChangePublisherParameters
{
    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
}

@synthesize delegate = _delegate;

@synthesize BEWebView = _BEWebView;

- (SPBrandEngageWebView *)BEWebView
{
    if (!_BEWebView) {
        _BEWebView = [[SPBrandEngageWebView alloc] init];
        _BEWebView.brandEngageDelegate = self;
    }
    return _BEWebView;
}

@synthesize activeBEViewController = _activeBEViewController;

#pragma mark - Initializing and deallocing

- (id)initWithCredentials:(SPCredentials *)credentials
{
    self = [super init];

    if (self) {
        _offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
        _credentials = credentials;

        self.shouldShowRewardNotificationOnEngagementCompleted = YES;
        self.loadingStoreKitView = [[SPLoadingIndicator alloc] initFullScreen:NO showSpinner:YES];

        [self setUpInternetReachabilityNotifier];
        [self registerForCurrencyNameChangeNotification];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.timeoutTimer.isValid) {
        [self.timeoutTimer invalidate];
    }
}

#pragma mark - Public methods
- (BOOL)canRequestOffers
{
    return self.offersRequestStatus == SPBEClientOffersRequestStatusMustQueryServerForOffers ||
           self.offersRequestStatus == SPBEClientOffersRequestStatusReadyToShowOffers;
}

- (BOOL)requestOffers
{
    return [self requestOffersForPlacementId:nil];
}

- (BOOL)requestOffersForPlacementId:(NSString *)placementId
{
    self.placementId = placementId;

    if (![self canRequestOffers]) {
        SPLogWarn(
                  @"SPBrandEngageClient cannot request offers at this point. "
                  "It might be requesting offers right now or an offer might be currently being presented to the user.");

        return NO;
    }

    if (SPFoundationVersionNumber >= NSFoundationVersionNumber_iOS_5_0) {
        self.offersRequestStatus = SPBEClientOffersRequestStatusQueryingServerForOffers;

        NSURL *requestURL = [self requestURLForMBE];

        [SPURLRequest requestWithUserDataForURL:requestURL shouldUpdateLocation:YES completionBlock:^(NSURLRequest *urlRequest) {
            NSMutableURLRequest *mutableRequest = [urlRequest mutableCopy];
            [mutableRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [self.BEWebView loadRequest:mutableRequest];
        }];

        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:SPMBERequestOffersTimeout
                                                             target:self
                                                           selector:@selector(requestOffersTimerDue)
                                                           userInfo:nil
                                                            repeats:NO];
    } else {
        // iOS 5 or newer is required.
        [self performSelector:@selector(callDelegateWithNoOffers) withObject:nil afterDelay:0.0];
    }
    
    return YES;
}

- (BOOL)canStartOffers
{
    return (self.offersRequestStatus == SPBEClientOffersRequestStatusReadyToShowOffers);
}

- (BOOL)startWithParentViewController:(UIViewController *)parentViewController
{
    if (![self canStartOffers]) {
        SPLogError(@"SPBrandEngageClient is not ready to show offers. Call -requestOffers: "
                    "and wait until your delegate is called with the confirmation that offers have been received.");

        [self invokeDelegateWithStatus:ERROR];

        return NO;
    }

//    if (_internetReachability.currentReachabilityStatus == SPNetworkStatusNotReachable) {
//        SPLogError(@"SPBrandEngageClient could not show the video due to lack of Internet connectivity");
//        NSError *error = [NSError errorWithDomain:@"com.sponsorpay.mobileBrandEngageError" code:-1009 userInfo:@{NSLocalizedDescriptionKey: @"The Internet connection appears to be offline"}];
//        [self showErrorAlertWithMessage:error.localizedDescription tag:SPMBEErrorDialogGenericTag];
//        [self invokeDelegateWithStatus:ERROR];
//
//        return NO;
//    }

    [[SPConnectionHelper sharedInstance] checkConnectivityWithFailure:^{
        SPLogError(@"SPBrandEngageClient could not show the video due to lack of Internet connectivity");
        NSError *error = [NSError errorWithDomain:@"com.sponsorpay.mobileBrandEngageError" code:-1009 userInfo:@{NSLocalizedDescriptionKey: @"The Internet connection appears to be offline"}];
        [self showErrorAlertWithMessage:error.localizedDescription tag:SPMBEErrorDialogCloseTag];
        [self invokeDelegateWithStatus:ERROR];
    }];

    self.offersRequestStatus = SPBEClientOffersRequestStatusShowingOffers;

    BOOL isTPNOffer = self.playingThroughTPN = [self.BEWebView currentOfferUsesTPN];

    if (isTPNOffer) {
        self.mediationCoordinator.hostViewController = parentViewController;
        [self animateLoadingViewIn];
        self.playVideoCallbackReceived = NO;
        [self performSelector:@selector(playTPNVideoDue) withObject:nil afterDelay:SPMBEStartOfferTimeout];

        [self.BEWebView startOffer];
    } else {
        [self presentBEViewControllerWithParent:parentViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }


    return YES;
}

- (void)presentBEViewControllerWithParent:(UIViewController *)parentViewController
{
    if (![UIApplication sharedApplication].statusBarHidden) {
        SPLogDebug(@"Hiding status bar");
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        self.mustRestoreStatusBarOnPlayerDismissal = YES;
    }

    SPBrandEngageViewController *brandEngageVC = [[SPBrandEngageViewController alloc] initWithWebView:self.BEWebView];

    self.activeBEViewController = brandEngageVC;

    void (^simpleBlock)(void) = ^{ [self.BEWebView startOffer]; };

    if (SPFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0) {
        [parentViewController presentViewController:self.activeBEViewController animated:YES completion:simpleBlock];
    } else {
        self.viewControllerToRestore = [[self class] swapRootViewControllerTo:brandEngageVC
                                                         withAnimationOptions:UIViewAnimationOptionTransitionCurlDown
                                                                   completion:simpleBlock];
    }
}

#pragma mark - Interrupting engagement if the host app enters background

- (void)didEnterBackground
{
    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
    [self engagementDidFinishWithStatus:CLOSE_ABORTED];
}

#pragma mark - SPBrandEngageWebViewControllerDelegate methods

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView javascriptReportedOffers:(NSInteger)numberOfOffers
{
    SPLogDebug(@"%s BEWebView=%x offers=%d", __PRETTY_FUNCTION__, [BEWebView hash], numberOfOffers);

    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;

    BOOL areOffersAvailable = (numberOfOffers > 0);

    self.offersRequestStatus = areOffersAvailable ? SPBEClientOffersRequestStatusReadyToShowOffers :
                                                    SPBEClientOffersRequestStatusMustQueryServerForOffers;

    if ([self.delegate respondsToSelector:@selector(brandEngageClient:didReceiveOffers:)]) {
        [self.delegate brandEngageClient:self didReceiveOffers:areOffersAvailable];
    }
}

- (void)brandEngageWebViewJavascriptOnStarted:(SPBrandEngageWebView *)BEWebView
{
    SPLogDebug(@"OnStarted event received");

    [self invokeDelegateWithStatus:STARTED];
}

- (void)brandEngageWebViewOnAborted:(SPBrandEngageWebView *)BEWebView
{
    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;

  [self engagementDidFinishWithStatus:CLOSE_ABORTED];
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView didFailWithError:(NSError *)error
{
    SPBEClientOffersRequestStatus preErrorStatus = self.offersRequestStatus;
    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;

    // Show dialog only if we are showing offers
    if (preErrorStatus == SPBEClientOffersRequestStatusShowingOffers) {
        NSString *errorMessage = nil;

        if ([error.domain isEqualToString:SPMBEWebViewJavascriptErrorDomain]) {
            errorMessage = SPMBEErrorDialogMessageDefault;
        } else {
            errorMessage = SPMBEErrorDialogMessageOffline;
        }

        [self showErrorAlertWithMessage:errorMessage tag:SPMBEErrorDialogGenericTag];
    } else if (preErrorStatus == SPBEClientOffersRequestStatusQueryingServerForOffers) {
        [self invokeDelegateWithStatus:ERROR];
    }
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView requestsToCloseFollowingOfferURL:(NSURL *)offerURL
{
    BOOL willOpenURL = NO;
    if (offerURL) {
        willOpenURL = [[UIApplication sharedApplication] canOpenURL:offerURL];
    }

    if (willOpenURL) {
        [BEWebView stopLoading];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userReturnedAfterFollowingOffer)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        SPLogDebug(@"Application will follow offer url: %@", offerURL);
    }

    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;

    [self engagementDidFinishWithStatus:CLOSE_FINISHED];

    if (!willOpenURL) {
        [self showRewardNotification];
    }
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView
   requestsValidationOfTPN:(NSString *)tpnName
               contextData:(NSDictionary *)contextData
{
    SPTPNValidationResultBlock resultBlock = ^(NSString *tpnKey, SPTPNValidationResult validationResult) {
    NSString *validationResultString = SPTPNValidationResultToString(validationResult);

    SPLogInfo(@"Videos from %@ validation result: %@", tpnKey, validationResultString);

    [BEWebView notifyOfValidationResult:validationResultString forTPN:tpnKey contextData:contextData];
    };

    [self.mediationCoordinator videosFromProvider:tpnName available:resultBlock];
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView
    requestsPlayVideoOfTPN:(NSString *)tpnName
               contextData:(NSDictionary *)contextData
{
    [self animateLoadingViewOut];
    self.playVideoCallbackReceived = YES;
    SPTPNVideoEventsHandlerBlock eventsHandlerBlock = ^(NSString *tpnKey, SPTPNVideoEvent event) {
    NSString *eventName = SPTPNVideoEventToString(event);
    SPLogDebug(@"Video event from %@: %@", tpnKey, eventName);

    [BEWebView notifyOfVideoEvent:eventName forTPN:tpnName contextData:contextData];
    };

    if (self.mediationCoordinator.hostViewController) {
        [self.mediationCoordinator playVideoFromProvider:tpnName eventsCallback:eventsHandlerBlock];
    } // else - function called after timeout
}

- (void)playTPNVideoDue
{
    if (!self.playVideoCallbackReceived) {
        [self animateLoadingViewOut];
        SPLogError(@"Could not play the video - timeout to start playing reached");
        [self invokeDelegateWithStatus:ERROR];
        self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
        self.mediationCoordinator.hostViewController = nil;
    }
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView requestsStoreWithAppId:(NSString *)appId affiliateToken:(NSString *)affiliateToken campaignToken:(NSString *)campaignToken
{
    [BEWebView stopLoading];
    [self openStoreWithAppId:appId affiliateToken:affiliateToken campaignToken:campaignToken];
}

- (void)brandEngageWebView:(SPBrandEngageWebView *)BEWebView
 playVideoFromLocalNetwork:(NSString *)network
                     video:(NSString *)video
                 showAlert:(BOOL)showAlert
              alertMessage:(NSString *)alertMessage
           clickThroughURL:(NSURL *)clickThroughURL
{
    // Since our video player supports only landscape, the end card should only support landscape as well
    [self.activeBEViewController playVideoFromNetwork:network
                                                video:video
                                            showAlert:showAlert
                                         alertMessage:alertMessage
                                      clickThroughURL:clickThroughURL];
}

#pragma mark - StoreKit methods
- (void)openStoreWithAppId:(NSString *)appId affiliateToken:(NSString *)affiliateToken campaignToken:(NSString *)campaignToken
{
    SPLogDebug(@"Opening app store with appId %@", appId);
    [self.loadingStoreKitView presentWithAnimationTypes:SPAnimationTypeFade];

    [[SPStoreKitManager sharedInstance] openStoreWithAppId:appId trackingURL:nil affiliateToken:affiliateToken campaignToken:campaignToken success:^(BOOL result, SKStoreProductViewController *productViewController) {
        [self.loadingStoreKitView dismiss];
        [self.activeBEViewController presentViewController:productViewController animated:YES completion:nil];
    } failure:^(NSError *error) {
        [self.loadingStoreKitView dismiss];
        [self showErrorAlertWithMessage:[error localizedDescription] tag:SPMBEErrorDialogStoreKitTag];
    } didFinish:^(SKStoreProductViewController *productViewController) {
        [self dismissProductViewController];
    } didOpenWithSafari:^(NSURL *openedURL) {
        [self brandEngageWebView:self.BEWebView requestsToCloseFollowingOfferURL:openedURL];
    }];
}

- (void)dismissProductViewController
{
    [self showRewardNotification];

    self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
    [self engagementDidFinishWithStatus:CLOSE_FINISHED];
}
#pragma mark - Handling user's return after completing engagement

- (void)userReturnedAfterFollowingOffer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    SPLogDebug(@"User returned to app after following offer. Will show notification.");

    [self showRewardNotification];
}

#pragma mark - Internet connection status change management

- (void)setUpInternetReachabilityNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kSPReachabilityChangedNotification
                                               object:nil];

    if (!self.internetReachability) {
        self.internetReachability = [SPReachability reachabilityForInternetConnection];
    }

    [self.internetReachability startNotifier];
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note
{
    if (!self.activeBEViewController) {
        return;
    }

    SPReachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[SPReachability class]]);

    SPNetworkStatus currentNetworkStatus = [curReach currentReachabilityStatus];

    switch (currentNetworkStatus) {
    case SPNetworkStatusReachableViaWiFi:
        SPLogDebug(@"Internet is now reachable via WiFi");
        break;
    case SPNetworkStatusReachableViaWWAN:
        SPLogDebug(@"Internet is now reachable via WWAN (cellular connection)");
        break;
    case SPNetworkStatusNotReachable:
        SPLogDebug(@"Connection to the internet has been lost");
        [self didLoseInternetConnection];
        break;
    default:
        SPLogDebug(@"Unexpected network status received: %d", currentNetworkStatus);
        break;
    }
}

- (void)didLoseInternetConnection
{
    if (self.offersRequestStatus == SPBEClientOffersRequestStatusShowingOffers) {
        self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
        [self showErrorAlertWithMessage:SPMBEErrorDialogMessageOffline tag:SPMBEErrorDialogGenericTag];
    }
}

#pragma mark - Error alerts

- (void)showErrorAlertWithMessage:(NSString *)message tag:(NSInteger)tag
{
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:SPMBEErrorDialogTitle
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:SPMBEErrorDialogButtonTitleDismiss
                                                   otherButtonTitles:nil];
    if (tag) {
        errorAlertView.tag = tag;
    }

    [errorAlertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case SPMBEErrorDialogGenericTag:
            _offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;
            [self engagementDidFinishWithStatus:ERROR];
            break;

        case SPMBEErrorDialogStoreKitTag:
            [self dismissProductViewController];
            break;

        case SPMBEErrorDialogCloseTag:
            self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;

            if (_mustRestoreStatusBarOnPlayerDismissal) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                SPLogDebug(@"Restored status bar");
            }

            [self dismissEngagementViewControllerWithStatus:ERROR];

            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidEnterBackgroundNotification
                                                          object:nil];
            break;

        default:
            break;
    }
}

#pragma mark - Utility methods

- (NSURL *)requestURLForMBE
{
    SPURLGenerator *urlGenerator = [SPURLGenerator URLGeneratorWithEndpoint:SPURLEndpointMBEJSCore];

    [urlGenerator setCredentials:self.credentials];

    [urlGenerator setParameterWithKey:kSPURLParamKeyCurrencyName stringValue:self.currencyName];
    [urlGenerator setParameterWithKey:@"sdk" stringValue:@"on"];
    [urlGenerator setParameterWithKey:kSPURLParamKeyRewarded integerValue:kSPMBEURLParamValueRewarded];
    [urlGenerator setParameterWithKey:kSPURLParamKeyAdFormat stringValue:kSPMBEURLParamValueAdFormat];
    [urlGenerator setParameterWithKey:SPUrlGeneratorPlacementIDKey stringValue:self.placementId];

    if (self.customParams) {
        [urlGenerator setParametersFromDictionary:self.customParams];
    }
    return [urlGenerator generatedURL];
}

- (NSURLRequest *)requestForWebViewMBEJsCore
{
    NSURL *requestURL = [self requestURLForMBE];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

    return request;
}

- (void)engagementDidFinishWithStatus:(SPBrandEngageClientStatus)status
{
    SPLogInfo(@"Engagement finished");

    [self.BEWebView removeFromSuperview];
    self.BEWebView = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Used to tell Unity that the engagement will be dismissed. It should update the rotation at this point.
    // Using perform selector to not expose the method on the protocol
    if ([self.delegate respondsToSelector:@selector(brandEngageClientWillDismissEngagement:)]) {
        [self.delegate performSelector:@selector(brandEngageClientWillDismissEngagement:) withObject:self];
    }
#pragma clang diagnostic pop

    if (self.playingThroughTPN) {
        [self invokeDelegateWithStatus:status];
        return;
    }

    if (self.mustRestoreStatusBarOnPlayerDismissal) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        SPLogDebug(@"Restored status bar");
    }

    [self dismissEngagementViewControllerWithStatus:status];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (void)dismissEngagementViewControllerWithStatus:(SPBrandEngageClientStatus)status
{
    if (!self.activeBEViewController) {
        SPLogWarn(@"no active BEViewController to dismiss");
        return;
    }

    if (SPFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0) {
        [self.activeBEViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self invokeDelegateWithStatus:status];
        }];
    } else {
        NSAssert(self.viewControllerToRestore, @"%@.viewControllerToRestore is nil!", [self class]);

        [[self class] swapRootViewControllerTo:self.viewControllerToRestore
                          withAnimationOptions:UIViewAnimationOptionTransitionCurlUp
                                    completion:^{
                                        [self invokeDelegateWithStatus:status];
                                    }];
        self.viewControllerToRestore = nil;
    }

    self.activeBEViewController = nil;
}

- (void)requestOffersTimerDue
{
    if (self.offersRequestStatus == SPBEClientOffersRequestStatusQueryingServerForOffers) {
        SPLogError(@"Requesting offers timed out");
        [self.BEWebView stopLoading];
        self.BEWebView = nil;
        self.offersRequestStatus = SPBEClientOffersRequestStatusMustQueryServerForOffers;

        [self callDelegateWithNoOffers];
    }
}

- (void)callDelegateWithNoOffers
{
    if ([self.delegate respondsToSelector:@selector(brandEngageClient:didReceiveOffers:)]) {
        [self.delegate brandEngageClient:self didReceiveOffers:NO];
    }
}

- (void)showRewardNotification
{
    SPLogDebug(@"showRewardNotification");

    if (!self.shouldShowRewardNotificationOnEngagementCompleted) {
        return;
    }

    SPToastSettings *const settings = [SPToastSettings toastSettings];

    settings.duration = SPToastDurationNormal;
    settings.gravity = SPToastGravityBottom;

    (void)[SPToast enqueueToastOfType:SPToastTypeNone withText:SPMBERewardNotificationText settings:settings];
}

- (void)invokeDelegateWithStatus:(SPBrandEngageClientStatus)status
{
    if ([self.delegate respondsToSelector:@selector(brandEngageClient:didChangeStatus:)]) {
        [self.delegate brandEngageClient:self didChangeStatus:status];
    } else {
        SPLogWarn(@"SP Brand Engage Client Delegate: %@ cannot be notified of status change "
                  "because it doesn't respond to selector brandEngageClient:didChangeStatus:",
                  self.delegate);
    }
}

+ (UIViewController *)swapRootViewControllerTo:(UIViewController *)toVC
                          withAnimationOptions:(UIViewAnimationOptions)animationOptions
                                    completion:(void (^)(void))completion
{
#define kSPRootVCSwapAnimationDuration 1.0

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *fromVC = keyWindow.rootViewController;
    void (^animationCompletionHandler)(BOOL) = nil;

    if (completion) {
        animationCompletionHandler = ^(BOOL finished) {
        if (finished)
            completion();
        };
    }

    [UIView transitionFromView:fromVC.view
                        toView:toVC.view
                      duration:kSPRootVCSwapAnimationDuration
                       options:animationOptions
                    completion:animationCompletionHandler];

    [keyWindow setRootViewController:toVC];

    return fromVC;
}

#pragma mark - Currency name change notification

- (void)registerForCurrencyNameChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currencyNameChanged:)
                                                 name:SPCurrencyNameChangeNotification
                                               object:nil];
}

- (void)currencyNameChanged:(NSNotification *)notification
{
    if ([SPTargetedNotificationFilter instanceWithAppId:self.credentials.appId
                                                 userId:self.credentials.userId
                            shouldRespondToNotification:notification]) {
        id newCurrencyName = notification.userInfo[SPNewCurrencyNameKey];
        if ([newCurrencyName isKindOfClass:[NSString class]]) {
            self.currencyName = newCurrencyName;
            SPLogInfo(@"%@ currency name is now: %@", self, self.currencyName);
        }
    }
}

#pragma mark - Loading indicator

- (SPLoadingIndicator *)loadingProgressView
{
    if (nil == _loadingProgressView) {
        _loadingProgressView = [[SPLoadingIndicator alloc] initFullScreen:YES showSpinner:NO];
    }

    return _loadingProgressView;
}

- (void)animateLoadingViewIn
{
    [self.loadingProgressView presentWithAnimationTypes:SPAnimationTypeFade];
}

- (void)animateLoadingViewOut
{
    [[self loadingProgressView] dismiss];
}

#pragma mark - Custom Accessors

- (NSString *)placementId
{
    return _placementId ? _placementId : @"";
}

#pragma mark - NSObject selectors

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {appId=%@ userId=%@}", [super description], self.credentials.appId, self.credentials.userId];
}

#pragma mark - Credentials

- (NSString *)appId
{
    return self.credentials ? self.credentials.appId : nil;
}

- (NSString *)userId
{
    return self.credentials ? self.credentials.userId : nil;
}

@end
