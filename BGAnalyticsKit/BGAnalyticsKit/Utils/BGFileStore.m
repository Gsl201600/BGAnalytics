//
//  BGFileStore.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGFileStore.h"

@implementation BGFileStore

#pragma mark - archive file
+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value {
    if (!fileName) {
        NSLog(@"key should not be nil for file store");
        return NO;
    }
    NSString *filePath = [BGFileStore filePath:fileName];
    
    /* 为filePath文件设置保护等级 */
    NSDictionary *protection = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    
    [[NSFileManager defaultManager] setAttributes:protection
                                     ofItemAtPath:filePath
                                            error:nil];
    if (![NSKeyedArchiver archiveRootObject:value toFile:filePath]) {
        NSLog(@"%@ unable to archive %@", self, fileName);
        return NO;
    }
    NSLog(@"%@ archived %@", self, fileName);
    return YES;
}

#pragma mark - unarchive file
+ (id)unarchiveWithFileName:(NSString *)fileName {
    if (!fileName) {
        NSLog(@"key should not be nil for file store");
        return nil;
    }
    NSString *filePath = [BGFileStore filePath:fileName];
    return [BGFileStore unarchiveFromFile:filePath];
}

+ (id)unarchiveFromFile:(NSString *)filePath {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch (NSException *exception) {
        NSLog(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        unarchivedData = nil;
    }
    return unarchivedData;
}

#pragma mark - file path
+ (NSString *)filePath:(NSString *)key {
    NSString *filename = [NSString stringWithFormat:@"yoka.analytics-%@.plist", key];
    
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
    NSLog(@"filepath for %@ is %@", key, filepath);
    return filepath;
}

@end
