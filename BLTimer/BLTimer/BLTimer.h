//
//  BTimer.h
//  BLTimer
//
//  Created by Louis.B on 2020/2/24.
//  Copyright © 2020 Louis.B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLTimer;

typedef void(^BLTimerFireBlock)(BLTimer *timer);

@interface BLTimer : NSObject

+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   target:(id)target
                                 selector:(SEL)selector
                                   repeat:(BOOL)repeat;

+ (instancetype)scheduleTimerWithDuration:(NSTimeInterval)duration
                                   repeat:(BOOL)repeat
                                    block:(BLTimerFireBlock)block;

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          target:(id)target
                        selector:(SEL)selector
                          repeat:(BOOL)repeat;

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          repeat:(BOOL)repeat
                           block:(BLTimerFireBlock)block;

- (void)fire;

- (void)invalidate;

@end
