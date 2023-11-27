//
//  BGDatabase.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

@class BGEventRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract
 * 一个基于Sqlite封装的接口，用于向其中添加和获取数据
 */
@interface BGDatabase : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

/// init method
/// @param filePath path for database file
- (instancetype)initWithFilePath:(NSString *)filePath;

/// fetch records with type
/// @param type record type
- (NSArray<BGEventRecord *> *)selectRecords:(nullable NSString *)type;

/// bulk insert event records
/// @param records event records
- (BOOL)insertRecords:(NSArray<BGEventRecord *> *)records;

/// insert single record
/// @param record event record
- (BOOL)insertRecord:(BGEventRecord *)record;

/// delete records with IDs
/// @param recordIDs event record IDs
- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs;

/// delete first records with a certain size
/// @param recordSize record size
- (BOOL)deleteFirstRecords:(NSUInteger)recordSize;

/// delete all records from database
- (BOOL)deleteAllRecords;

@end

NS_ASSUME_NONNULL_END
