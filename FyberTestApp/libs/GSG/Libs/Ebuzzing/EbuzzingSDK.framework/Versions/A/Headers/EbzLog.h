//  EbzLog.h
//  EbuzzingSDK
//
//  Created by Emmanuel Digiaro on 3/12/14.
//  Copyright (c) 2014 Ebuzzing. All rights reserved.
//


#import <Foundation/Foundation.h>

#define PREFIX_LOG_ERROR    @"EBZ_Error"
#define PREFIX_LOG_INFO     @"EBZ_Info"
#define PREFIX_LOG_VERBOSE  @"EBZ_Verbose"

//Log functions
#define EBZLogError(fmt, ...)       [EbzLog logErrorWithFunctionName:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] format:fmt, ##__VA_ARGS__ ];
#define EBZLogInfo(fmt, ...)        [EbzLog logInfoWithFunctionName:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] format:fmt, ##__VA_ARGS__ ];
#define EBZLogVerbose(fmt, ...)     [EbzLog logVerboseWithFunctionName:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] format:fmt, ##__VA_ARGS__ ];

typedef enum {
    EbzDebugLevelInactive   = 0,
    EbzDebugLevelError      = 1,
    EbzDebugLevelInfo       = 2,
    EbzDebugLevelVerbose    = 3,
} EbzDebugLevelType;

@interface EbzLog : NSObject

@property EbzDebugLevelType debugLevel;

+(EbzLog *)sharedInstance;

+(void)logErrorWithFunctionName:(NSString*)functionName format:(NSString *)format, ...;
+(void)logInfoWithFunctionName:(NSString*)functionName format:(NSString *)format, ...;
+(void)logVerboseWithFunctionName:(NSString*)functionName format:(NSString *)format, ...;

+(void) setLevelType:(EbzDebugLevelType)levelType;

@end
