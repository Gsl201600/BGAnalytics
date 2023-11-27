//
//  BGConfigOptions.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGConfigOptions.h"

NSTimeInterval const kPeriodicTimerMinute = 5.f;
NSInteger const kFlushItem = 10;

@implementation BGConfigOptions

- (NSTimeInterval)periodicTimerMinute {
    if (_periodicTimerMinute <= 0.02) {
        _periodicTimerMinute = kPeriodicTimerMinute;
    }
    return _periodicTimerMinute;
}

- (NSInteger)flushItem {
    if (_flushItem <= 0) {
        _flushItem = kFlushItem;
    }
    return _flushItem;
}

@end
