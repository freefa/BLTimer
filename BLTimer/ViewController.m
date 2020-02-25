//
//  ViewController.m
//  BLTimer
//
//  Created by Louis.B on 2020/2/24.
//  Copyright © 2020 Louis.B. All rights reserved.
//

#import "ViewController.h"
#import "BLTimer.h"

@interface ViewController ()

@property (nonatomic, strong) BLTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testTargetSelectorTimer];
    [self testBlockTimer];
}


#pragma mark - target-selector timer
- (void)testTargetSelectorTimer {
    // class method
//    self.timer = [BLTimer scheduleTimerWithDuration:1.0 target:self selector:@selector(handleTargetTimer:) repeat:YES];
    
    // instance method
    self.timer = [[BLTimer alloc] initWithDuration:1.0 target:self selector:@selector(handleTargetTimer:) repeat:YES];
    [self.timer fire];
}

- (void)handleTargetTimer:(BLTimer *)timer {
    static NSUInteger target_timer_count = 0;
    target_timer_count++;
    NSLog(@"handlerTargetTimer: %lu", target_timer_count);
    if (target_timer_count >= 10) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - block timer
- (void)testBlockTimer {
    __weak typeof(self) weakself = self;
    BLTimerFireBlock block = ^(BLTimer *timer) {
        static NSUInteger block_timer_count = 0;
        block_timer_count++;
        NSLog(@"testBlockTimer: %lu", block_timer_count);
        if (block_timer_count >= 10) {
            [weakself.timer invalidate];
            weakself.timer = nil;
        }
    };
    
    // class method
//    self.timer = [BLTimer scheduleTimerWithDuration:1.0 repeat:YES block:block];
    
    // instans method
    self.timer = [[BLTimer alloc] initWithDuration:1.0 repeat:YES block:block];
    [self.timer fire];
}

@end
