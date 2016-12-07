//
//  LHFilmstripView.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "LHFilmstripView.h"
#import "LHThumbnail.h"
#import "LHOverlayView.h"

@interface LHFilmstripView()

@property (nonatomic, strong) NSArray *thumbnails;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation LHFilmstripView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buildScrubber:) name:@"THThumbnailsGeneratedNotification" object:nil];
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.pagingEnabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)buildScrubber:(NSNotification *)notification
{
    self.thumbnails = [notification object];
    CGFloat currentX = 0.0f;
    CGSize size = [(UIImage *)[[self.thumbnails firstObject]image]size];
    CGSize imageSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(0.5, 0.5));
    CGRect imageRect = CGRectMake(currentX, 0, imageSize.width, imageSize.height);
    CGFloat imageWidth = CGRectGetWidth(imageRect) * self.thumbnails.count;
    self.scrollView.contentSize = CGSizeMake(imageWidth, imageRect.size.height);
    
    for (NSUInteger i = 0; i < self.thumbnails.count; i++) {
        LHThumbnail *timedImage = self.thumbnails[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.adjustsImageWhenHighlighted = NO;
        [button setBackgroundImage:timedImage.image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(currentX, 0, imageSize.width, imageSize.height);
        button.tag = i;
        [self.scrollView addSubview:button];
        currentX += imageSize.width;
    }
}

- (void)imageButtonTapped:(UIButton *)sender
{
    LHThumbnail *image = self.thumbnails[sender.tag];
    if (image) {
        if ([self.superview respondsToSelector:@selector(setCurrentTime:)]) {
            [(LHOverlayView *)self.superview setCurrentTime:CMTimeGetSeconds(image.time)];
        }
    }
}







@end
