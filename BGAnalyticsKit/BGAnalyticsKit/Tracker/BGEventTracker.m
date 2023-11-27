//
//  BGEventTracker.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGEventTracker.h"
#import "BGAnalyticsKit.h"
#import "BGConfigOptions.h"
#import "BGReportRequest.h"
#import "BGEventInfo.h"
#import "BGEventStore.h"

@implementation BGEventTracker

- (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    if (!name) {
        name = @"";
    }
    if (!parameters) {
        parameters = @{};
    }
    // 日志数据入库
    [BGEventStore.sharedInstance insertRecord:type name:name parameters:parameters];
    
    // 查询日志记录
    NSString *typeStr = [BGConstants toString:type];
    NSArray<BGEventRecord *> *records = [BGEventStore.sharedInstance selectRecords:typeStr];
    
    BOOL isReport = BGAnalytics.configOptions.isRealtime || type == BGAnalyticsTypeLogin || type == BGAnalyticsTypePay || type == BGAnalyticsTypeError || type == BGAnalyticsTypeCrash || records.count >= BGAnalytics.configOptions.flushItem;
    
    if (isReport) {
        NSMutableArray *eventArr = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *recordIDArr = [NSMutableArray arrayWithCapacity:10];
        for (BGEventRecord *record in records) {
            @autoreleasepool {
                [eventArr addObject:record.event];
                [recordIDArr addObject:record.recordID];
            }
        }
        NSMutableDictionary *data = @{typeStr:eventArr.copy}.mutableCopy;
        [data addEntriesFromDictionary:[BGEventInfo reportBaseParameters]];
        [BGReportRequest reportEventData:data.copy completion:^{
            // 上报完成删除数据
            [BGEventStore.sharedInstance deleteRecords:recordIDArr.copy];
        }];
    }
}

@end
