//
//  SPVirtualCurrencyConnector.m
//  SponsorPay iOS SDK
//
//  Created by David Davila on 9/23/11.
//  Copyright (c) 2011 SponsorPay. All rights reserved.
//

#import "SPVirtualCurrencyServerConnector.h"
#import "SPVirtualCurrencyServerConnector_SDKPrivate.h"
#import "SPURLGenerator.h"
#import "SPSignature.h"
#import "SPLogger.h"
#import "SPPersistence.h"
#import "SponsorPaySDK.h"
#import "SPCredentials.h"

static NSString *const SP_CURRENCY_DELTA_REQUEST_RESOURCE = @"new_credit.json";


// URL parameters to pass on the query string
static NSString *const URL_PARAM_KEY_APP_ID = @"appid";
static NSString *const URL_PARAM_KEY_USER_ID = @"uid";
static NSString *const URL_PARAM_KEY_LAST_TRANSACTION_ID = @"ltid";
static NSString *const URL_PARAM_KEY_TIMESTAMP = @"timestamp";
static NSString *const URL_PARAM_CURRENCY_ID = @"currency_id";

static NSString *const SP_VCS_JSON_KEY_DELTA_OF_COINS = @"delta_of_coins";
static NSString *const SP_VCS_JSON_KEY_LATEST_TRANSACTION_ID = @"latest_transaction_id";
static NSString *const SP_VCS_JSON_KEY_CURRENCY_NAME = @"currency_name";
static NSString *const SP_VCS_JSON_KEY_IS_DEFAULT = @"is_default";

static NSString *const SP_VCS_JSON_KEY_ERROR_CODE = @"code";
static NSString *const SP_VCS_JSON_KEY_ERROR_MESSAGE = @"message";

static NSString *const SP_VCS_RESPONSE_SIGNATURE_HEADER = @"X-Sponsorpay-Response-Signature";

static NSString *const SP_VCS_LATEST_TRANSACTION_ID_VALUE_NO_TRANSACTION = @"NO_TRANSACTION";
static NSString *const SP_VCS_LATEST_TRANSACTION_IDS_KEY = @"SPVCSLatestTransactionIds";

static NSString *const SPVCSDefaultCurrencyIdKey = @"SPVCSDefaultCurrencyId";

NSString *const SPVCSPayoffReceivedNotification = @"SPVCSPayoffReceivedNotification";
NSString *const SPVCSPayoffAmountKey = @"SPVCSPayoffAmountKey";
NSString *const SPVCSCurrencyName = @"SPVCSCurrencyName";
NSString *const SPVCSTransactionIdKey = @"SPVCSTransactionIdKey";

@interface SPVirtualCurrencyServerConnector ()

@property (nonatomic, strong) SPCredentials *credentials;

@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (strong, readonly, nonatomic) NSString *responseString;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, strong) NSMutableArray *fetchDeltaOfCoinsCompletionBlocks;

@property (nonatomic, assign) BOOL requestDefaultCurrency;
@property (nonatomic, strong) NSString *defaultCurrencyId;
@property (nonatomic, copy) NSString *responseSignature;

@end

@implementation SPVirtualCurrencyServerConnector

@synthesize defaultCurrencyId = _defaultCurrencyId;

#pragma mark - Manually implemented property accessors

- (void)setCurrentConnection:(NSURLConnection *)connection
{
    if (_currentConnection) {
        [_currentConnection cancel];
    }
    _currentConnection = connection;
}

- (NSString *)defaultCurrencyId
{
    _defaultCurrencyId = [SPPersistence nestedValueWithPersistenceKey:SPVCSDefaultCurrencyIdKey nestedKeys:@[SPVCSCurrencyName] defaultingToValue:nil];
    return _defaultCurrencyId;
}

- (void)setDefaultCurrencyId:(NSString *)currencyId
{
    [SPPersistence setNestedValue:currencyId forPersistenceKey:SPVCSDefaultCurrencyIdKey nestedKeys:@[SPVCSCurrencyName]];
}

- (NSString *)latestTransactionId
{
    if (!_latestTransactionId) {
        _latestTransactionId = SP_VCS_LATEST_TRANSACTION_ID_VALUE_NO_TRANSACTION;
    }

    return _latestTransactionId;
}

