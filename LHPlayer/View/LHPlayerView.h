//
//  LHPlayerView.h
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHTransport.h"

@class AVPlayer;

@interface LHPlayerView : UIView

- (id) initWithPlayer:(AVPlayer *)player;

@property (nonatomic, readonly) id <LHTransport> transport;

@end
