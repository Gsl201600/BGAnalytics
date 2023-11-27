//
//  BGEventInfo.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGEventInfo : NSObject

+ (NSDictionary *)reportBaseParameters;

+ (NSDictionary *)reportParametersByType:(NSNumber *)type name:(NSString *)name parameters:(NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
