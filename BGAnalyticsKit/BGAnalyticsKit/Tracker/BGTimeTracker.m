//
//  BGTrackTimer.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGTimeTracker.h"
#import "BGAnalyticsKit.h"
#import "BGConfigOptions.h"
#import "BGReportRequest.h"
#import "BGEventInfo.h"
#import "BGTimerCycle.h"
#import "BGEventStore.h"
#import "BGLogger.h"

@interface BGTimeTracker ()

@property (nonatomic, strong) BGTimerCycle *timer;
@property (nonatomic, strong) dispatch_queue_t queue_t;

@end

@implementation BGTimeTracker

- (instancetype)initWith:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        self.queue_t = queue;
    }
    return self;
}

- (void)trackTimer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __weak typeof(self) weakSelf = self;
        self.timer = [BGTimerCycle timerWithBlock:^{
            [weakSelf trackFlush];
        } queue:self.queue_t startTime:0 intervalTime:BGAnalytics.configOptions.periodicTimerMinute * 60];
        [self.timer resume];
    });
}

- (void)trackFlush {
    dispatch_async(self.queue_t, ^{
        // 查询日志记录
        NSArray<BGEventRecord *> *records = [BGEventStore.sharedInstance selectRecords:nil];
        BGLogInfo(@"定时任务：开始处理是否有需要上报的数据:%d\n currentThread:%@", records.count, [NSThread currentThread]);
        
        if (records.count > 0) {
            NSMutableArray *loginEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *payEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *protocolEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *runtimeEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *warningEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *errorEventArr = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *crashEventArr = [NSMutableArray arrayWithCapacity:10];
            
            NSMutableArray *recordIDArr = [NSMutableArray arrayWithCapacity:10];
            
            for (BGEventRecord *record in records) {
                @autoreleasepool {
                    [recordIDArr addObject:record.recordID];
                    if ([record.type isEqualToString:@"r_login"]) {
                        [loginEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_pay"]) {
                        [payEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_protocol"]) {
                        [protocolEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_runtime_log"]) {
                        [runtimeEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_warning_log"]) {
                        [warningEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_error_log"]) {
                        [errorEventArr addObject:record.event];
                    } else if ([record.type isEqualToString:@"r_crash"]) {
                        [crashEventArr addObject:record.event];
                    }
                }
            }
            
            NSMutableDictionary *data = [BGEventInfo reportBaseParameters].mutableCopy;
            
            if (loginEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_login":loginEventArr.copy}];
            }
            if (payEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_pay":payEventArr.copy}];
            }
            if (protocolEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_protocol":protocolEventArr.copy}];
            }
            if (runtimeEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_runtime_log":runtimeEventArr.copy}];
            }
            if (warningEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_warning_log":warningEventArr.copy}];
            }
            if (errorEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_error_log":errorEventArr.copy}];
            }
            if (crashEventArr.count > 0) {
                [data addEntriesFromDictionary:@{@"r_crash":crashEventArr.copy}];
            }
            BGLogInfo(@"定时任务：开始上报数据...\n currentThread:%@\n recordID:%@", [NSThread currentThread], recordIDArr.copy);
            [BGReportRequest reportEventData:data.copy completion:^{
                // 上报完成删除数据
                [BGEventStore.sharedInstance deleteRecords:recordIDArr.copy];
            }];
        }
    });
}

- (void)dealloc {
    [self.timer cancel];
}

@end
