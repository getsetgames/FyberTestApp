//
//  SPInterstitialViewController.m
//  SponsorPaySDK
//
//  Created by tito on 17/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPSSInterstitialViewController.h"
#import "SPSSInterstitialDelegate.h"
#import "SPCloseButton.h"
#import "SPInterstitialHTMLOffer.h"
#import "SPStoreKitManager.h"
#import "SPLoadingIndicator.h"
#import "SPSchemeParser.h"
#import "SPScheme.h"
#import "SPCloseButton+SPFrameHelper.h"
#import "SPVersionChecker.h"
#import "SPLogger.h"


typedef NS_ENUM(NSUInteger , SPSSInterstitialStatus) {
    SPSSInterstitialStatusFinishedByUser,
    SPSSInterstitialStatusLeaveApplication,
};

@interface SPSSInterstitialViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) SPInterstitialOffer *interstitial;

@property (nonatomic, strong) SPLoadingIndicator *loadingIndicator;


@end


@implementation SPSSInterstitialViewController


#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"Use designated initializer %@", NSStringFromSelector(@selector(initWithInterstitialOffer:)));
    }
    return self;
}


- (id)initWithInterstitialOffer:(SPInterstitialOffer *)interstitial
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        self.interstitial = interstitial;
        self.alertViewClass = [UIAlertView class];
        self.storeKitStoreProductClass = [SKStoreProductViewController class];


    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.loadingIndicator = [[SPLoadingIndicator alloc] initFullScreen:NO showSpinner:YES];

    // setup webview
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.clipsToBounds = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];

    //setup close button
    self.closeButton = [[SPCloseButton alloc] init];
    [self.closeButton addTarget:self action:@selector(dismissInterstitial:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.closeButton.frame = [self.closeButton frameForCloseButtonInInterstitialInFrame:self.view.bounds];

    self.webView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self preloadInterstitial];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([self.delegate respondsToSelector:@selector(interstitialDidPresentScreen:)]) {
        [self.delegate interstitialDidPresentScreen:self.interstitial];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.interstitial = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private

/**
 *  Triggers the loading of the interstitial offer. This method can be exposed again publicly in case we need
 *  to preload the interstitial as soon as we get the offer
 */
- (void)preloadInterstitial
{
    if (self.interstitial.type == SPSSInterstitialTypeHTML) {
        [self.loadingIndicator presentWithAnimationTypes:SPAnimationTypeNone];
        NSAssert([self.interstitial isKindOfClass:[SPInterstitialHTMLOffer class]], @"Expected %@", NSStringFromClass([SPInterstitialHTMLOffer class]));
        SPInterstitialHTMLOffer *htmlOffer = (SPInterstitialHTMLOffer *) self.interstitial;
        NSString *html = htmlOffer.html;
        [self.webView loadHTMLString:html baseURL:nil];
    }
}


- (void)dismissAnimated:(BOOL)animated withStatus:(SPSSInterstitialStatus) status {

    [self.loadingIndicator dismiss];
    SEL delegateMethodSelector;
    if (status == SPSSInterstitialStatusFinishedByUser) {
        delegateMethodSelector = @selector(interstitialDidDismissScreen:);
    } else {
        delegateMethodSelector = @selector(interstitialWillLeaveApplication:);
    }

    [self dismissViewControllerAnimated:animated completion:^{
        if ([self.delegate respondsToSelector:delegateMethodSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:delegateMethodSelector withObject:self.interstitial];
#pragma clang diagnostic pop
        }
    }];
}

- (void)dismissInterstitial:(id)sender
{
    [self dismissAnimated:NO withStatus:SPSSInterstitialStatusFinishedByUser];
}

- (void)openITunesWithAppId:(NSString *)appId trackingURL:(NSURL *)trackingURL requestsClosing:(BOOL)requestsClosing closeStatus:(NSInteger)closeStatus
{
    [self.loadingIndicator presentWithAnimationTypes:SPAnimationTypeNone];

    [[SPStoreKitManager sharedInstance] openStoreWithAppId:appId trackingURL:trackingURL affiliateToken:nil campaignToken:nil success:^(BOOL result, SKStoreProductViewController *productViewController) {
        [self.loadingIndicator dismiss];
        [self presentViewController:productViewController animated:YES completion:nil];
    } failure:^(NSError *error) {
        [self.loadingIndicator dismiss];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"An error occured", nil)
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    } didFinish:^(SKStoreProductViewController *productViewController) {
        if (requestsClosing) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self dismissAnimated:YES withStatus:SPSSInterstitialStatusLeaveApplication];
            }];
        }
    } didOpenWithSafari:^(NSURL *openedURL) {
        [self.loadingIndicator dismiss];
        if (requestsClosing) {
            [self dismissAnimated:YES withStatus:SPSSInterstitialStatusLeaveApplication];
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    /**
     * URL Samples:
     *
     * sponsorpay://exit?url=https%3A%2F%2Fitunes.apple.com%2Fus%2Fapp%2Fborrow-get-back-whats-yours%2Fid870827750%3Fmt%3D8&tracking_url=http%3A%2F%2Fwww.apple.com
     * Fire a request to TRACKING_URL and open URL in SAFARI
     *
     * sponsorpay://exit?url=https%3A%2F%2Fitunes.apple.com%2Fus%2Fapp%2Fborrow-get-back-whats-yours%2Fid870827750%3Fmt%3D8
     * Open URL in SAFARI
     *
     * sponsorpay://install?id=870827750&tracking_url=http://www.apple.com
     * Fire a request to TRACKING_URL and open ID in StoreKit (if present) or Safari
     *
     * sponsorpay://install?id=870827750
     * Open URL in SAFARI
     *
     **/

    SPScheme *scheme = [SPSchemeParser parseUrl:request.URL];

    // is this all the time yes for interstitial ?
    scheme.shouldRequestCloseWhenOpeningExternalURL = YES;

    if (![scheme isSponsorPayScheme]) {
        // case for RTB where we open links outside of the app
        BOOL openExtern = [[UIApplication sharedApplication] canOpenURL:request.URL];
        if (openExtern) {
            SPLogDebug(@"Opening external URL %@", request.URL.absoluteString);
            [[UIApplication sharedApplication] openURL:request.URL];
            [self dismissAnimated:YES withStatus:SPSSInterstitialStatusLeaveApplication];
        }
        return !openExtern;
    }

    switch (scheme.commandType) {
    // Exit Command
    case SPSchemeCommandTypeExit: {
        BOOL openingExternalDestination = scheme.requestsOpeningExternalDestination;

        if (openingExternalDestination) {
            [[UIApplication sharedApplication] openURL:scheme.externalDestination];
        }

        if (scheme.requestsClosing) {
            [self dismissAnimated:YES withStatus:openingExternalDestination ? SPSSInterstitialStatusLeaveApplication : SPSSInterstitialStatusFinishedByUser];
        }
        break;
    }

    // Install Command
    case SPSchemeCommandTypeInstall: {
        [self openITunesWithAppId:scheme.appId
                      trackingURL:scheme.trackingUrl
                  requestsClosing:scheme.requestsClosing
                      closeStatus:scheme.closeStatus];
        break;
    }

    default:
        break;
    }

    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%s", sel_getName(_cmd));
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator dismiss];
    NSLog(@"%s", sel_getName(_cmd));
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingIndicator dismiss];
    NSLog(@"%s", sel_getName(_cmd));
    if ([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
        [self.delegate interstitial:self.interstitial didFailToLoadAdWithError:error];
    }
}


#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (SPFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0) {
        BOOL forcePortrait = (UIInterfaceOrientationIsPortrait(interfaceOrientation) && UIInterfaceOrientationIsPortrait(self.forcedOrientation));
        BOOL forceLandscape = (UIInterfaceOrientationIsLandscape(interfaceOrientation) && UIInterfaceOrientationIsLandscape(self.forcedOrientation));

        if (forcePortrait || forceLandscape) {
            return YES;
        }
    }

    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.forcedOrientation;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#endif

@end
