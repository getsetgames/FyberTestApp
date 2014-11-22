//
//  SPURLGenerator.m
//  SponsorPay iOS SDK
//
//  Copyright 2011-2013 SponsorPay. All rights reserved.
//

#import <objc/runtime.h>

#import "SPURLGenerator.h"
#import "SPSignature.h"
#import "SPLogger.h"

#import "SPOrientationProvider.h"
#import "SPSystemParametersProvider.h"
#import "SPLocaleParametersProvider.h"
#import "SPNetworkParametersProvider.h"
#import "SPHostAppBundleParametersProvider.h"
#import "SPJailbreakStatusProvider.h"
#import "SPScreenMetricsProvider.h"
#import "SPAppleAdvertiserIDProvider.h"
#import "SPSDKVersionProvider.h"
#import "SPMacAddressProvider.h"
#import "SPMD5MacAddressProvider.h"
#import "SPSHA1MacAddressProvider.h"
#import "SPSDKFeaturesProvider.h"
#import "NSString+SPURLEncoding.h"
#import "SPCredentials.h"
#import "SPVersionChecker.h"

static NSString *const kSPURLParamKeySignature = @"signature";

static NSString *const kSPURLParamKeyAppID = @"appid";
static NSString *const kSPURLParamKeyUserID = @"uid";

NSString *const kSPURLParamKeyAllowCampaign = @"allow_campaign";
NSString *const kSPURLParamValueAllowCampaignOn = @"on";
NSString *const kSPURLParamKeySkin = @"skin";
NSString *const kSPURLParamKeyOffset = @"offset";
NSString *const kSPURLParamKeyBackground = @"background";
NSString *const kSPURLParamKeyCurrencyName = @"currency";
NSString *const kSPURLParamKeyClient = @"client";
NSString *const kSPURLParamKeyPlatform = @"platform";
NSString *const kSPURLParamKeyRewarded = @"rewarded";
NSString *const kSPURLParamKeyAdFormat = @"ad_format";

static NSString *const kSPURLParamValuePlatform = @"ios";
static NSString *const kSPURLParamValueClient = @"sdk";
@interface SPURLGenerator ()

@property (readonly, strong) NSMutableDictionary *parametersDictionary;
@property (readonly, strong) NSMutableSet *parameterProviders;

@end

@implementation SPURLGenerator {
    NSMutableDictionary *_parametersDictionary;
    NSMutableSet *_parameterProviders;
}

#pragma mark - Initialization and configuration

- (id)initWithBaseURLString:(NSString *)baseURLString
{
    self = [super init];

    if (self) {
        self.baseURLString = baseURLString;
        [self addParametersProviders];
    }

    return self;
}

- (id)initWithEndpoint:(SPURLEndpoint)endpoint
{
    self = [super init];

    if (self) {
        self.baseURLString = [[SPBaseURLProvider sharedInstance] urlForEndpoint:endpoint];
        [self addParametersProviders];
    }

    return self;
}

- (void)setCredentials:(SPCredentials *)credentials
{
    if (credentials) {
        if (credentials.appId) {
            [self setParameterWithKey:kSPURLParamKeyAppID stringValue:credentials.appId];
        }
        if (credentials.userId) {
            [self setParameterWithKey:kSPURLParamKeyUserID stringValue:credentials.userId];
        }

    } else {
        [self setParameterWithKey:kSPURLParamKeyAppID stringValue:nil];
        [self setParameterWithKey:kSPURLParamKeyUserID stringValue:nil];
    }
}

- (void)setParameterWithKey:(NSString *)key stringValue:(NSString *)stringValue
{
    if (stringValue) {
        (self.parametersDictionary)[key] = stringValue;
    }
}

- (void)setParameterWithKey:(NSString *)key integerValue:(NSInteger)integerValue
{
    [self setParameterWithKey:key stringValue:[NSString stringWithFormat:@"%ld", (long)integerValue]];
}

- (void)setParametersFromDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsWithOptions:0
                                        usingBlock:^(id key, id obj, BOOL *stop) {
                                        NSString *value = [obj isKindOfClass:[NSString class]] ? obj : [obj stringValue];
                                        [self setParameterWithKey:key stringValue:value];
                                        }];
}

- (void)addParametersProvider:(id<SPURLParametersProvider>)paramsProvider
{
    if (paramsProvider)
        [self.parameterProviders addObject:paramsProvider];
}

- (void)addParametersProviderWithClass:(Class)paramsProviderClass
{
    NSAssert(class_conformsToProtocol(paramsProviderClass, @protocol(SPURLParametersProvider)),
             @"Parameters Provider's class %s must conform to the SPURLParametersProvider protocol.",
             class_getName(paramsProviderClass));

    id<SPURLParametersProvider> paramsProvider = (id <SPURLParametersProvider>) [[paramsProviderClass alloc] init];
    [self addParametersProvider:paramsProvider];
}

- (void)removeParametersProvider:(id<SPURLParametersProvider>)paramsProvider
{
    [self.parameterProviders removeObject:paramsProvider];
}

- (void)removeParameterProviderWithClass:(Class)paramsProviderClass
{
    __block id paramsProviderToRemove = nil;

    [self.parameterProviders enumerateObjectsWithOptions:NSEnumerationConcurrent
                                              usingBlock:^(id obj, BOOL *stop) {
                                              if ([obj isMemberOfClass:paramsProviderClass]) {
                                                  paramsProviderToRemove = obj;
                                                  *stop = YES;
                                              }
                                              }];

    if (paramsProviderToRemove) {
        [self removeParametersProvider:paramsProviderToRemove];
    }
}

