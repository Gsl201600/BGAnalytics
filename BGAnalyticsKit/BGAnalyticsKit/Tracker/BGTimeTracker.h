//
//  BGTimeTracker.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>
#import "BGConstants+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGTimeTracker : NSObject

- (instancetype)initWith:(dispatch_queue_t)queue;
- (void)trackTimer;
- (void)trackFlush;

@end

NS_ASSUME_NONNULL_END