- (NSString *)latestTransactionIdWithCurrencyId:(NSString *)currencyId
{
    NSString *latestTransactionId = [SPPersistence nestedValueWithPersistenceKey:SPVCSLatestTransactionIdsKey
                                                                     nestedKeys:@[self.credentials.appId, self.credentials.userId, currencyId]
                                                               defaultingToValue:SP_VCS_LATEST_TRANSACTION_ID_VALUE_NO_TRANSACTION];
    return latestTransactionId;
}

- (void)setLatestTransactionId:(NSString *)ltid currencyId:(NSString *)currencyId
{
    if (!ltid.length || !self.credentials.appId.length || !self.credentials.userId.length || !currencyId.length) {
        SPLogError(@"Could not persist transaction");
        return;
    }

    [SPPersistence setNestedValue:ltid forPersistenceKey:SPVCSLatestTransactionIdsKey nestedKeys:@[self.credentials.appId, self.credentials.userId, currencyId]];
}

- (NSString *)responseString
{
    NSString *bodyString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];

    return bodyString;
}

#pragma mark - Initializing and deallocating

- (void)dealloc
{
    self.delegate = nil;
    self.currentConnection = nil;
}

#pragma mark - VCS services

- (void)fetchDeltaOfCoins
{
    [self fetchDeltaOfCoinsWithCurrencyId:nil];
}

- (void)fetchDeltaOfCoinsWithCurrencyId:(NSString *)currencyId
{
    if (!currencyId.length) {
        self.requestDefaultCurrency = YES;
        currencyId = self.defaultCurrencyId;
    } else {
        self.requestDefaultCurrency = NO;
    }

    SPURLGenerator *urlGenerator = [SPURLGenerator URLGeneratorWithEndpoint:SPURLEndpointVCS];

    [urlGenerator setParameterWithKey:URL_PARAM_KEY_APP_ID stringValue:self.credentials.appId];
    [urlGenerator setParameterWithKey:URL_PARAM_KEY_USER_ID stringValue:self.credentials.userId];

    NSString *ltid = currencyId.length ? [self latestTransactionIdWithCurrencyId:currencyId] : SP_VCS_LATEST_TRANSACTION_ID_VALUE_NO_TRANSACTION;
    self.latestTransactionId = ltid;

    [urlGenerator setParameterWithKey:URL_PARAM_KEY_LAST_TRANSACTION_ID
                          stringValue:ltid];

    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]];
    [urlGenerator setParameterWithKey:URL_PARAM_KEY_TIMESTAMP integerValue:[timestamp integerValue]];

    if (!self.requestDefaultCurrency) {
        [urlGenerator setParameterWithKey:URL_PARAM_CURRENCY_ID stringValue:currencyId];
    }

    NSURL *urlForVCSRequest = [urlGenerator signedURLWithSecretToken:self.credentials.securityToken];

    SPLogDebug(@"VCS request will be sent with url: %@", urlForVCSRequest);

    NSURLRequest *request = [NSURLRequest requestWithURL:urlForVCSRequest
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:60.0];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    if (connection) {
        self.currentConnection = connection;
        self.responseData = [NSMutableData data];
    } else {
        SPLogError(@"Connection to SP VCS initialization failed (%@)", connection);
        [self notifyOfError:ERROR_OTHER errorCode:nil errorMessage:nil];
    }
}

#pragma mark - Response processing

- (void)processDeltaOfCoinsResponse:(NSDictionary *)responseDict
{
    NSString *currencyId = responseDict[URL_PARAM_CURRENCY_ID];
    BOOL isDefault = [responseDict[SP_VCS_JSON_KEY_IS_DEFAULT] boolValue];

    // On the first request, the default currencyId will be nil
    if (!self.defaultCurrencyId.length && isDefault) {
        self.defaultCurrencyId = currencyId;
    }

    // In case the default is different than stored - update
    // If we requested the default currency, we'll need to request again
    if (isDefault && ![self.defaultCurrencyId isEqualToString:currencyId]) {
        self.defaultCurrencyId = currencyId;

        if (self.requestDefaultCurrency){
            [self fetchDeltaOfCoins];
            return;
        }
    }

    NSString *deltaOfCoins = responseDict[SP_VCS_JSON_KEY_DELTA_OF_COINS];
    NSString *transactionId = responseDict[SP_VCS_JSON_KEY_LATEST_TRANSACTION_ID];
    NSString *currencyName = self.credentials.userConfig[SPVCSConfigCurrencyName] ?: responseDict[SP_VCS_JSON_KEY_CURRENCY_NAME];

    if (!deltaOfCoins.length || !transactionId.length) {
        SPLogError(@"Parsing SP VCS response failed: missing expected keys.");
        [self notifyOfError:ERROR_INVALID_RESPONSE errorCode:nil errorMessage:nil];
        return;
    }

    self.latestTransactionId = transactionId;
    [self setLatestTransactionId:transactionId currencyId:currencyId];

    [self notifyOfDeltaOfCoinsResponseReceivedWithAmount:deltaOfCoins
                                            currencyName:currencyName
                                     latestTransactionId:transactionId];
}

