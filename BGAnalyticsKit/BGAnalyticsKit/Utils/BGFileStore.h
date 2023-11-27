//
//  BGFileStore.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGFileStore : NSObject

/**
 @abstract
 文件本地存储

 @param fileName 本地存储文件名
 @param value 本地存储文件内容

 @return 存储结果
*/
+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value;

/**
 @abstract
 获取本地存储的文件内容

 @param fileName 本地存储文件名
 @return 本地存储文件内容
*/
+ (nullable id)unarchiveWithFileName:(NSString *)fileName;

/**
 @abstract
 获取文件路径

 @param fileName 文件名
 @return 文件全路径
*/
+ (NSString *)filePath:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
