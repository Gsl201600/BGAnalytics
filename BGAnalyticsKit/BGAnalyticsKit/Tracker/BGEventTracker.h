//
//  BGEventTracker.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>
#import "BGConstants+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGEventTracker : NSObject

- (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
