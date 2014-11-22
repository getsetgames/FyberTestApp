//
//  SPUser.m
//  SponsorPaySDK
//
//  Created by Piotr  on 08/07/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPUser.h"
#import "SPLogger.h"
#import "CLLocationManager+SPLocation.h"

typedef void (^SPLocationCompletionBlock)(NSDictionary *data);

@interface SPUser () <CLLocationManagerDelegate> {

}

@property (nonatomic, strong) NSMutableDictionary       *privateData;
@property (nonatomic, copy) SPLocationCompletionBlock   locationCompletionBlock;
@property (nonatomic, strong) CLLocationManager         *locationManager;
@property (nonatomic, strong) CLLocation                *manualLocation;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SPUser



#pragma mark -  Public

- (void)setAge:(NSInteger)age
{
    if (age == SPEntryIgnore) {
        [self.privateData removeObjectForKey:SPUserAgeKey];
        return;
    }

    self.privateData[SPUserAgeKey] = @(age);
}

-  (void)setBirthdate:(NSDate *)date
{
    if (!date) {
        [self.privateData removeObjectForKey:SPUserBirthdateKey];
        return;
    }

    NSString *dob = [self.dateFormatter stringFromDate:date];

    (self.privateData)[SPUserBirthdateKey] = dob;
}

-  (void)setGender:(SPUserGender)gender
{
    if (gender == SPUserGenderUndefined || !SPUserMappingGender[gender]) {
        [self.privateData removeObjectForKey:SPUserGenderKey];
        return;
    }
    (self.privateData)[SPUserGenderKey] = SPUserMappingGender[gender];

}

- (void)setSexualOrientation:(SPUserSexualOrientation)sexualOrientation
{
    if (sexualOrientation == SPUserSexualOrientationUndefined || !SPUserMappingSexualOrientation[sexualOrientation]) {
        [self.privateData removeObjectForKey:SPUserSexualOrientationKey];
        return;
    }

    (self.privateData)[SPUserSexualOrientationKey] = SPUserMappingSexualOrientation[sexualOrientation];

}

- (void)setEthnicity:(SPUserEthnicity)ethnicity
{
    if (ethnicity == SPUserEthnicityUndefined || !SPUserMappingEthnicity[ethnicity]) {
        [self.privateData removeObjectForKey:SPUserEthnicityKey];
        return;
    }

    (self.privateData)[SPUserEthnicityKey] = SPUserMappingEthnicity[ethnicity];

}

- (void)setLocation:(CLLocation *)geoLocation
{
    if (!geoLocation) {
        [self.privateData removeObjectForKey:SPUserLocationLongitude];
        [self.privateData removeObjectForKey:SPUserLocationLatitude];
        self.manualLocation = nil;
        return;
    }
    self.manualLocation = geoLocation;

    CLLocationDegrees lat = geoLocation.coordinate.latitude;
    CLLocationDegrees lon = geoLocation.coordinate.longitude;

    // Let's keep as string for the sake of consistency
    self.privateData[SPUserLocationLongitude]   = [@(lon) stringValue];
    self.privateData[SPUserLocationLatitude]    = [@(lat) stringValue];

}

- (void)setMaritalStatus:(SPUserMaritalStatus)status
{
    if (status == SPUserMaritalStatusUndefined || !SPUserMappingMaritalStatus[status]) {
        [self.privateData removeObjectForKey:SPUserMaritalStatusKey];
        return;
    }

    (self.privateData)[SPUserMaritalStatusKey] = SPUserMappingMaritalStatus[status];
}

- (void)setNumberOfChildren:(NSInteger)numberOfChildren
{
    if (numberOfChildren == SPEntryIgnore) {
        [self.privateData removeObjectForKey:SPUserNumberOfChildrenKey];
        return;
    }
    self.privateData[SPUserNumberOfChildrenKey] = @(numberOfChildren);
}

- (void)setAnnualHouseholdIncome:(NSInteger)income
{
    if (income == SPEntryIgnore) {
        [self.privateData removeObjectForKey:SPUserAnnualHouseholdIncomeKey];
        return;
    }

    (self.privateData)[SPUserAnnualHouseholdIncomeKey] = @(income);
}

- (void)setEducation:(SPUserEducation)education
{
    if (education == SPUserEducationUndefined || !SPUserMappingEducation[education]) {
        [self.privateData removeObjectForKey:SPUserEducationKey];
        return;
    }

    (self.privateData)[SPUserEducationKey] = SPUserMappingEducation[education];
}

- (void)setZipcode:(NSString *)zipcode
{
    if (![zipcode length]) {
        [self.privateData removeObjectForKey:SPUserZipCodeKey];
        return;
    }

    (self.privateData)[SPUserZipCodeKey] = zipcode;
}

- (void)setInterests:(NSArray *)interests
{
    if (![interests count]) {
        [self.privateData removeObjectForKey:SPUserInterestsKey];
        return;
    }

    __block NSMutableString *arguments = [NSMutableString string];
    [interests enumerateObjectsUsingBlock:^(NSString *interest, NSUInteger idx, BOOL *stop) {
        if (idx) {
            [arguments appendString:@","];
        }
        [arguments appendFormat:@"%@", interest];
    }];

    self.privateData[SPUserInterestsKey] = [arguments copy];
}

