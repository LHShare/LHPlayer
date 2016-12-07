//
//  NSTimer+LHAdditions.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/7.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "NSTimer+LHAdditions.h"

@implementation NSTimer (LHAdditions)

+ (void)executeTimerBlock:(NSTimer *)timer {
    TimerFireBlock block = [timer userInfo];
    block();
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)interval firing:(TimerFireBlock)fireBlock {
    return [self scheduledTimerWithTimeInterval:interval repeating:NO firing:fireBlock];
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock {
    id block = [fireBlock copy];
    return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeTimerBlock:) userInfo:block repeats:repeat];
}

@end
