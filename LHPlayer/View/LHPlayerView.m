//
//  LHPlayerView.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "LHPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "LHOverlayView.h"

@interface LHPlayerView()
//操作视图
@property (nonatomic, strong) LHOverlayView *overlayView;

@end

@implementation LHPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (id)initWithPlayer:(AVPlayer *)player
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [(AVPlayerLayer *)[self layer] setPlayer:player];
        self.overlayView = [[LHOverlayView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self addSubview:self.overlayView];
    }
    return self;
}

- (id<LHTransport>)transport
{
    return self.overlayView;
}

@end
