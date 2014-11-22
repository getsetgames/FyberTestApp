//
//  EbzError.h
//  EbuzzingSDKTest
//
//  Created by Ibrahim Ennafaa on 10/03/2014.
//  Copyright (c) 2014 Ebuzzing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EbzErrorEnum {
	EbzNetworkError = 0,
	EbzAdServerError = 1,
	EbzAdServerBadResponse = 2,
	EbzAdFailsToLoad = 3,
    EbzNoAdsAvailable = 4,
} EbzErrorType;

@interface EbzError : NSObject

-(BOOL)isType:(EbzErrorType)errorType;

@property (nonatomic) EbzErrorType code;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *message;

+(EbzError*)EbzNetworkError;
+(EbzError*)EbzAdServerError;
+(EbzError*)EbzAdServerBadResponse;
+(EbzError*)EbzAdFailsToLoad;
+(EbzError*)EbzNoAdsAvailable;

@end
