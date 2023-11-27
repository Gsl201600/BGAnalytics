//
//  BGDatabase.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGDatabase.h"
#import <sqlite3.h>
#import "BGEventRecord.h"
#import "BGLogger.h"

static NSString *const kDatabaseTableName = @"dataCache";

static const NSUInteger kMaxCacheSize = 500;
static const NSUInteger kRemoveFirstRecordsDefaultCount = 50; // 超过最大缓存条数时默认的删除条数

@interface BGDatabase () {
    sqlite3 *_database;
    CFMutableDictionaryRef _dbStmtCache;
}

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL isCreatedTable;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation BGDatabase

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
        [self createStmtCache];
        [self open];
        [self createTable];
    }
    return self;
}

- (BOOL)open {
    if (self.isOpen) {
        return YES;
    }
    if (_database) {
        [self close];
    }
    if (sqlite3_open_v2([self.filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {
        _database = NULL;
        BGLogError(@"Failed to open SQLite db");
        return NO;
    }
    BGLogInfo(@"Success to open SQLite db");
    self.isOpen = YES;
    return YES;
}

- (void)close {
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;

    if (_database) sqlite3_close(_database);
    _database = NULL;

    _isCreatedTable = NO;
    _isOpen = NO;
    BGLogInfo(@"%@ close database", self);
}

- (BOOL)databaseCheck {
    if (![self open]) {
        return NO;
    }
    if (![self createTable]) {
        return NO;
    }
    return YES;
}

// MARK: Internal APIs for database CRUD
- (BOOL)createTable {
    if (!self.isOpen) {
        return NO;
    }
    if (self.isCreatedTable) {
        return YES;
    }
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, content TEXT)", kDatabaseTableName];
    
    if (sqlite3_exec(_database, sql.UTF8String, NULL, NULL, NULL) != SQLITE_OK) {
        BGLogError(@"Create %@ table fail.", kDatabaseTableName);
        self.isCreatedTable = NO;
        return NO;
    }
    self.isCreatedTable = YES;
    self.count = [self messagesCount];
    BGLogInfo(@"Create %@ table success, current count is %lu", kDatabaseTableName, self.count);
    return YES;
}

- (NSArray<BGEventRecord *> *)selectRecords:(nullable NSString *)type {
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    if (self.count == 0) {
        return [contentArray copy];
    }
    if (![self databaseCheck]) {
        return [contentArray copy];
    }
    NSString *query = @"SELECT id,type,content FROM dataCache ORDER BY id ASC";
    if ([type isKindOfClass:[NSString class]] && type.length > 0) {
        query = [NSString stringWithFormat:@"SELECT id,type,content FROM dataCache WHERE type = '%@' ORDER BY id ASC", type];
    }
    sqlite3_stmt *stmt = [self dbCacheStmt:query];
    if (!stmt) {
        BGLogError(@"Failed to prepare statement, error:%s", sqlite3_errmsg(_database));
        return [contentArray copy];
    }

    NSMutableArray<NSString *> *invalidRecords = [NSMutableArray array];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int index = sqlite3_column_int(stmt, 0);
        char *typeChar = (char *)sqlite3_column_text(stmt, 1);
        char *contentChar = (char *)sqlite3_column_text(stmt, 2);
        if (!typeChar || !contentChar) {
            BGLogError(@"Failed to query column_text, error:%s", sqlite3_errmsg(_database));
            [invalidRecords addObject:[NSString stringWithFormat:@"%d", index]];
            continue;
        }
        NSString *recordID = [NSString stringWithFormat:@"%d", index];
        NSString *type = [NSString stringWithUTF8String:typeChar];
        NSString *content = [NSString stringWithUTF8String:contentChar];
        BGEventRecord *record = [[BGEventRecord alloc] initWithRecordID:recordID type:type content:content];
        [contentArray addObject:record];
    }
    [self deleteRecords:invalidRecords];
    return [contentArray copy];
}

- (BOOL)insertRecords:(NSArray<BGEventRecord *> *)records {
    if (records.count == 0) {
        return NO;
    }
    if (![self databaseCheck]) {
        return NO;
    }
    if (![self preCheckForInsertRecords:records.count]) {
        return NO;
    }
    if (sqlite3_exec(_database, "BEGIN TRANSACTION", 0, 0, 0) != SQLITE_OK) {
        return NO;
    }

    NSString *query = @"INSERT INTO dataCache(type, content) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    if (!insertStatement) {
        return NO;
    }
    BOOL success = YES;
    for (BGEventRecord *record in records) {
        if (![record isValid]) {
            success = NO;
            break;
        }
        sqlite3_bind_text(insertStatement, 1, [record.type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(insertStatement, 2, [record.content UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(insertStatement) != SQLITE_DONE) {
            success = NO;
            break;
        }
        sqlite3_reset(insertStatement);
    }
    BOOL bulkInsertResult = sqlite3_exec(_database, success ? "COMMIT" : "ROLLBACK", 0, 0, 0) == SQLITE_OK;
    self.count = [self messagesCount];
    return bulkInsertResult;
}

- (BOOL)insertRecord:(BGEventRecord *)record {
    if (![record isValid]) {
        BGLogError(@"%@ input parameter is invalid for addObjectToDatabase", self);
        return NO;
    }
    if (![self databaseCheck]) {
        return NO;
    }

    if (![self preCheckForInsertRecords:1]) {
        return NO;
    }

    NSString *query = @"INSERT INTO dataCache(type, content) values(?, ?)";
    sqlite3_stmt *insertStatement = [self dbCacheStmt:query];
    int rc;
    if (insertStatement) {
        sqlite3_bind_text(insertStatement, 1, [record.type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(insertStatement, 2, [record.content UTF8String], -1, SQLITE_TRANSIENT);
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            BGLogError(@"insert into dataCache table of sqlite fail, rc is %d", rc);
            return NO;
        }
        self.count++;
        BGLogInfo(@"insert into dataCache table of sqlite success, current count is %lu", self.count);
        return YES;
    } else {
        BGLogError(@"insert into dataCache table of sqlite error");
        return NO;
    }
}

- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs {
    if ((self.count == 0) || (recordIDs.count == 0)) {
        return NO;
    }
    if (![self databaseCheck]) {
        return NO;
    }
    NSString *query = [NSString stringWithFormat:@"DELETE FROM dataCache WHERE id IN (%@);", [recordIDs componentsJoinedByString:@","]];
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(_database, query.UTF8String, -1, &stmt, NULL) != SQLITE_OK) {
        BGLogError(@"Prepare delete records query failure: %s", sqlite3_errmsg(_database));
        sqlite3_finalize(stmt);
        return NO;
    }
    BOOL success = YES;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        BGLogError(@"Failed to delete record from database, error: %s", sqlite3_errmsg(_database));
        success = NO;
    }
    sqlite3_finalize(stmt);
    self.count = [self messagesCount];
    return success;
}

- (BOOL)deleteFirstRecords:(NSUInteger)recordSize {
    if (self.count == 0 || recordSize == 0) {
        return NO;
    }
    if (![self databaseCheck]) {
        return NO;
    }
    NSUInteger removeSize = MIN(recordSize, self.count);
    NSString *query = [NSString stringWithFormat:@"DELETE FROM dataCache WHERE id IN (SELECT id FROM dataCache ORDER BY id ASC LIMIT %lu);", (unsigned long)removeSize];
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(_database, query.UTF8String, -1, &stmt, NULL) != SQLITE_OK) {
        BGLogError(@"Prepare delete records query failure: %s", sqlite3_errmsg(_database));
        sqlite3_finalize(stmt);
        return NO;
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        BGLogError(@"Failed to delete record from database, error: %s", sqlite3_errmsg(_database));
        sqlite3_finalize(stmt);
        self.count = [self messagesCount];
        return NO;
    }
    sqlite3_finalize(stmt);
    self.count = self.count - removeSize;
    return YES;
}

- (BOOL)deleteAllRecords {
    if (self.count == 0) {
        return NO;
    }
    if (![self databaseCheck]) {
        return NO;
    }
    NSString *sql = @"DELETE FROM dataCache";
    if (sqlite3_exec(_database, sql.UTF8String, NULL, NULL, NULL) != SQLITE_OK) {
        BGLogError(@"Failed to delete all records");
        return NO;
    } else {
        BGLogInfo(@"Delete all records successfully");
    }
    self.count = 0;
    return YES;
}

- (BOOL)preCheckForInsertRecords:(NSUInteger)recordSize {
    if (recordSize > kMaxCacheSize) {
        return NO;
    }
    while ((self.count + recordSize) >= kMaxCacheSize) {
        BGLogWarning(@"AddObjectToDatabase touch MAX_MESSAGE_SIZE:%lu, try to delete some old events", kMaxCacheSize);
        if (![self deleteFirstRecords:kRemoveFirstRecordsDefaultCount]) {
            BGLogError(@"AddObjectToDatabase touch MAX_MESSAGE_SIZE:%lu, try to delete some old events FAILED", kMaxCacheSize);
            return NO;
        }
    }
    return YES;
}

- (void)createStmtCache {
    CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
    CFDictionaryValueCallBacks valueCallbacks = { 0 };
    _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
}

- (sqlite3_stmt *)dbCacheStmt:(NSString *)sql {
    if (sql.length == 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            BGLogError(@"sqlite stmt prepare error (%d): %s", result, sqlite3_errmsg(_database));
            sqlite3_finalize(stmt);
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

//MARK: execute sql statement to get total event records count stored in database
- (NSUInteger)messagesCount {
    NSString *query = @"select count(*) from dataCache";
    int count = 0;
    sqlite3_stmt *statement = [self dbCacheStmt:query];
    if (statement) {
        while (sqlite3_step(statement) == SQLITE_ROW)
            count = sqlite3_column_int(statement, 0);
    } else {
        BGLogError(@"Failed to get count form dataCache");
    }
    return (NSUInteger)count;
}

- (void)dealloc {
    [self close];
}

@end
