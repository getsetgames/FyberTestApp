//
//  Created by Piotr  on 18/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPURLRequest.h"
#import "SponsorPaySDK.h"
#import "SPUser.h"
#import "NSString+SPURLEncoding.h"

static NSTimeInterval const SPCallbackOperationTimeout = 60.0;
static NSTimeInterval const SPTenMinutes = 60.0 * 10.0;
NSString * const SPUserHeaderKey = @"X-User-Data";

@implementation SPURLRequest

+ (NSURLRequest *)requestWithURL:(NSURL *)url
{
    // Just override if needed
    return [NSURLRequest requestWithURL:url];
}

+ (NSURLRequest *)requestWithUserDataForURL:(NSURL *)url
{
    NSMutableURLRequest* mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                   timeoutInterval:SPCallbackOperationTimeout];

    SponsorPaySDK * sdk = [SponsorPaySDK instance];

    [self addUserHeaderKeyHeaderParameters:sdk.user.data toRequest:mutableRequest];

    return [mutableRequest copy];
}


+ (void)requestWithUserDataForURL:(NSURL *)url shouldUpdateLocation:(BOOL)shouldUpdate completionBlock:(void (^)(NSURLRequest *urlRequest))block
{
    // If request is without location update or, time to update location didn't elapsed, request user data with cached location by calling `-requestWithUserDataForURL`
    // Note: The location update occurs with 10 minute interval
    if (!shouldUpdate || ![[self class] timeElapsedForLoactionUpdate]) {
        if (block) {
            block([[self class] requestWithUserDataForURL:url]);
        }
        return;
    }

    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                   timeoutInterval:SPCallbackOperationTimeout];

    SponsorPaySDK *sdk = [SponsorPaySDK instance];

    [sdk.user dataWithCurrentLocation:^(NSDictionary *data) {

        [self addUserHeaderKeyHeaderParameters:data toRequest:mutableRequest];

        if (block) {
            block([mutableRequest copy]);
        }

    }];
}

+ (BOOL) timeElapsedForLoactionUpdate {
    static NSTimeInterval __locationUpdateTimeStamp;
    BOOL locationShouldUpdate = NO;

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    if (__locationUpdateTimeStamp == 0) {
        __locationUpdateTimeStamp = now;
        locationShouldUpdate = YES;
    }

    if (now > __locationUpdateTimeStamp + SPTenMinutes) {
        __locationUpdateTimeStamp = now;
        locationShouldUpdate = YES;
    }

    return locationShouldUpdate;
}

#pragma mark - Private

+ (void)addUserHeaderKeyHeaderParameters:(NSDictionary *)parameters toRequest:(NSMutableURLRequest *)mutableRequest
{
    __block NSString *values = @"";

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        // URL Encode each key and value
        values = [values stringByAppendingFormat:@"&%@=%@", [key SPURLEncodedString], [[obj description] SPURLEncodedString]];
    }];

    // Remove first character
    if (values.length > 0) {
        values = [values substringFromIndex:1];
        SPLogDebug(@"Adding header to request %@: %@", SPUserHeaderKey, values);
        [mutableRequest addValue:values forHTTPHeaderField:SPUserHeaderKey];
    }


}

@end