#pragma mark -  

- (void)setIap:(BOOL)flag
{
    self.privateData[SPUserIapKey] = flag ? @"true" : @"false";
}

- (void)setIapAmount:(CGFloat)amount
{
    self.privateData[SPUserIapAmountKey] = @(amount);
}

- (void)setNumberOfSessions:(NSInteger)numberOfSessions
{
    self.privateData[SPUserNumberOfSessionsKey] = @(numberOfSessions);
}

- (void)setPsTime:(NSTimeInterval)timestamp
{
    self.privateData[SPUserPsTimeKey] = @(timestamp);
}

- (void)setLastSession:(NSTimeInterval)session
{
    self.privateData[SPUserLastSessionKey] = @(session);
}

- (void)setConnectionType:(SPUserConnectionType)connectionType
{
    if (connectionType == SPUserConnectionTypeUndefined || !SPUserMappingConnectionType[connectionType]) {
        [self.privateData removeObjectForKey:SPUserConnectionTypeKey];
        return;
    }

    self.privateData[SPUserConnectionTypeKey] = SPUserMappingConnectionType[connectionType];
}

- (void)setDevice:(SPUserDevice)device
{
    if (device == SPUserDeviceUndefined || !SPUserMappingDevice[device]) {
        [self.privateData removeObjectForKey:SPUserDeviceKey];
        return;
    }

    self.privateData[SPUserDeviceKey] = SPUserMappingDevice[device];
}

- (void)setVersion:(NSString *)version
{
    if (![version length]) {
        [self.privateData removeObjectForKey:SPUserVersionKey];
        return;
    }

    (self.privateData)[SPUserVersionKey] = version;
}

- (void)setCustomParameters:(NSDictionary *)parameters
{
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        (self.privateData)[key] = obj;
    }];

}

#pragma mark -  Getters

- (NSInteger)age
{
    if (!self.privateData[SPUserAgeKey]) {
        return SPEntryIgnore;
    }
    return [self.privateData[SPUserAgeKey] integerValue];
}

- (NSDate *)birthdate
{
    NSString *dateString = self.privateData[SPUserBirthdateKey];

    NSDate *date = [self.dateFormatter dateFromString:dateString];
    return date;
}

- (SPUserGender)gender
{
    if (self.privateData[SPUserGenderKey]) {
        NSInteger i = [self indexOfValue:self.privateData[SPUserGenderKey] key:SPUserMappingGender];
        return (SPUserGender) i;
    }
    return SPUserGenderUndefined;
}

- (SPUserSexualOrientation)sexualOrientation
{
    if (self.privateData[SPUserSexualOrientationKey]) {
        NSInteger i = [self indexOfValue:self.privateData[SPUserSexualOrientationKey] key:SPUserMappingSexualOrientation];
        return (SPUserSexualOrientation) i;
    }
    return SPUserSexualOrientationUndefined;
}

- (SPUserEthnicity)ethnicity
{
    if (self.privateData[SPUserEthnicityKey]) {
        NSInteger i = [self indexOfValue:self.privateData[SPUserEthnicityKey] key:SPUserMappingEthnicity];
        return (SPUserEthnicity) i;
    }
    return SPUserEthnicityUndefined;
}

- (CLLocation *)location
{
    BOOL locationValid = YES;
    locationValid &= self.privateData[SPUserLocationLatitude] != nil;
    locationValid &= self.privateData[SPUserLocationLongitude] != nil;

    if (!locationValid) {
        return nil;
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.privateData[SPUserLocationLatitude] doubleValue]
                                                      longitude:[self.privateData[SPUserLocationLongitude] doubleValue]];
    return location;
}

- (SPUserMaritalStatus)maritalStatus
{
    if (self.privateData[SPUserMaritalStatusKey]) {
        NSInteger i = [self indexOfValue:self.privateData[SPUserMaritalStatusKey] key:SPUserMappingMaritalStatus];
        return (SPUserMaritalStatus) i;
    }
    return SPUserMaritalStatusUndefined;
}

- (NSInteger)numberOfChildren
{
    if (!self.privateData[SPUserNumberOfChildrenKey]) {
        return SPEntryIgnore;
    }
    return [self.privateData[SPUserNumberOfChildrenKey] integerValue];
}

- (NSInteger) annualHouseholdIncome
{
    if (!self.privateData[SPUserAnnualHouseholdIncomeKey]) {
        return SPEntryIgnore;
    }
    return [self.privateData[SPUserAnnualHouseholdIncomeKey] integerValue];
}

- (SPUserEducation)education
{
    if (self.privateData[SPUserEducationKey]) {
        NSInteger i = [self indexOfValue:self.privateData[SPUserEducationKey] key:SPUserMappingEducation];
        return (SPUserEducation) i;
    }
    return SPUserEducationUndefined;
}

- (NSString *)zipcode
{
    return self.privateData[SPUserZipCodeKey];
}