#pragma mark - Callback handling

- (void)notifyOfError:(SPVirtualCurrencyRequestErrorType)error
            errorCode:(NSString *)errorCode
         errorMessage:(NSString *)errorMessage
{
    if (self.delegate) {
        [self.delegate virtualCurrencyConnector:self failedWithError:error
                                      errorCode:errorCode
                                   errorMessage:errorMessage];
    }
}

- (void)notifyOfDeltaOfCoinsResponseReceivedWithAmount:(NSString *)amount
                                          currencyName:(NSString *)currencyName
                                   latestTransactionId:(NSString *)transactionId
{
    double amountAsDouble = [self amountAsDouble:amount];

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(virtualCurrencyConnector:didReceiveDeltaOfCoinsResponse:currencyName:latestTransactionId:)]){
            [self.delegate virtualCurrencyConnector:self
                     didReceiveDeltaOfCoinsResponse:amountAsDouble
                                       currencyName:currencyName
                                latestTransactionId:transactionId];
        } else if ([self.delegate respondsToSelector:@selector(virtualCurrencyConnector:didReceiveDeltaOfCoinsResponse:latestTransactionId:)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.delegate virtualCurrencyConnector:self didReceiveDeltaOfCoinsResponse:amountAsDouble latestTransactionId:transactionId];
#pragma clang diagnostic pop
        }
    }

    [self runCompletionBlocksWithAmount:amountAsDouble transactionId:transactionId];

    if (amountAsDouble > 0.0)
        [self postPayoffReceivedNotificationWithAmount:amountAsDouble currencyName:currencyName transactionId:transactionId];
}

- (double)amountAsDouble:(NSString *)amount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [[numberFormatter numberFromString:amount] doubleValue];
}

- (void)runCompletionBlocksWithAmount:(double)amount transactionId:(NSString *)transactionId
{
    if (self.fetchDeltaOfCoinsCompletionBlocks) {
        for (NSInteger i = [self.fetchDeltaOfCoinsCompletionBlocks count] - 1; i >= 0; i--) {
            SPVCSDeltaOfCoinsRequestCompletionBlock completionBlock =
            [self.fetchDeltaOfCoinsCompletionBlocks objectAtIndex:i];
            BOOL mustRemoveBlock;

            completionBlock(amount, transactionId, &mustRemoveBlock);

            if (mustRemoveBlock)
                [self.fetchDeltaOfCoinsCompletionBlocks removeObjectAtIndex:i];
        }
    }
}

- (void)postPayoffReceivedNotificationWithAmount:(double)amount currencyName:(NSString *)currencyName transactionId:(NSString *)transactionId
{
    SPLogDebug(@"VCS Connector posting payoff received notification with amount=%f, "
                "appId=%@ userId=@ currency=%@ notification key=%@",
               amount,
               self.credentials.appId,
               self.credentials.userId,
               currencyName,
               SPVCSPayoffReceivedNotification);

    NSDictionary *notificationInfo = @{
        SPAppIdKey: self.credentials.appId,
        SPUserIdKey: self.credentials.userId,
        SPVCSCurrencyName: currencyName,
        SPVCSPayoffAmountKey: @(amount),
        SPVCSTransactionIdKey: transactionId
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:SPVCSPayoffReceivedNotification
                                                        object:self
                                                      userInfo:notificationInfo];
}

