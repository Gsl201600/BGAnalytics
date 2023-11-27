//
//  BGEventRecord.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGEventRecord : NSObject

@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) NSDictionary *event;

/// 通过 recordID、 type 和 content 进行初始化
/// @param recordID 事件 id
/// @param type 事件 type
/// @param content 事件 json 字符串数据
- (instancetype)initWithRecordID:(nullable NSString *)recordID type:(NSString *)type content:(NSString *)content;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
