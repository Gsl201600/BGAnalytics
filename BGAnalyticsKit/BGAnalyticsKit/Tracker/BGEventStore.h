//
//  BGEventStore.h
//  BGAnalytics
//
//  Created by BG on 2023/9/6.
//

#import <Foundation/Foundation.h>
#import "BGConstants+Private.h"
#import "BGEventRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGEventStore : NSObject

+ (instancetype)sharedInstance;

/// fetch records with type
/// @param type record type
- (NSArray<BGEventRecord *> *)selectRecords:(nullable NSString *)type;

- (BOOL)insertRecord:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters;

/// delete records with IDs
/// @param recordIDs event record IDs
- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs;

/// delete all records from database
- (BOOL)deleteAllRecords;

@end

NS_ASSUME_NONNULL_END
