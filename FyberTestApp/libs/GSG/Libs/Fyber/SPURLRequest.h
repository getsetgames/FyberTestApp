//
//  SPURLRequest.h
//  SponsorPaySDK
//
//  Created by Piotr  on 18/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SPUserHeaderKey;

@interface SPURLRequest : NSObject

/**
 Creates and returns a URL request for a specified URL with default cache policy and timeout value.
 This is a convinient method. Should be restructured as needed.

 @param url The URL for the new request.
 @note Use this method for across SDK
 */
+ (NSURLRequest *) requestWithURL:(NSURL *)url;

/**
 Creates and returns a URL request for a specified URL with user data information attached to the header.

 @param url The URL for the new request
 @note Use this method every time the user info is required to be attached in request
 */
+ (NSURLRequest *) requestWithUserDataForURL:(NSURL *)url;

/**
 Creates and returns a URL request for a specified URL with user data information attached to the header with current loaction update as an option.

 @param url The URL for the new request
 @param shouldUpdate Indicates whether user's location should be automatically included. This only updates when the user's `Core Location` service is enabled
 @param block The block to be excecuted on the completion of user data request. This block has no return value and takes 1 argument: the `url request`.
 */
+ (void)requestWithUserDataForURL:(NSURL *)url shouldUpdateLocation:(BOOL)shouldUpdate completionBlock:(void(^)(NSURLRequest *urlRequest))block;

@end