#pragma mark - Global custom parameters

static id<SPURLParametersProvider> globalCustomParametersProvider;

+ (void)setGlobalCustomParametersProvider:(id<SPURLParametersProvider>)provider
{
    globalCustomParametersProvider = provider;
}

#pragma mark - URL generation

- (NSURL *)generatedURL
{
    return [NSURL URLWithString:[self generatedURLString]];
}

- (NSString *)generatedURLString
{
    return [self.baseURLString stringByAppendingString:[self stringOfEncodedParameters]];
}

- (NSURL *)signedURLWithSecretToken:(NSString *)secretToken
{
    return [NSURL URLWithString:[self signedURLStringWithSecretToken:secretToken]];
}

- (NSString *)signedURLStringWithSecretToken:(NSString *)secretToken
{
    return
    [NSString stringWithFormat:@"%@&%@=%@", [self generatedURLString], kSPURLParamKeySignature, [self signatureWithToken:secretToken]];
}

- (NSString *)stringOfEncodedParameters
{
    [self setParametersFromProviders];

    NSMutableString *encodedParams = [NSMutableString stringWithCapacity:255];
    BOOL isFirstParameter = YES;
    for (NSString *currKey in self.parametersDictionary) {
        NSString *currValue = [(self.parametersDictionary)[currKey] SPURLEncodedString];
        [encodedParams appendFormat:@"%@%@=%@", isFirstParameter ? @"?" : @"&", currKey, currValue];
        if (isFirstParameter)
            isFirstParameter = NO;
    }

    return encodedParams;
}

- (void)setParametersFromProviders
{
    [self.parameterProviders enumerateObjectsWithOptions:0
                                              usingBlock:^(id parametersProvider, BOOL *stop) {
                                              [self setParametersFromDictionary:[parametersProvider dictionaryWithKeyValueParameters]];
                                              }];

    if (globalCustomParametersProvider) {
        [self setParametersFromDictionary:[globalCustomParametersProvider dictionaryWithKeyValueParameters]];
    }
}

- (NSString *)signatureWithToken:(NSString *)token
{
    NSArray *paramKeys = [self.parametersDictionary allKeys];
    NSArray *orderedParamKeys = [paramKeys sortedArrayUsingSelector:@selector(compare:)];

    NSMutableString *concatenatedOrderedParams = [[NSMutableString alloc] initWithCapacity:255];
    NSEnumerator *e = [orderedParamKeys objectEnumerator];
    for (NSString *paramKey = [e nextObject]; nil != paramKey; paramKey = [e nextObject]) {
        NSString *paramValue = (self.parametersDictionary)[paramKey];
        NSString *keyValueParam = [NSString stringWithFormat:@"%@=%@&", paramKey, paramValue];
        [concatenatedOrderedParams appendString:keyValueParam];
    }

    NSString *signature = [SPSignature signatureForString:concatenatedOrderedParams secretToken:token];
    return signature;
}

#pragma mark - Housekeeping

- (NSMutableDictionary *)parametersDictionary
{
    if (!_parametersDictionary) {
        _parametersDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _parametersDictionary;
}

- (NSMutableSet *)parameterProviders
{
    if (!_parameterProviders) {
        _parameterProviders = [[NSMutableSet alloc] initWithCapacity:14];
    }
    return _parameterProviders;
}


#pragma mark - Static factory

+ (SPURLGenerator *)URLGeneratorWithBaseURLString:(NSString *)baseUrl
{
    SPURLGenerator *urlGenerator = [[SPURLGenerator alloc] initWithBaseURLString:baseUrl];

    return urlGenerator;
}

- (void)addParametersProviders
{
    [self addParametersProviderWithClass:[SPSystemParametersProvider class]];
    [self addParametersProviderWithClass:[SPLocaleParametersProvider class]];
    [self addParametersProviderWithClass:[SPOrientationProvider class]];
    [self addParametersProviderWithClass:[SPJailbreakStatusProvider class]];
    [self addParametersProviderWithClass:[SPScreenMetricsProvider class]];
    [self addParametersProviderWithClass:[SPNetworkParametersProvider class]];
    [self addParametersProviderWithClass:[SPHostAppBundleParametersProvider class]];
    [self addParametersProviderWithClass:[SPAppleAdvertiserIDProvider class]];
    [self addParametersProviderWithClass:[SPSDKVersionProvider class]];
    [self addParametersProviderWithClass:[SPSDKFeaturesProvider class]];
    [self setParameterWithKey:kSPURLParamKeyPlatform stringValue:kSPURLParamValuePlatform];
    [self setParameterWithKey:kSPURLParamKeyClient stringValue:kSPURLParamValueClient];

    if (SPFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
#ifndef kSPShouldNotSendPlainMACAddress
        [self addParametersProviderWithClass:[SPMacAddressProvider class]];
#endif

#ifndef kSPShouldNotSendMD5MacAddress
        [self addParametersProviderWithClass:[SPMD5MacAddressProvider class]];
#endif

#ifndef kSPShouldNotSendSHA1MacAddress
        [self addParametersProviderWithClass:[SPSHA1MacAddressProvider class]];
#endif
    }
}

+ (SPURLGenerator *)URLGeneratorWithEndpoint:(SPURLEndpoint)endpoint
{
    NSString *baseUrl = [[SPBaseURLProvider sharedInstance] urlForEndpoint:endpoint];
    return [SPURLGenerator URLGeneratorWithBaseURLString:baseUrl];
}

@end
