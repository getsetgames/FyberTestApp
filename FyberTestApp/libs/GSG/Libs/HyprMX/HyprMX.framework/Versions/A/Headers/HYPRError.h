    //
//  HYPRError.h
//  HyprMX
//
//  Created on 2/29/12.
//  Copyright (c) 2012 HyprMX Mobile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HyprMX/HYPRErrorType.h>

/// Error Domain String for errors generated by the HyprMX Mobile SDK
extern NSString * const kHYPRErrorDomain;

/** Models an error coming back from the HTTP api, the type property will identify the severity and type of the error, and the errorMessage will be a string formatted for optional display to the user */
@interface HYPRError : NSError

/** Type of error */
@property (nonatomic, readonly) HYPRErrorType errorType;

/** Description of error */
@property (nonatomic, readonly) NSString *errorMessage;

@end


