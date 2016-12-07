//
//  NSTimer+LHAdditions.h
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/7.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerFireBlock)(void);

@interface NSTimer (LHAdditions)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock;

@end
