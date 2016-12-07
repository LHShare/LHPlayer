//
//  LHOverlayView.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "LHOverlayView.h"
#import "UIView+LHAdditions.h"
#import "LHFilmstripView.h"
#import "NSTimer+LHAdditions.h"


//内容视图高度
#define kContentViewHeight 44
//内容视图动画时间
#define kContentAnimationDuration 0.35
//滚动视图动画时间
#define kScrollViewAnimationDuration 0.5
@interface LHOverlayView()
//顶部内容视图
@property (nonatomic, strong) UIView *topContentView;
//底部内容视图
@property (nonatomic, strong) UIView *bottomContentView;
//内容视图隐藏
@property (nonatomic, assign) BOOL contentViewHidden;
//滚动视图隐藏
@property (nonatomic, assign) BOOL scrollViewHidden;
//滚动视图
//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) LHFilmstripView *filmstripView;
//当前时间
@property (nonatomic, strong) UILabel *currentTimeLabel;
//剩余时间
@property (nonatomic, strong) UILabel *remainTimeLabel;
//搓擦条
@property (nonatomic, strong) UISlider *slider;
//标题
@property (nonatomic, strong) UILabel *titleLabel;
//搓擦条顶部事件展示视图
@property (nonatomic, strong) UIImageView *sliderTopImageView;
@property (nonatomic, strong) UILabel *topTimeLabel;

@property (nonatomic, assign) BOOL scrubbing;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LHOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)]];
        _scrubbing = YES;
        [self resetTimer];
    }
    return self;
}

#pragma mark 展示按钮点击事件
- (void)showButtonClick
{
    [UIView animateWithDuration:kScrollViewAnimationDuration animations:^{
        if (self.scrollViewHidden) {//显示滚动视图隐藏
            self.filmstripView.frameY += (self.filmstripView.frameHeight + self.topContentView.frameHeight);
            self.scrollViewHidden = NO;
        } else {//滚动视图隐藏
            self.filmstripView.frameY -= (self.filmstripView.frameHeight + self.topContentView.frameHeight);
            self.scrollViewHidden = YES;
        }
    }];
}

#pragma mark 跳转到当前时间
- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [self.delegate jumpedToTime:currentTime];
}

#pragma mark 完成按钮点击事件
- (void)doneButtonClick
{
    [self changeContentViewPosition];
}

#pragma mark 视图点击
- (void)click
{
    [self changeContentViewPosition];
}

#pragma mark 暂停按钮点击事件
- (void)pauseBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.delegate) {
        SEL callback = sender.selected ? @selector(pause) : @selector(play);
        [self.delegate performSelector:callback];
    }
}

- (void)showPopuiUI
{
    self.sliderTopImageView.hidden = NO;
    CGRect trackRect = [self.slider convertRect:self.slider.bounds toView:nil];
    CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds trackRect:trackRect value:self.slider.value];
    CGRect rect = self.sliderTopImageView.frame;
    rect.origin.x = (thumbRect.origin.x) + 16 - 40;
    self.sliderTopImageView.frame = rect;
    
    self.currentTimeLabel.text = @"-- : --";
    self.remainTimeLabel.text = @"-- : --";
    [self setScrubbingTime:self.slider.value];
    [self.delegate scrubbedToTime:self.slider.value];
}

- (void)unhidePopupUI
{
    self.sliderTopImageView.hidden = NO;
    self.sliderTopImageView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.sliderTopImageView.alpha = 1.0f;
    }];
    self.scrubbing = YES;
    [self resetTimer];
    [self.delegate scrubbingDidStart];
}

- (void)hidePopupUI
{
    [UIView animateWithDuration:0.3f animations:^{
        self.sliderTopImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.sliderTopImageView.alpha = 1.0f;
        self.sliderTopImageView.hidden = YES;
    }];
    self.scrubbing = NO;
    [self.delegate scrubbingDidEnd];
}

- (void)setScrubbingTime:(NSTimeInterval)time
{
    self.topTimeLabel.text = [self formatSeconds:time];
}

- (void)resetTimer
{
    [self.timer invalidate];
    if (self.scrubbing) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f firing:^{
            if (self.timer.isValid && !self.contentViewHidden) {
                [self changeContentViewPosition];
            }
        }];
    }
}

#pragma mark 操作条操作
- (void)changeContentViewPosition
{
    [self resetTimer];
    [UIView animateWithDuration:kContentAnimationDuration animations:^{
        if (!self.contentViewHidden) {//内容视图展示中
            if (!self.scrollViewHidden) {//滚动视图展示中
                [UIView animateWithDuration:kScrollViewAnimationDuration animations:^{
                    self.filmstripView.frameY -= (self.filmstripView.frameHeight + self.topContentView.frameHeight);
                    self.scrollViewHidden = YES;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:kContentAnimationDuration animations:^{
                        self.topContentView.frameY -= self.topContentView.frameHeight;
                        self.bottomContentView.frameY += self.bottomContentView.frameHeight;
                        self.contentViewHidden = YES;
                    }];
                }];
                
            } else {//隐藏内容视图
                self.topContentView.frameY -= self.topContentView.frameHeight;
                self.bottomContentView.frameY += self.bottomContentView.frameHeight;
                self.contentViewHidden = YES;
            }
        } else {//显示内容视图
            self.topContentView.frameY += self.topContentView.frameHeight;
            self.bottomContentView.frameY -= self.bottomContentView.frameHeight;
            self.contentViewHidden = NO;
        }
    }];
}

