//
//  ViewController.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/5.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

static const NSString *PlayerItemStatusContext;

@interface ViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hubblecast" ofType:@"m4v"];
    path = [@"file://" stringByAppendingString:path];
    NSURL *url = [NSURL URLWithString:path];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:@[@"tracks"]];
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view.layer addSublayer:playerLayer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self.player play];
            }
        });
    }
}

@end
