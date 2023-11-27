//
//  BGAnalytics.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>
#import <BGAnalyticsKit/BGConstants.h>

@class BGUserInfo, BGConfigOptions;

NS_ASSUME_NONNULL_BEGIN

@interface BGAnalytics : NSObject

@property (nonatomic, copy, readonly, class) NSString *version;
@property (nonatomic, strong, readonly, class) BGConfigOptions *configOptions;
@property (nonatomic, strong, readonly, class) BGUserInfo *userInfo;

#pragma mark - init instance
- (instancetype)init NS_UNAVAILABLE;
/**
 此方法调用建议在应用启动时调用，即在 application:didFinishLaunchingWithOptions: 中调用
 @param configOptions 参数配置
 */
+ (void)startWithConfigOptions:(nonnull BGConfigOptions *)configOptions;

/// 设置用户信息
/// - Parameter userInfo: 标识事件用户
+ (void)setUserInfo:(nonnull BGUserInfo *)userInfo;

#pragma mark - track event
+ (void)track:(BGAnalyticsType)type;
+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name;
+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters;

/**
 * @abstract
 * 强制试图把数据传到对应的服务器上
 * 主动调用 flush 接口，则不论限制条件是否满足，都尝试向服务器上传一次数据
 */
+ (void)flush;

/**
 * @abstract
 * 删除本地缓存的全部事件
 * 一旦调用该接口，将会删除本地缓存的全部事件，请慎用！
 */
+ (void)deleteAll;

@end

NS_ASSUME_NONNULL_END
