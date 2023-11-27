//
//  BGUncaughtExceptionHandler.h
//  BGAnalytics
//
//  Created by BG on 2023/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGUncaughtExceptionHandler : NSObject

+ (void)registerHandler;

@end

NS_ASSUME_NONNULL_END
