//
//  BGConstants.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BGAnalyticsType) {
    BGAnalyticsTypeLogin = 1001, //登录类
    BGAnalyticsTypePay = 2001, //支付类
    BGAnalyticsTypeProtocol = 3001, //关键协议
    BGAnalyticsTypeRuntime = 4001, //运行时日志
    BGAnalyticsTypeWarning = 5001, //警告类
    BGAnalyticsTypeError = 6001, //错误类
    BGAnalyticsTypeCrash = 7001 //崩溃报告
};

@interface BGConstants : NSObject

@end

NS_ASSUME_NONNULL_END
