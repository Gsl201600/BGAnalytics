//
//  BGConstants+Private.h
//  BGAnalytics
//
//  Created by BG on 2023/9/1.
//

#import <Foundation/Foundation.h>
#import "BGConstants.h"

FOUNDATION_EXTERN NSString * _Nonnull const kSDKVersion;

NS_ASSUME_NONNULL_BEGIN

@interface BGConstants ()

+ (NSString *)toString:(BGAnalyticsType)type;
+ (NSNumber *)toNumber:(BGAnalyticsType)type;

@end

NS_ASSUME_NONNULL_END
