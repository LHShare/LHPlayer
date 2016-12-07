//
//  LHPlayerController.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "LHPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "LHPlayerView.h"
#import "UIAlertView+LHAdditions.h"
#import "LHTransport.h"
#import "AVAsset+LHAdditions.h"
#import "LHThumbnail.h"

#define STATUS_KEYPATH @"status"

#define REFRESH_INTERVAL 0.5

static const NSString *PlayerItemStatusContext;

@interface LHPlayerController()<LHTransportDelegate>
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) LHPlayerView *playerView;

@property (nonatomic, assign) id<LHTransport> transport;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id itemEndObserver;

//获取缩略图的工具
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
//视频播放率
@property (nonatomic, assign) float lastPlaybackRate;
@end

@implementation LHPlayerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"hubblecast" ofType:@"m4v"];
    urlStr = [@"file://" stringByAppendingString:urlStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
                      ];
    
    self.asset = [AVAsset assetWithURL:url];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView = [[LHPlayerView alloc]initWithPlayer:self.player];
    self.playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.playerView];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self.player play];
                //播放完成进度监听
                [self addItemEndObserverForPlayerItem];
                //时间监听
                [self addPlayerItemTimeObserver];
                //设置初始时间
                CMTime duration = self.playerItem.duration;
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                //设置标题
                [self.transport setTitle:self.asset.title];
                //获取缩略图
                [self generateThumbnails];
            } else {
                [UIAlertView showAlertWithTitle:@"错误" message:@"加载视频错误"];
            }
        });
    }
}

#pragma mark 获取缩略图
- (void)generateThumbnails
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);
    CMTime duration = self.asset.duration;
    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment = duration.value / 20;
    CMTimeValue currentValue = 2.0 * duration.timescale;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    
    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = [NSMutableArray array];
    
    AVAssetImageGeneratorCompletionHandler handler;
    
    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            id thumbnail = [LHThumbnail thumbnailWithImage:image time:actualTime];
            [images addObject:thumbnail];
        } else {
            NSLog(@"Error : %@",[error localizedDescription]);
        }
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *name = @"THThumbnailsGeneratedNotification";
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:name object:images];
            });
        }
    };
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}


#pragma mark 时间监听
- (void)addPlayerItemTimeObserver
{
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak LHPlayerController *weakSelf = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    };
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
}

#pragma mark 播放完成进度监听
- (void)addItemEndObserverForPlayerItem
{
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __weak LHPlayerController *weakSelf = self;
    void (^callback)(NSNotification *noti) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
    };
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playerItem queue:queue usingBlock:callback];
}

#pragma mark ---overlayview--delegate
- (void)jumpedToTime:(NSTimeInterval)time
{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)scrubbingDidStart
{
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)scrubbingDidEnd
{
    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {
        [self.player play];
    }
    
}

- (void)scrubbedToTime:(NSTimeInterval)time
{
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

@end
