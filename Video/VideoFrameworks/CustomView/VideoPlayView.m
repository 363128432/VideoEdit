//
//  VideoPlayView.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoPlayView.h"
#import "TimeBarSlider.h"

@interface VideoPlayView ()<TimeBarSliderDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;       // 播放层
@property (nonatomic, strong) TimeBarSlider *timeSlider;        // 时间滑杆
@property (nonatomic, strong) UILabel *playTimeLabel;           // 播放时间标签
@property (nonatomic, strong) UILabel *totalTimeLabel;          // 总时间标签

@end

@implementation VideoPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加视图
        _container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 50)];
        [self addSubview:_container];
        
        [self addSubview:self.statusView];
        
        // 添加播放层
        [_container.layer addSublayer:self.playerLayer];
    }
    return self;
}

- (void)startPlayer {
    [self.player play];
}

- (void)pausePlayer {
    [self.player pause];
}



- (void)VauleChangeTimeBarSlider:(TimeBarSlider *)timeBar {
    CGFloat sumPlayOperation = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
    [self.player seekToTime:CMTimeMakeWithSeconds(timeBar.value * sumPlayOperation, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

- (void)setPlayUrl:(NSURL *)playUrl {
    _playUrl = playUrl;
    self.player = [AVPlayer playerWithURL:playUrl];
    self.player.volume = 1.0f;
    self.playerLayer.player = self.player;
}

- (void)setTotalTime:(CMTime)totalTime {
    _totalTime = totalTime;
    
    NSUInteger time = CMTimeGetSeconds(totalTime);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",time / 60, time % 60];
}

- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        _statusView.backgroundColor = [UIColor whiteColor];
        
        _timeSlider = [[TimeBarSlider alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        _timeSlider.delegate = self;
        [_statusView addSubview:_timeSlider];
        
        _playTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, 100, 20)];
        _playTimeLabel.font = [UIFont systemFontOfSize:13];
        [_statusView addSubview:_playTimeLabel];
        
        _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 100, 20, 95, 20)];
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
        _totalTimeLabel.font = [UIFont systemFontOfSize:13];
        [_statusView addSubview:_totalTimeLabel];
    }
    return _statusView;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer layer];
        //设置播放页面的大小
        _playerLayer.frame = CGRectMake(0, 0, _container.bounds.size.width, _container.bounds.size.height);
        _playerLayer.backgroundColor = [UIColor cyanColor].CGColor;
        //设置播放窗口和当前视图之间的比例显示内容
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //设置播放的默认音量值
        _playerLayer.player.volume = 1.0f;
    }
    return _playerLayer;
}

@end
