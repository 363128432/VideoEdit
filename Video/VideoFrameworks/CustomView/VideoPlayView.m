//
//  VideoPlayView.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoPlayView.h"
#import "TimeBarSlider.h"
#import "GPUImage.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface VideoPlayView ()<TimeBarSliderDelegate,GPUImageMovieDelegate>

@property (nonatomic, strong) AVPlayerLayer *playerLayer;       // 播放层
@property (nonatomic, strong) UIView *playView;          // 播放器容器
@property (nonatomic, strong) TimeBarSlider *timeSlider;        // 时间滑杆
@property (nonatomic, strong) UILabel *playTimeLabel;           // 播放时间标签
@property (nonatomic, strong) UILabel *totalTimeLabel;          // 总时间标签

@property (nonatomic, strong) UIButton *refreshButton;

// 饱和等滤镜相关
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;   // 亮度滤镜
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;       // 对比度
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;   // 饱和度
@property (nonatomic, assign) CGSize videoSize;


@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<IJKMediaPlayback> ijkPlayer;
@property(nonatomic, strong) NSTimer *timer;


@end

@implementation VideoPlayView

- (instancetype)initWithFrame:(CGRect)frame playUrl:(NSURL *)playUrl userFFMPEG:(BOOL)userFFMPEG{
    _playUrl = playUrl;
    self = [super initWithFrame:frame];
    if (self) {
        _nowTime = kCMTimeZero;
        self.clipsToBounds = YES;
        
        // 添加视图
        _playView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, [UIScreen mainScreen].bounds.size.width * frame.size.width / [UIScreen mainScreen].bounds.size.height)];
        _playView.backgroundColor = [UIColor blackColor];
        [self addSubview:_playView];
        
        _contentView = [[UIView alloc]initWithFrame:_playView.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playClick)];
        [_contentView addGestureRecognizer:tap];
        
        [self addSubview:self.statusView];
        frame.size.height = self.statusView.bounds.size.height + _playView.bounds.size.height;
        self.frame = frame;
        
        if (userFFMPEG) {
            [self initFfmpegPlayView];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshMediaControl) userInfo:nil repeats:YES];
        }else {
            // 添加播放层
            [_playView.layer addSublayer:self.playerLayer];
            [self.playView addSubview:self.gpuImageView];
        }
    }
    return self;
}

- (void)initFfmpegPlayView {
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.playUrl withOptions:options];
    self.ijkPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.ijkPlayer.view.frame = self.playView.bounds;
    self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.ijkPlayer.shouldAutoplay = YES;
    [self installMovieNotificationObservers];
    
    self.playView.autoresizesSubviews = YES;
    [self.playView addSubview:self.ijkPlayer.view];
    [self.ijkPlayer prepareToPlay];
}

- (void)startPlayer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_ijkPlayer) {
            [_ijkPlayer play];
        }else {
            [self.player play];
        }
        self.refreshButton.hidden = YES;
    });
    
    if (_gpuImageView) {   // 如果有视频滤镜，启动实时滤镜
        [self.movie startProcessing];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayViewPlayerStart:)]) {
        [_delegate videoPlayViewPlayerStart:self];
    }
}

-(void)playbackFinished:(NSNotification *)notification{
    [self.player seekToTime:self.player.currentItem.duration];
    [self bringSubviewToFront:self.refreshButton];
    self.refreshButton.hidden = NO;

    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayViewPlayerPlayEnd:)]) {
        [_delegate videoPlayViewPlayerPlayEnd:self];
    }
}

- (void)toPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshButton.hidden = YES;
    });

    [self.player seekToTime:CMTimeMakeWithSeconds(0.001, 600) completionHandler:^(BOOL finished) {
        [self startPlayer];
    }];
}

- (void)pausePlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshButton.hidden = YES;
        
        if (_ijkPlayer) {
            [_ijkPlayer pause];
        }else {
            [self.player pause];
        }
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayViewPlayerPause:)]) {
        [_delegate videoPlayViewPlayerPause:self];
    }
}

