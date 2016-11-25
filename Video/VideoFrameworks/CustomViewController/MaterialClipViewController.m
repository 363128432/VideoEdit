//
//  MaterialClipViewController.m
//  Video
//
//  Created by 付州  on 16/10/13.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "MaterialClipViewController.h"
#import "SAVideoRangeSlider.h"
#import "VideoPlayView.h"
#import "UIView+Custom.h"
#import "CustomMacros.h"

@interface MaterialClipViewController ()<SAVideoRangeSliderDelegate>
{
    UISlider *slider;
}
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIButton *makesure;

@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *rightMask;

@property (nonatomic, assign) CGFloat leftVaule;
@property (nonatomic, assign) CGFloat rightVaule;

@property (nonatomic, strong) UIView *weitiaoView;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation MaterialClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;

    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.mySAVideoRangeSlider];
    [self.view addSubview:self.makesure];
    
    _leftMask = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _leftMask.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.7];
    [self.mySAVideoRangeSlider addSubview:_leftMask];
    _rightMask = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _rightMask.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.7];
    [self.mySAVideoRangeSlider addSubview:_rightMask];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.leftThumb];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.rightThumb];
    
    _leftMask.frame = CGRectMake(0, 0, [self correspondingXWithTime:CMTimeGetSeconds(self.editAsset.playTimeRange.start)], 50);
    _leftVaule = CMTimeGetSeconds(self.editAsset.playTimeRange.start);
    NSTimeInterval endTime = CMTimeGetSeconds(self.editAsset.playTimeRange.start) + CMTimeGetSeconds(self.editAsset.playTimeRange.duration);
    _rightVaule = endTime;
    _rightMask.frame = CGRectMake([self correspondingXWithTime:endTime], 0, self.mySAVideoRangeSlider.width - [self correspondingXWithTime:endTime], 50);
    
    
    if (!_isClip) { // 剪切视图
        self.mySAVideoRangeSlider.allHide = YES;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 260 * SCREEN_WIDTH_RATIO, SCREEN_WIDTH, 20)];
        label.text = @"拖动剪刀来调整分割点";
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 290 * SCREEN_WIDTH_RATIO, SCREEN_WIDTH, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self showTimeWithSeconds:_leftVaule],[self showTimeWithSeconds:CMTimeGetSeconds(self.editAsset.duration)]];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_timeLabel];
        
        
        slider = [[UISlider alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        slider.maximumValue = CMTimeGetSeconds(self.editAsset.duration);
        slider.value = CMTimeGetSeconds(self.editAsset.playTimeRange.start);
        slider.minimumTrackTintColor = [UIColor clearColor];
        slider.maximumTrackTintColor = [UIColor clearColor];
        [slider setThumbImage:[UIImage imageNamed:@"jiandao"] forState:UIControlStateNormal];
        [self.mySAVideoRangeSlider addSubview:slider];
        
        [self.view addSubview:self.weitiaoView];
        self.weitiaoView.center = CGPointMake([self correspondingXWithTime:_leftVaule] + 20, 390* SCREEN_WIDTH_RATIO);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark clip
- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.editAsset.duration) * self.mySAVideoRangeSlider.bounds.size.width;
}


- (NSString *)showTimeWithSeconds:(double)seconds {
    return [NSString stringWithFormat:@"%02d:%02d.%d",(int)seconds/60,(int)seconds%60,(int)(seconds*10.0) % 10];
}

- (void)sliderAction:(UISlider *)sender {
    [self sliderVauleChangeWithSeconds:sender.value];
}

- (void)sliderVauleChangeWithSeconds:(double)seconds {
    slider.value = MAX(seconds, CMTimeGetSeconds(self.editAsset.playTimeRange.start));
    slider.value = MIN(slider.value,  CMTimeGetSeconds(self.editAsset.playTimeRange.start) + CMTimeGetSeconds(self.editAsset.playTimeRange.duration));
    self.playView.nowTime = CMTimeMakeWithSeconds(slider.value, 600);
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self showTimeWithSeconds:slider.value],[self showTimeWithSeconds:CMTimeGetSeconds(self.editAsset.duration)]];
    self.weitiaoView.center = CGPointMake([self correspondingXWithTime:slider.value] + 20, 390 * SCREEN_WIDTH_RATIO);
}

- (void)makeSureAction {
    if (_isClip) {
        self.editAsset.playTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(_leftVaule, 600), CMTimeMakeWithSeconds(_rightVaule - _leftVaule, 600));
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [[VideoObject currentVideo]componentsSeparatedWithIndex:self.assetIndex byTime:slider.value];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)minusAction {
    slider.value -= 0.1;
    [self sliderVauleChangeWithSeconds:slider.value];
}

- (void)addTimeAction {
    slider.value += 0.1;
    [self sliderVauleChangeWithSeconds:slider.value];
}

#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.playView.nowTime = CMTimeMakeWithSeconds(videoRange.isMoveLeft?leftPosition:rightPosition, 600);
    
    _leftMask.frame = CGRectMake(0, 0, [self correspondingXWithTime:leftPosition], 50);
    _rightMask.frame = CGRectMake([self correspondingXWithTime:rightPosition], 0, self.mySAVideoRangeSlider.width - [self correspondingXWithTime:rightPosition], 50);
    
    _leftVaule = leftPosition;
    _rightVaule = rightPosition;
}

#pragma mark - property
- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.playUrl = _editAsset.URL;
        _playView.totalTime = _editAsset.duration;
    }
    return _playView;
}

- (SAVideoRangeSlider *)mySAVideoRangeSlider {
    if (!_mySAVideoRangeSlider) {
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(20, 320 * SCREEN_WIDTH_RATIO, self.view.frame.size.width - 40, 50) videoUrl:self.editAsset.URL];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        NSTimeInterval endTime = CMTimeGetSeconds(self.editAsset.playTimeRange.start) + CMTimeGetSeconds(self.editAsset.playTimeRange.duration);
        [_mySAVideoRangeSlider setLeftVaule:CMTimeGetSeconds(self.editAsset.playTimeRange.start) rightVaule:endTime];
        _mySAVideoRangeSlider.delegate = self;

    }
    return _mySAVideoRangeSlider;
}

- (UIButton *)makesure {
    if (!_makesure) {
        _makesure = [UIButton buttonWithType:UIButtonTypeCustom];
        _makesure.frame = CGRectMake(0, self.view.height - 64 - 40, self.view.width, 40);
        [_makesure setTitle:@"确定" forState:UIControlStateNormal];
        _makesure.backgroundColor = RGB(98, 199, 182);
        [_makesure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_makesure addTarget:self action:@selector(makeSureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _makesure;
}

- (UIView *)weitiaoView {
    if (!_weitiaoView) {
        _weitiaoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
        
        UIButton *minus = [UIButton buttonWithType:UIButtonTypeCustom];
        minus.frame = CGRectMake(0, 0, 20, 20);
        minus.backgroundColor = RGB(98, 199, 182);
        [minus setTitle:@"-" forState:UIControlStateNormal];
        [minus addTarget:self action:@selector(minusAction) forControlEvents:UIControlEventTouchUpInside];
        [_weitiaoView addSubview:minus];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
        add.frame = CGRectMake(30, 0, 20, 20);
        [add setTitle:@"+" forState:UIControlStateNormal];
        [add addTarget:self action:@selector(addTimeAction) forControlEvents:UIControlEventTouchUpInside];
        add.backgroundColor = RGB(98, 199, 182);
        [_weitiaoView addSubview:add];
    }
    return _weitiaoView;
}

@end
