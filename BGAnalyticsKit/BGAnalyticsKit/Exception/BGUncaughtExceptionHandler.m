//
//  BGUncaughtExceptionHandler.m
//  BGAnalytics
//
//  Created by BG on 2023/9/6.
//

#import "BGUncaughtExceptionHandler.h"
#import "BGEventStore.h"

// 记录之前的崩溃回调函数
static NSUncaughtExceptionHandler *previousUncaughtExceptionHandler = NULL;

@implementation BGUncaughtExceptionHandler

#pragma mark - Register
+ (void)registerHandler {
    // Backup original handler
    previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

#pragma mark - Private
// 崩溃时的回调函数
static void UncaughtExceptionHandler(NSException * exception) {
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"========uncaughtException异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@", name, reason, [stackArray componentsJoinedByString:@"\n"]];
    
    // 保存崩溃日志到沙盒目录
    [BGEventStore.sharedInstance insertRecord:BGAnalyticsTypeCrash name:@"InternalCrash" parameters:@{@"Crash(Uncaught)":exceptionInfo}];
    
    // 调用之前崩溃的回调函数
    if (previousUncaughtExceptionHandler) {
        previousUncaughtExceptionHandler(exception);
    }
    
    // 杀掉程序，这样可以防止同时抛出的SIGABRT被SignalException捕获
    kill(getpid(), SIGKILL);
}

@end
