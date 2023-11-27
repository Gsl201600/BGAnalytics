//
//  BGTimerCycle.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGTimerCycle.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

#pragma mark - private
@interface BGTimerCycle()

@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, assign) BOOL suspended;

@end

@implementation BGTimerCycle

+ (BGTimerCycle *)timerWithBlock:(dispatch_block_t)block
                            queue:(dispatch_queue_t)queue
                        startTime:(NSTimeInterval)startTime
                     intervalTime:(NSTimeInterval)intervalTime
{
    return [[BGTimerCycle alloc] initBlock:block queue:queue startTime:startTime intervalTime:intervalTime];
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime
{
    self = [super init];
    if (self == nil) return nil;

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.source,
                              dispatch_walltime(NULL, startTime * NSEC_PER_SEC),
                              intervalTime * NSEC_PER_SEC,
                              kTimerLeeway);

    dispatch_source_set_event_handler(self.source,^{
        block();
    });

    self.suspended = YES;
    
    return self;
}

- (void)resume {
    if (self.source == nil) return;
    if (!self.suspended) {
        return;
    }
    
    dispatch_resume(self.source);
    self.suspended = NO;
}

- (void)suspend {
    if (self.source == nil) return;
    if (self.suspended) {
        return;
    }
    
    dispatch_suspend(self.source);
    self.suspended = YES;
}

- (void)cancel {
    if (self.source != nil) {
        dispatch_cancel(self.source);
    }
    self.source = nil;
}

- (void)dealloc {
    [self cancel];
}

@end