- (NSArray *)interests
{
    NSString *arguments = self.privateData[SPUserInterestsKey];
    NSArray *interests = [arguments componentsSeparatedByString:@","];
    return interests;
}


#pragma mark - 

- (BOOL)iap
{
    return [self.privateData[SPUserIapKey] boolValue];
}

- (CGFloat)iapAmount
{
    return [self.privateData[SPUserIapAmountKey] floatValue];
}

- (NSInteger)numberOfSessions
{
    return [self.privateData[SPUserNumberOfSessionsKey] integerValue];
}

- (NSTimeInterval)psTime
{
    return [self.privateData[SPUserPsTimeKey] doubleValue];
}

- (NSTimeInterval)lastSession
{
    return [self.privateData[SPUserLastSessionKey] doubleValue];
}

- (SPUserConnectionType)connectionType
{
    NSInteger i = [self indexOfValue:self.privateData[SPUserConnectionTypeKey] key:SPUserMappingConnectionType];
    return (SPUserConnectionType) i;
}

- (SPUserDevice)device
{
    NSInteger i = [self indexOfValue:self.privateData[SPUserDeviceKey] key:SPUserMappingDevice];
    return (SPUserDevice) i;
}

- (NSString *)version
{
    return self.privateData[SPUserVersionKey];
}

- (NSDictionary *)customParameters
{
    NSMutableDictionary *customParams = [NSMutableDictionary dictionary];
    NSMutableSet *keys                = [NSMutableSet setWithArray:[self.privateData allKeys]];
    [keys minusSet:self.registeredKeys];

    [keys enumerateObjectsUsingBlock:^(NSString *key, BOOL *stop) {
        NSString *value = self.privateData[key];
        customParams[key] = value;
    }];

    return [customParams copy];
}


#pragma mark - 

- (NSDictionary *)data
{
    return [self.privateData copy];
}

- (void)dataWithCurrentLocation:(void(^)(NSDictionary *data))completionBlock {

    self.locationCompletionBlock = completionBlock;

    if ([CLLocationManager locationServicesEnabledAndAuthorized]) {
        // Obtain the location if enabled and authorized (by the developer's app). We do not want to trigger the
        // UIAlertView asking for location access!
        // Ask for current location
        [self.locationManager startUpdatingLocation];
    } else {
        SPLogInfo(@"Location not updated. Service disabled");
        // Just call the default block
        if (self.locationCompletionBlock) {
            self.locationCompletionBlock([self data]);
        }
    }
}

- (void)reset
{
    [self.privateData removeAllObjects];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    SPLogDebug(@"Did update location %@", [locations firstObject]);
    if (!self.manualLocation) {
        CLLocation *currentLocation = [locations firstObject];
        [self setLocation:currentLocation];
    }
    
    [self.locationManager stopUpdatingLocation];

    if (self.locationCompletionBlock) {
        self.locationCompletionBlock([self data]);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if ([error code] == kCLErrorDenied) {
        SPLogError(@"Error while getting core location: %@",[error localizedFailureReason]);
    }
    [manager stopUpdatingLocation];

    if (self.locationCompletionBlock) {
        self.locationCompletionBlock([self data]);
    }
}

#pragma mark -  Private

- (NSDateFormatter *) dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:SPUserDateFormat];
    }
    return _dateFormatter;
}

-  (NSSet *)registeredKeys
{
    static NSSet *__knownKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSArray *keys   = @[SPUserAgeKey,
                            SPUserAgeKey,
                            SPUserBirthdateKey,
                            SPUserGenderKey,
                            SPUserSexualOrientationKey,
                            SPUserEthnicityKey,
                            SPUserLocationLongitude,
                            SPUserLocationLatitude,
                            SPUserMaritalStatusKey,
                            SPUserAnnualHouseholdIncomeKey,
                            SPUserEducationKey,
                            SPUserZipCodeKey,
                            SPUserInterestsKey,
                            SPUserIapKey,
                            SPUserIapAmountKey,
                            SPUserNumberOfSessionsKey,
                            SPUserPsTimeKey,
                            SPUserLastSessionKey,
                            SPUserConnectionTypeKey,
                            SPUserDeviceKey,
                            SPUserVersionKey];

        __knownKeys = [[NSSet alloc] initWithArray:keys];

    });
    return __knownKeys;
}

/**
 Request index of value represented by NSString from provided array of constant strings
 
 @discussion This method converts value to appropriate index represented in enum. Because it needs to know mapping object the array of constant strings are required as argument.
 
 @param value Value for which index is requested
 @param keys An array of keys, represented by array of NSStrings
 
 @return index as NSInteger
 */

-  (NSInteger)indexOfValue:(NSString *)value key:(NSString * const *)keys
{
    NSInteger i = 0;
    while (keys[i]) {
        if ([keys[i] isEqualToString:value]) {
            return i;
        }
        i++;
    }
    return - 1;
}


#pragma mark -  Accessors

- (NSMutableDictionary *)privateData
{
    if (!_privateData) {
        _privateData = [NSMutableDictionary dictionary];
    }
    return _privateData;
}

-(CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    return _locationManager;
}

@end
