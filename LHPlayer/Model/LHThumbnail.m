//
//  LHThumbnail.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "LHThumbnail.h"

@implementation LHThumbnail

+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time
{
    return [[self alloc]initWithImage:image time:time];
}

- (id)initWithImage:(UIImage *)image time:(CMTime)time
{
    self = [super init];
    if (self) {
        _image = image;
        _time = time;
    }
    return self;
}

@end
