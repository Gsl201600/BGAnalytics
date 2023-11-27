//
//  BGLogger.h
//  BGSDK
//
//  Created by BG on 2022/12/30.
//

#import <Foundation/Foundation.h>

#define BGLogLevel(level, fmt, ...) \
[BGLogger logLevel:level file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format:(fmt), ##__VA_ARGS__]

#define BGLogInfo(fmt, ...) \
BGLogLevel(BGLogLevelInfo, (fmt), ##__VA_ARGS__)

#define BGLogWarning(fmt, ...) \
BGLogLevel(BGLogLevelWarning, (fmt), ##__VA_ARGS__)

#define BGLogError(fmt, ...) \
BGLogLevel(BGLogLevelError, (fmt), ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BGLogLevel) {
    BGLogLevelInfo = 1,
    BGLogLevelWarning,
    BGLogLevelError
};

@interface BGLogger : NSObject

@property (nonatomic, assign, class) BOOL enableLog;

+ (void)logLevel:(BGLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
