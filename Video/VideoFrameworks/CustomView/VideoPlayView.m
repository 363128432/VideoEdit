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
        _container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, [UIScreen mainScreen].bounds.size.width * frame.size.width / [UIScreen mainScreen].bounds.size.height)];
        _container.backgroundColor = [UIColor blackColor];
        [self addSubview:_container];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playClick)];
        [_container addGestureRecognizer:tap];
        
        [self addSubview:self.statusView];
        frame.size.height = self.statusView.bounds.size.height + _container.bounds.size.height;
        self.frame = frame;
        
        // 添加播放层
        [_container.layer addSublayer:self.playerLayer];
    }
    return self;
}

- (void)startPlayer {
    [self.player play];
}

- (void)toPlay {
    [self.player seekToTime:CMTimeMake(0, 600) completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

- (void)pausePlayer {
    [self.player pause];
}

- (void)playClick {
    if(self.player.rate==0){ //说明时暂停
//        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
//        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    }
}

- (void)setNowTime:(CMTime)nowTime {
    [self.player seekToTime:nowTime completionHandler:^(BOOL finished) {
    }];
    
    self.timeSlider.value = CMTimeGetSeconds(nowTime);
}

- (void)VauleChangeFinishTimeBarSlider:(TimeBarSlider *)timeBar {
    [self.player seekToTime:CMTimeMakeWithSeconds(timeBar.value, self.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

- (void)setPlayUrl:(NSURL *)playUrl {
    _playUrl = playUrl;
    self.player = [AVPlayer playerWithURL:playUrl];
    self.player.volume = 1.0f;
    __weak typeof(self) weakself = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSUInteger current=CMTimeGetSeconds(time);
        weakself.playTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",current / 60, current % 60];
        weakself.timeSlider.value = current;
    }];
    self.playerLayer.player = self.player;
}

- (void)setSeparatePoints:(NSArray<NSNumber *> *)separatePoints {
    _separatePoints = separatePoints;
    self.timeSlider.separatePoint = separatePoints;
}

- (void)setTotalTime:(CMTime)totalTime {
    _totalTime = totalTime;
    
    NSUInteger time = CMTimeGetSeconds(totalTime);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",time / 60, time % 60];
    self.timeSlider.maxVaule = time;
}

- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [[UIView alloc]initWithFrame:CGRectMake(0, _container.bounds.size.height, self.frame.size.width, 50)];
        _statusView.backgroundColor = [UIColor whiteColor];
        
        _timeSlider = [[TimeBarSlider alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        _timeSlider.delegate = self;
        [_statusView addSubview:_timeSlider];
        
        _playTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, 100, 20)];
        _playTimeLabel.font = [UIFont systemFontOfSize:13];
        _playTimeLabel.text = @"00:00";
        [_statusView addSubview:_playTimeLabel];
        
        _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 100, 20, 95, 20)];
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
        _totalTimeLabel.text = @"00:00";
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
        //设置播放窗口和当前视图之间的比例显示内容
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //设置播放的默认音量值
        _playerLayer.player.volume = 1.0f;
    }
    return _playerLayer;
}

@end