- (void)playClick {
    if(!self.isPlay){ //说明时暂停
//        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self startPlayer];
    }else {//正在播放
        [self pausePlayer];
//        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    }
}

- (void)setShowRefresh:(BOOL)showRefresh {
    _showRefresh = showRefresh;
    if (_showRefresh) {
        if (!_refreshButton.superview) {
            [self addSubview:self.refreshButton];
        }
    }else {
        [self.refreshButton removeFromSuperview];
    }
}

- (void)refreshAction {
    [self toPlay];
}

- (void)setNowTime:(CMTime)nowTime {
    _nowTime = nowTime;
    if (_ijkPlayer) {
        self.ijkPlayer.currentPlaybackTime = CMTimeGetSeconds(nowTime);
    }else {
        [self.player seekToTime:nowTime];
    }
    
    NSLog(@" one is %f",CMTimeGetSeconds(nowTime));

    [self updateViewWitTime:nowTime];
}

- (void)updateViewWitTime:(CMTime)time {
    double current = CMTimeGetSeconds(time);
    self.playTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)current / 60, (int)current % 60];
    self.timeSlider.value = CMTimeGetSeconds(time);
}

- (void)startPlayerWithTime:(CMTime)time {
//    _nowTime = time;
//    [self.player seekToTime:_nowTime];
    self.nowTime = time;
    [self startPlayer];
}


#pragma mark TimeBarSliderDelegate
- (void)VauleChangeFinishTimeBarSlider:(TimeBarSlider *)timeBar {
   
}

- (void)VauleChangeTimeBarSlider:(TimeBarSlider *)timeBar {
    [self pausePlayer];
    if (self.ijkPlayer) {
        self.ijkPlayer.currentPlaybackTime = timeBar.value;
    }else {
        [self.player seekToTime:CMTimeMakeWithSeconds(timeBar.value, self.player.currentItem.duration.timescale)];
    }
}

#pragma mark set

-(void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self removeNotification];
    [self removeMovieNotificationObservers];
    _delegate = nil;
    [self pausePlayer];
    [_timer invalidate];
}

- (void)setSeparatePoints:(NSArray<NSNumber *> *)separatePoints {
    _separatePoints = separatePoints;
    self.timeSlider.separatePoint = separatePoints;
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self startPlayer];
        _player.rate = rate;
    }];
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    
    self.gpuImageView.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setSaturationVaule:(float)saturationVaule {
    _saturationVaule = saturationVaule;
    _saturationFilter.saturation = saturationVaule;
}

- (void)setBrightnessVaule:(float)brightnessVaule {
    _brightnessVaule = brightnessVaule;
    _brightnessFilter.brightness = brightnessVaule;
}

- (void)setContrastVaule:(float)contrastVaule {
    _contrastVaule = contrastVaule;
    _contrastFilter.contrast = contrastVaule;
}

- (void)setTotalTime:(CMTime)totalTime {
    _totalTime = totalTime;
    
    NSUInteger time = CMTimeGetSeconds(totalTime);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",time / 60, time % 60];
    self.timeSlider.maxVaule = time;
}

- (void)setFilter:(GPUImageOutput<GPUImageInput> *)filter {
    _filter = filter;
    if (!_gpuImageView) {
        [self.playView addSubview:self.gpuImageView];
    }
    [self.movie removeAllTargets];
    [self.movie addTarget:filter];
    [filter addTarget:self.gpuImageView];
    
    NSLog(@"videoPlay is %@",_movie);

}

- (void)cancelMovieProcessing {
    [self.movie cancelProcessing];
}

// 保存当前滤镜视频到某文件
- (void)saveFilterVideoPath:(NSURL *)pathUrl completion: (void (^ __nullable)(void))completion {
    if (!_filter) {
        completion();
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pausePlayer];
//        [self.gpuImageView removeFromSuperview];
        // gpuimage的bug，不能同时存在两个movie，不然无法写入。只有等播放的movie播放完毕才能写入。所以这里直接设置播放完毕
        [self.player seekToTime:self.player.currentItem.duration completionHandler:^(BOOL finished) {
            _movie = [[GPUImageMovie alloc] initWithURL:_playUrl];
            _movie.runBenchmark = YES;
            _movie.shouldRepeat = NO;
            _movie.playAtActualSpeed = NO;
            [_movie addTarget:_filter];
            
            _videoSize = self.player.currentItem.asset.naturalSize;
            _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:pathUrl size:_videoSize fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
            _movieWriter.encodingLiveVideo = YES;
            _movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
            [_filter addTarget:_movieWriter];
            _movieWriter.shouldPassthroughAudio = YES;
            _movie.audioEncodingTarget = _movieWriter;
            [_movie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
            
            [_movieWriter startRecording];
            [_movie startProcessing];
            
            __weak typeof(self) weakself = self;
            [_movieWriter setCompletionBlock:^{
                [weakself.filter removeTarget:weakself.movieWriter];
                [weakself.movieWriter finishRecording];
                [weakself.movie cancelProcessing];
                NSLog(@"finish");
                completion();
            }];
        }];
    });
}


