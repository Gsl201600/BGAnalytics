//
//  BGReportRequest.h
//  BGAnalytics
//
//  Created by BG on 2023/8/31.
//

#import <Foundation/Foundation.h>
#import "BGConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGReportRequest : NSObject

+ (void)reportEventData:(NSDictionary *)data completion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
