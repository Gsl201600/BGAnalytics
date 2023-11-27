//
//  BGLogger.m
//  BGSDK
//
//  Created by BG on 2022/12/30.
//

#import "BGLogger.h"

@implementation BGLogger

static BOOL _enableLog;
+ (void)initialize{
    _enableLog = YES;
}

+ (void)setEnableLog:(BOOL)enableLog {
    _enableLog = enableLog;
}

+ (BOOL)enableLog {
    return _enableLog;
}

static id sharedInstance = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)logLevel:(BGLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ...{
    if (_enableLog || (level > 2)) {
        @try {
            //参数链表指针
            va_list args;
            //遍历开始
            va_start(args, format);
            NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
            [self.sharedInstance logMessage:message level:level file:file function:function line:line];
            //结束遍历
            va_end(args);
        } @catch (NSException *exception) {
            NSLog(@"[BGSDK][⚠️WARN]: %@", exception);
        }
    }
}

- (void)logMessage:(NSString *)message level:(BGLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line{
    NSString *logMessage = [NSString stringWithFormat:@"[BGSDK][%@][%s][line:%lu]: %@", [self descriptionForLevel:level], function, (unsigned long)line, message];
    NSLog(@"%@", logMessage);
}

- (NSString *)descriptionForLevel:(BGLogLevel)level{
    NSString *desc = nil;
    switch (level) {
        case BGLogLevelInfo:
            desc = @"INFO";
            break;
        case BGLogLevelWarning:
            desc = @"⚠️WARN";
            break;
        case BGLogLevelError:
            desc = @"❌ERROR";
            break;
        default:
            desc = @"UNKNOW";
            break;
    }
    return desc;
}

@end
