//
//  BGAnalytics.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGAnalytics.h"
#import "BGConfigOptions.h"
#import "BGUserInfo.h"
#import "BGRouter.h"
#import "BGLogger.h"
#import "BGSessionRequest.h"
#import "BGTimeTracker.h"
#import "BGEventTracker.h"
#import "BGEventStore.h"
#import "BGSignalExceptionHandler.h"
#import "BGUncaughtExceptionHandler.h"

static const char * kSerialQueueLabel = "com.bg.serialQueue";

@interface BGAnalytics ()

@property (nonatomic, strong) BGConfigOptions *configOptions;
@property (nonatomic, strong) BGUserInfo *userInfo;
@property (nonatomic, strong) BGTimeTracker *timeTracker;
@property (nonatomic, strong) BGEventTracker *eventTracker;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation BGAnalytics

+ (NSString *)version {
    return kSDKVersion;
}

+ (BGConfigOptions *)configOptions {
    return [BGAnalytics sharedInstance].configOptions;
}

+ (BGUserInfo *)userInfo {
    return [BGAnalytics sharedInstance].userInfo;
}

static id instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BGAnalytics alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serialQueue = dispatch_queue_create(kSerialQueueLabel, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)startWithConfigOptions:(nonnull BGConfigOptions *)configOptions {
    [[BGAnalytics sharedInstance] startWithConfigOptions:configOptions];
}

+ (void)setUserInfo:(nonnull BGUserInfo *)userInfo {
    [[BGAnalytics sharedInstance] setUserInfo:userInfo];
}

#pragma mark - track event
+ (void)track:(BGAnalyticsType)type {
    [[self sharedInstance] track:type];
}

+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name {
    [[self sharedInstance] track:type name:name];
}

+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    [[self sharedInstance] track:type name:name parameters:parameters];
}

+ (void)flush {
    [[self sharedInstance] flush];
}

+ (void)deleteAll {
    [[self sharedInstance] deleteAll];
}

#pragma mark - instance method
- (void)startWithConfigOptions:(nonnull BGConfigOptions *)configOptions {
    dispatch_async(self.serialQueue, ^{
        BGLogInfo(@"appID:%@,\n channelId:%@,\n disableSDK:%d,\n domain:%@,\n disableLog:%d,\n isRealtime:%d,\n periodicTimerMinute:%f,\n flushItem:%d,\n currentThread:%@", configOptions.app_id, configOptions.channel_id, configOptions.disableSDK, configOptions.domain, configOptions.disableLog, configOptions.isRealtime, configOptions.periodicTimerMinute, configOptions.flushItem, [NSThread currentThread]);
        
        if (configOptions.disableSDK) {
            return;
        }
        self.configOptions = configOptions;
        [BGRouter sharedInstance].baseUrl = configOptions.domain;
        BGLogger.enableLog = !configOptions.disableLog;
        
        [BGSignalExceptionHandler registerHandler];
        [BGUncaughtExceptionHandler registerHandler];
        
        [BGSessionRequest getSessionIDWithCompletion:^{
            BGLogInfo(@"定时任务开启\n currentThread:%@", [NSThread currentThread]);
            [self.timeTracker trackTimer];
        }];
    });
}

- (void)setUserInfo:(nonnull BGUserInfo *)userInfo {
    BGLogInfo(@"UID:%@,\n plat_id:%@,\n role_id:%@\n currentThread:%@", userInfo.uid, userInfo.plat_id, userInfo.role_id, [NSThread currentThread]);
    _userInfo = userInfo;
}

#pragma mark - track event
- (void)track:(BGAnalyticsType)type {
    [self track:type name:nil];
}

- (void)track:(BGAnalyticsType)type name:(nullable NSString *)name {
    [self track:type name:name parameters:nil];
}

- (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    dispatch_async(self.serialQueue, ^{
        if (self.configOptions.disableSDK) {
            return;
        }
        BGLogInfo(@"type:%d,\n name:%@,\n parameters:%@\n currentThread:%@", type, name, parameters, [NSThread currentThread]);
        [self.eventTracker track:type name:name parameters:parameters];
    });
}

- (void)flush {
    if (self.configOptions.disableSDK) {
        return;
    }
    BGLogInfo(@"试图把数据传到对应的服务器上\n currentThread:%@", [NSThread currentThread]);
    [self.timeTracker trackFlush];
}

- (void)deleteAll {
    dispatch_async(self.serialQueue, ^{
        BGLogWarning(@"删除本地缓存的全部事件!\n currentThread:%@", [NSThread currentThread]);
        [BGEventStore.sharedInstance deleteAllRecords];
    });
}

- (BGTimeTracker *)timeTracker {
    if (!_timeTracker) {
        _timeTracker = [[BGTimeTracker alloc] initWith:self.serialQueue];
    }
    return _timeTracker;
}

- (BGEventTracker *)eventTracker {
    if (!_eventTracker) {
        _eventTracker = [[BGEventTracker alloc] init];
    }
    return _eventTracker;
}

@end
