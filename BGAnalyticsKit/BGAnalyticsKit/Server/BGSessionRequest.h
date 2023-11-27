//
//  BGSessionRequest.h
//  BGAnalytics
//
//  Created by BG on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGSessionRequest : NSObject

+ (NSString *)sessionID;
+ (void)getSessionIDWithCompletion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
