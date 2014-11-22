//
//  SPPersistence.h
//  SponsorPay iOS SDK
//
//  Created by David Davila on 9/28/11.
//  Copyright (c) 2011 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const SPAdvertiserCallbackSuccessKey;
FOUNDATION_EXPORT NSString *const SPActionCallbackSuccessKey;
FOUNDATION_EXPORT NSString *const SPVCSLatestTransactionIdsKey;

@interface SPPersistence : NSObject

+ (BOOL)didAdvertiserCallbackSucceed;

+ (void)setDidAdvertiserCallbackSucceed:(BOOL)successValue;

+ (BOOL)didActionCallbackSucceedForActionId:(NSString *)actionId;

+ (void)setDidActionCallbackSucceed:(BOOL)successValue forActionId:(NSString *)actionId;

+ (id)nestedValueWithPersistenceKey:(NSString *)persistenceKey nestedKeys:(NSArray *)nestedKeys defaultingToValue:(id)defaultValue;

+ (void)setNestedValue:(id)value forPersistenceKey:(NSString *)persistenceKey nestedKeys:(NSArray *)nestedKeys;

+ (void)resetAllSDKValues;

@end
