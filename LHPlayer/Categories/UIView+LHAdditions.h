//
//  UIView+LHAdditions.h
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LHAdditions)

@property (nonatomic, assign) CGFloat frameX;
@property (nonatomic, assign) CGFloat frameY;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGFloat boundsX;
@property (nonatomic, assign) CGFloat boundsY;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@end
