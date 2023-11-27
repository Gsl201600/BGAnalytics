//
//  BGEventStore.m
//  BGAnalytics
//
//  Created by BG on 2023/9/6.
//

#import "BGEventStore.h"
#import "BGDatabase.h"
#import "BGFileStore.h"
#import "BGEventInfo.h"
#import "BGConvertor.h"

@interface BGEventStore ()

@property (nonatomic, strong) BGDatabase *database;

@end

@implementation BGEventStore

static id instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BGEventStore alloc] init];
    });
    return instance;
}

- (NSArray<BGEventRecord *> *)selectRecords:(nullable NSString *)type {
    return [self.database selectRecords:type];
}

- (BOOL)insertRecord:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters {
    NSNumber *typeNum = [BGConstants toNumber:type];
    NSString *typeStr = [BGConstants toString:type];
    NSDictionary *event = [BGEventInfo reportParametersByType:typeNum name:name parameters:parameters];
    // 日志数据入库
    BGEventRecord *record = [[BGEventRecord alloc] initWithRecordID:nil type:typeStr content:[BGConvertor JSONObjectToString:event]];
    return [self.database insertRecord:record];
}

- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs {
    return [self.database deleteRecords:recordIDs];
}

- (BOOL)deleteAllRecords {
    return [self.database deleteAllRecords];
}

- (BGDatabase *)database {
    if (!_database) {
        _database = [[BGDatabase alloc] initWithFilePath:[BGFileStore filePath:@"database"]];
    }
    return _database;
}

@end