#pragma mark 获取时间字符串
- (NSString *)formatSeconds:(NSInteger)value
{
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
}

#pragma mark ----transport--delegate
#pragma mark 设置当前时间
- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration
{
    NSInteger currentSeconds = ceil(time);
    double remainingTime = duration - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainTimeLabel.text = [self formatSeconds:remainingTime];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = duration;
    self.slider.value = time;
}

#pragma 播放完成
- (void)playbackComplete
{
    self.slider.value = 0.0f;
    
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title ? title : @"视频播放";
}

#pragma mark ----buildUI-----
- (void)buildUI
{
    //顶部操作条
    UIView *topContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kContentViewHeight)];
    topContentView.backgroundColor = [UIColor whiteColor];
//    topContentView.alpha = 0.6;
    [self addSubview:topContentView];
    _topContentView = topContentView;
    //完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(20, 0, 50, kContentViewHeight);
    [doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [topContentView addSubview:doneButton];
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, 0, 200, kContentViewHeight)];
    titleLabel.text = @"标题";
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topContentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    //展示按钮
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, 0, 50, kContentViewHeight);
    [showButton setTitle:@"展示" forState:UIControlStateNormal];
    [showButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(showButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [topContentView addSubview:showButton];
    //滚动视图
    LHFilmstripView *filmstripView = [[LHFilmstripView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topContentView.frame), [UIScreen mainScreen].bounds.size.width, 88)];
    filmstripView.layer.shadowOffset = CGSizeMake(0, 2);
    filmstripView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    filmstripView.layer.shadowRadius = 2.0f;
    filmstripView.layer.shadowOpacity = 0.8f;
    [self insertSubview:filmstripView belowSubview:topContentView];
    self.filmstripView = filmstripView;
    
    //底部操作条
    UIView *bottomContentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kContentViewHeight, [UIScreen mainScreen].bounds.size.width, kContentViewHeight)];
    bottomContentView.backgroundColor = [UIColor whiteColor];
//    bottomContentView.alpha = 0.6;
    [self addSubview:bottomContentView];
    _bottomContentView = bottomContentView;
    //开始停止按钮
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseButton setBackgroundImage:[UIImage imageNamed:@"pause_button"] forState:UIControlStateNormal];
    [pauseButton setBackgroundImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateSelected];
    pauseButton.selected = NO;
    pauseButton.frame = CGRectMake(50, 10, 24, 24);
    [pauseButton addTarget:self action:@selector(pauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomContentView addSubview:pauseButton];
    //进度条
    UISlider *slider = [[UISlider alloc]init];
    slider.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, 10, 200, 24);
    [slider addTarget:self action:@selector(showPopuiUI) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown];
    [bottomContentView addSubview:slider];
    self.slider = slider;
    //播放时间
    UILabel *currentTimeLabel = [[UILabel alloc]init];
    currentTimeLabel.text = @"00:06";
    currentTimeLabel.textColor = [UIColor blackColor];
    currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    currentTimeLabel.frame = CGRectMake(CGRectGetMinX(slider.frame) - 70, 10, 60, 24);
    [bottomContentView addSubview:currentTimeLabel];
    self.currentTimeLabel = currentTimeLabel;
    //剩余时间
    UILabel *remainTimeLabel = [[UILabel alloc]init];
    remainTimeLabel.text = @"00:00";
    remainTimeLabel.textColor = [UIColor blackColor];
    remainTimeLabel.textAlignment = NSTextAlignmentCenter;
    remainTimeLabel.frame = CGRectMake(CGRectGetMaxX(slider.frame) + 10, 10, 60, 24);
    [bottomContentView addSubview:remainTimeLabel];
    _remainTimeLabel = remainTimeLabel;
    
    //搓擦条顶部视图
    UIImageView *sliderTopImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tp_info_popup"]];
    sliderTopImageView.frame = CGRectMake(CGRectGetMinX(slider.frame) - 40 + 16, CGRectGetMinY(bottomContentView.frame) - 33, 80, 33);
    sliderTopImageView.hidden = YES;
    [self addSubview:sliderTopImageView];
    self.sliderTopImageView = sliderTopImageView;
    UILabel *topTimeLabel = [[UILabel alloc]init];
    topTimeLabel.text = @"00:00";
    topTimeLabel.textColor = [UIColor blackColor];
    topTimeLabel.frame = CGRectMake(0, 0, 80, 29);
    topTimeLabel.textAlignment = NSTextAlignmentCenter;
    [sliderTopImageView addSubview:topTimeLabel];
    self.topTimeLabel = topTimeLabel;
}

@end
