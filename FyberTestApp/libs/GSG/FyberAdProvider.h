//
//  FyberAdProvider.h
//  GSG
//
//  Created by Robert Segal on 2014-09-29.
//  Copyright (c) 2014 Get Set Games. All rights reserved.
//

#import "GSGGenericAdProvider.h"
#import "SponsorPaySDK.h"

@interface FyberAdProvider : GSGGenericAdProvider <SPVirtualCurrencyConnectionDelegate, SPBrandEngageClientDelegate>

@property (nonatomic, readwrite, assign) BOOL areOffersAvailable;
@property (nonatomic, readwrite, retain) id client;

@end