#pragma mark get
- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [[UIView alloc]initWithFrame:CGRectMake(0, _playView.bounds.size.height, self.frame.size.width, 50)];
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
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        //设置播放页面的大小
        _playerLayer.frame = CGRectMake(0, 0, _playView.bounds.size.width, _playView.bounds.size.height);
        //设置播放窗口和当前视图之间的比例显示内容
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //设置播放的默认音量值
        _playerLayer.player.volume = 1.0f;
    }
    return _playerLayer;
}

- (AVPlayer *)player {
    if (!_player) {
//        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_playUrl];
        _player = [AVPlayer playerWithURL:_playUrl];
        _player.volume = 1.0f;
        __weak typeof(self) weakself = self;
        [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (weakself.isPlay) {
                _nowTime = time;
                [weakself updateViewWitTime:time];
                if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(videoPlayViewPlayerIsPlay:)]) {
                    [weakself.delegate videoPlayViewPlayerIsPlay:weakself];
                }
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    return _player;
}



- (GPUImageMovie *)movie {
    if (!_movie) {
        _movie = [[GPUImageMovie alloc]initWithPlayerItem:self.player.currentItem];
        _movie.playAtActualSpeed = YES;
        _movie.runBenchmark = NO;
        _movie.delegate = self;
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        _contrastFilter = [[GPUImageContrastFilter alloc]init];
        _saturationFilter = [[GPUImageSaturationFilter alloc]init];
        [_movie addTarget:_brightnessFilter];
        [_brightnessFilter addTarget:_contrastFilter];
        [_contrastFilter addTarget:_saturationFilter];
        [_saturationFilter addTarget:self.gpuImageView];
    }
    return _movie;
}

- (GPUImageView *)gpuImageView {
    if (!_gpuImageView) {
        _gpuImageView = [[GPUImageView alloc]initWithFrame:self.playView.bounds];
    }
    return _gpuImageView;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.frame = CGRectMake(0, 0, 40, 40);
        _refreshButton.center = self.playView.center;
        _refreshButton.hidden = YES;
        [_refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (BOOL)isPlay {
    if (_ijkPlayer) {
        return [_ijkPlayer isPlaying];
    }else {
        return self.player.rate;
    }
}





#pragma mark ijkPlayer
- (void)replaceCurrentPlayUrl:(NSURL *)playUrl {
    _playUrl = playUrl;
    //
//        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:playUrl]];
//        [self.player replaceCurrentItemWithPlayerItem:item];
    
    if (self.ijkPlayer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.ijkPlayer shutdown];
            [self removeMovieNotificationObservers];
            [self.playView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
//            [self.ijkPlayer.view removeFromSuperview];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 如果不睡眠，会无法创建成功
        sleep(0.2);
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.playUrl withOptions:options];
        self.ijkPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.ijkPlayer.view.frame = self.playView.bounds;
        self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.ijkPlayer.shouldAutoplay = YES;
        [self installMovieNotificationObservers];
        
        self.playView.autoresizesSubviews = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playView addSubview:self.ijkPlayer.view];
        });
        [self.ijkPlayer prepareToPlay];
    });

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
//        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
//        self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.playUrl withOptions:options];
//        self.ijkPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        self.ijkPlayer.view.frame = self.playView.bounds;
//        self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
//        self.ijkPlayer.shouldAutoplay = YES;
//        [self installMovieNotificationObservers];
//        
//        self.playView.autoresizesSubviews = YES;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.playView addSubview:self.ijkPlayer.view];
//        });
//        [self.ijkPlayer prepareToPlay];
//    });

}

- (void)refreshMediaControl {
    _nowTime = (self.ijkPlayer.currentPlaybackTime == 0) ? _nowTime : CMTimeMakeWithSeconds(self.ijkPlayer.currentPlaybackTime, 600);
    
    [self updateViewWitTime:_nowTime];
    if (self.isPlay) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayViewPlayerIsPlay:)]) {
            [self.delegate videoPlayViewPlayerIsPlay:self];
        }
    }
}


#pragma mark NSNotificationMothed
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = self.ijkPlayer.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayViewPlayerPlayEnd:)]) {
        [_delegate videoPlayViewPlayerPlayEnd:self];
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    // 不设置会PreparedToPlay后直接播放
//    [self pausePlayer];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (self.ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)self.ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)self.ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)self.ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)self.ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.ijkPlayer.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)self.ijkPlayer.playbackState);
            break;
        }
    }
}


#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.ijkPlayer];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}



@end
