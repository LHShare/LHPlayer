//
//  LHOverlayView.h
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHTransport.h"

@interface LHOverlayView : UIView<LHTransport>

//设置当前时间
- (void)setCurrentTime:(NSTimeInterval)time;

@property (nonatomic, weak) id<LHTransportDelegate> delegate;

@end
