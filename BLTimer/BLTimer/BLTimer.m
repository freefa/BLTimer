//
//  BTimer.m
//  BLTimer
//
//  Created by Louis.B on 2020/2/24.
//  Copyright © 2020 Louis.B. All rights reserved.
//

#import "BLTimer.h"

@interface BLTimer()

@property (nonatomic, weak) id target;

@property (nonatomic) SEL selector;

@property (nonatomic) BOOL repeat;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, copy) BLTimerFireBlock block;

@property (nonatomic, strong) dispatch_queue_t timerQueue;

@property (nonatomic, strong) dispatch_source_t timerSource;

@property (nonatomic) BOOL isRunning;

@end

static NSUInteger _bl_timer_queue_num = 0;

@implementation BLTimer

+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   target:(id)target
                                 selector:(SEL)selector
                                   repeat:(BOOL)repeat {
    BLTimer *timer = [[self alloc] initWithDuration:duration
                                             target:target
                                           selector:selector
                                             repeat:repeat
                                              block:NULL];
    [timer fire];
    return timer;
}

+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   repeat:(BOOL)repeat
                                    block:(BLTimerFireBlock)block {
    BLTimer *timer = [[self alloc] initWithDuration:duration
                                             target:nil
                                           selector:NULL
                                             repeat:repeat
                                              block:block];
    [timer fire];
    return timer;
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          target:(id)target
                        selector:(SEL)selector
                          repeat:(BOOL)repeat {
    return [[BLTimer alloc] initWithDuration:duration
                                      target:target
                                    selector:selector
                                      repeat:repeat
                                       block:NULL];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          repeat:(BOOL)repeat
                           block:(BLTimerFireBlock)block {
    return [[BLTimer alloc] initWithDuration:duration
                                      target:nil
                                    selector:NULL
                                      repeat:repeat
                                       block:block];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          target:(id)target
                        selector:(SEL)selector
                          repeat:(BOOL)repeat
                           block:(BLTimerFireBlock)block {
    if (self == [super init]) {
        self.duration = duration;
        self.target = target;
        self.selector = selector;
        self.repeat = repeat;
        self.block = block;
        _bl_timer_queue_num++;
        NSString *label = [NSString stringWithFormat:@"com.bltimer.queue%lu", _bl_timer_queue_num];
        self.timerQueue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL);
        self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_source_set_timer(self.timerSource,
                                  DISPATCH_TIME_NOW,
                                  (uint64_t)(self.duration * NSEC_PER_SEC),
                                  0);
        __weak typeof(self) weakself = self;
        dispatch_source_set_event_handler(self.timerSource, ^{
            [weakself excute];
        });
    }
    return self;
}

- (void)fire {
    if (self.isRunning) {
        return;
    }
    
    if (NO == self.repeat) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(self.duration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self excute];
        });
        return;
    }
    
    dispatch_resume(self.timerSource);
    self.isRunning = YES;
}

- (void)invalidate {
    if (self.isRunning) {
        dispatch_cancel(self.timerSource);
    }
    self.target = nil;
    self.selector = nil;
    self.block = nil;
    self.isRunning = NO;
}

- (void)excute {
    if (self.block != nil) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.block(self);
        });
        return;
    }
    
    if ([self.target respondsToSelector:self.selector]) {
        [self.target performSelectorOnMainThread:self.selector
                                      withObject:self
                                   waitUntilDone:NO];
    }
}

@end