- (void)addFetchDeltaOfCoinsCompletionBlock:(SPVCSDeltaOfCoinsRequestCompletionBlock)completionBlock
{
    if (!self.fetchDeltaOfCoinsCompletionBlocks) {
        self.fetchDeltaOfCoinsCompletionBlocks = [NSMutableArray arrayWithCapacity:1];
    }
    [self.fetchDeltaOfCoinsCompletionBlocks addObject:[completionBlock copy]];
}

#pragma mark - NSURLConnectionDelegate and NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.responseStatusCode = httpResponse.statusCode;
    NSDictionary *responseHeaders = [httpResponse allHeaderFields];
    self.responseSignature = responseHeaders[SP_VCS_RESPONSE_SIGNATURE_HEADER];

    SPLogInfo(@"Received response from SP VCS with status code: %d", self.responseStatusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    SPLogError(@"Connection to SP VCS failed with error: %@", error);
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        [self notifyOfError:ERROR_NO_INTERNET_CONNECTION errorCode:nil errorMessage:nil];
    } else {
        [self notifyOfError:ERROR_OTHER errorCode:nil errorMessage:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    SPLogDebug(@"Connection to SP VCS finished loading. Data: %p, Body: %@", self.responseData, self.responseString);

    NSDictionary *responseDict = [self parseResponseData:self.responseData];

    self.responseData = nil;

    if (responseDict) {
        [self processDeltaOfCoinsResponse:responseDict];
    }
}

- (NSDictionary *)parseResponseData:(NSData *)data
{
    NSError *parseResponseError = nil;

    id responseAsJson = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                        options:0
                                                          error:&parseResponseError];

    if (parseResponseError) {
        SPLogError(@"Parsing SP VCS response as JSON failed. Error is: %@", parseResponseError);
        [self notifyOfError:ERROR_INVALID_RESPONSE errorCode:nil errorMessage:nil];
        return nil;
    }

    if (![responseAsJson respondsToSelector:@selector(objectForKey:)]) {
        SPLogError(@"Parsing SP VCS response failed. It doesn't look like a valid dictionary");
        [self notifyOfError:ERROR_INVALID_RESPONSE errorCode:nil errorMessage:nil];
        return nil;
    }

    if (self.responseStatusCode != 200) { // server returned error
        NSString *errorCode = [responseAsJson objectForKey:SP_VCS_JSON_KEY_ERROR_CODE];
        NSString *errorMessage = [responseAsJson objectForKey:SP_VCS_JSON_KEY_ERROR_MESSAGE];

        [self notifyOfError:SERVER_RETURNED_ERROR errorCode:errorCode errorMessage:errorMessage];
        return nil;
    }

    BOOL isSignatureValid = [SPSignature isSignatureValid:self.responseSignature
                                                  forText:self.responseString
                                              secretToken:self.credentials.securityToken];
    if (!isSignatureValid) {
        [self notifyOfError:ERROR_INVALID_RESPONSE_SIGNATURE
                  errorCode:nil
               errorMessage:nil];
        return nil;
    }

    if (!responseAsJson[SP_VCS_JSON_KEY_CURRENCY_NAME] || !responseAsJson[SP_VCS_JSON_KEY_DELTA_OF_COINS] ||
        !responseAsJson[URL_PARAM_CURRENCY_ID] || !responseAsJson[SP_VCS_JSON_KEY_LATEST_TRANSACTION_ID] ||
        !responseAsJson[SP_VCS_JSON_KEY_IS_DEFAULT]) {
        [self notifyOfError:ERROR_INVALID_RESPONSE errorCode:nil errorMessage:@"Response missing required parameters"];
        return nil;
    }

    return responseAsJson;
}

#pragma mark - VCS base URL override


+ (NSString *)descriptionForErrorType:(SPVirtualCurrencyRequestErrorType)errorType
{
    switch (errorType) {
    case NO_ERROR:
        return @"NO_ERROR";
    case ERROR_NO_INTERNET_CONNECTION:
        return @"ERROR_NO_INTERNET_CONNECTION";
    case ERROR_INVALID_RESPONSE:
        return @"ERROR_INVALID_RESPONSE";
    case ERROR_INVALID_RESPONSE_SIGNATURE:
        return @"ERROR_INVALID_RESPONSE_SIGNATURE";
    case SERVER_RETURNED_ERROR:
        return @"SERVER_RETURNED_ERROR";
    case ERROR_OTHER:
        return @"ERROR_OTHER";
    default:
        return @"UNKNOWN";
    }
}

@end
