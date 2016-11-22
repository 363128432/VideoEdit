//
//  MaterialCutDownViewController.m
//  Video
//
//  Created by 付州  on 16/10/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "MaterialCutDownViewController.h"
#import "VideoPlayView.h"
#import "CustomMacros.h"
#import "SAVideoRangeSlider.h"
#import "SpeedView.h"
#import "GPUImage.h"
#import "AVURLAsset+Custom.h"

@interface MaterialCutDownViewController ()<SAVideoRangeSliderDelegate,GPUImageMovieDelegate,SpeedViewDelegate>

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIView *functionView;
@property (nonatomic, strong) UIView *functionContent;
@property (nonatomic, assign) NSInteger functionType;
@property (nonatomic, strong) UIButton *ensureButton;

// 裁剪相关
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *rightMask;
@property (nonatomic, assign) CGFloat leftVaule;
@property (nonatomic, assign) CGFloat rightVaule;

// 调速相关
@property (nonatomic, strong) SpeedView *speedView;



@end

@implementation MaterialCutDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.functionView];
    [self.view addSubview:self.functionContent];
    [self.view addSubview:self.ensureButton];
    
    [self updateFunctionContentViewWithType:self.functionType];
    
    [self play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)play {
    [self.playView startPlayer];
}

- (void)updateFunctionContentViewWithType:(NSInteger)type {
    self.functionType = type;
    [self.functionContent.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    switch (self.functionType) {
        case 0: {
            [self.functionContent addSubview:self.mySAVideoRangeSlider];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, self.functionContent.bounds.size.width, 30)];
            label.text = @"拖动两侧滑杆裁剪视频";
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self.functionContent addSubview:label];
        }
            break;
        case 1: {
            [self.functionContent addSubview:self.speedView];
        }
            break;
        case 2: {
            NSArray *array = @[@"亮度",@"饱和度",@"对比度"];
            for (int i = 0; i < 3; i++) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, i * self.functionContent.bounds.size.height / 3, 50, self.functionContent.bounds.size.height / 3)];
                label.text = array[i];
                label.textColor = [UIColor blackColor];
                label.font = [UIFont systemFontOfSize:15];
                [self.functionContent addSubview:label];
                
                UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(60, label.frame.origin.y, SCREEN_WIDTH - 70, label.bounds.size.height)];
                slider.tag = 1230 + i;
                [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
                [self.functionContent addSubview:slider];
                switch (i) {
                    case 0:
                    {
                        slider.value = self.editAsset.brightnessVaule;
                        slider.minimumValue = -1;
                        slider.maximumValue = 1;
                    }
                        break;
                    case 1:
                    {
                        slider.value = self.editAsset.saturationVaule;
                        slider.minimumValue = 0;
                        slider.maximumValue = 2.0;
                    }
                        break;
                    case 2:
                    {
                        slider.value = self.editAsset.contrastVaule;
                        slider.minimumValue = 0;
                        slider.maximumValue = 2;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
        }
            break;
        case 3: {
            UIButton *anticlockwise = [UIButton buttonWithType:UIButtonTypeCustom];
            anticlockwise.frame = CGRectMake(40, 30, 80, 30);
            [anticlockwise setTitle:@"逆时针" forState:UIControlStateNormal];
            [anticlockwise addTarget:self action:@selector(anticlockwiseAction) forControlEvents:UIControlEventTouchUpInside];
            [anticlockwise setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.functionContent addSubview:anticlockwise];
            
            UIButton *clockwise = [UIButton buttonWithType:UIButtonTypeCustom];
            clockwise.frame = CGRectMake(SCREEN_WIDTH - 120, 30, 80, 30);
            [clockwise setTitle:@"顺时针" forState:UIControlStateNormal];
            [clockwise addTarget:self action:@selector(clockwiseAction) forControlEvents:UIControlEventTouchUpInside];
            [clockwise setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.functionContent addSubview:clockwise];
        }
            break;
            
            
        default:
            break;
    }

}

- (void)functionAction:(UIButton *)button {
    if (button.tag - 1220 == self.functionType) {
        return;
    }

    [self updateFunctionContentViewWithType:button.tag - 1220];
}

- (void)makeSureAction {
    switch (self.functionType) {
        case 0: {
            self.editAsset.playTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(_leftVaule, 600), CMTimeMakeWithSeconds(_rightVaule - _leftVaule, 600));
        }
            break;
            
        default:
            break;
    }
    self.editAsset.changeSpeed = self.playView.rate;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderAction:(UISlider *)slider {
    switch (slider.tag - 1230) {
        case 0:
            self.playView.brightnessVaule = slider.value;
            break;
        case 1:
            self.playView.saturationVaule = slider.value;
            break;
        case 2:
            self.playView.contrastVaule = slider.value;
            break;
        default:
            break;
    }
}

- (void)anticlockwiseAction {
    self.playView.angle += M_PI_2;
}

- (void)clockwiseAction {
    self.playView.angle -= M_PI_2;
}



#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    if (leftPosition != _leftVaule) {
        self.playView.nowTime = CMTimeMakeWithSeconds(leftPosition, 600);
    }else if (rightPosition != _rightVaule) {
        self.playView.nowTime = CMTimeMakeWithSeconds(rightPosition, 600);
    }
    
    _leftMask.frame = CGRectMake(0, 0, [self correspondingXWithTime:leftPosition], 50);
    _rightMask.frame = CGRectMake([self correspondingXWithTime:rightPosition], 0, self.mySAVideoRangeSlider.bounds.size.width - [self correspondingXWithTime:rightPosition], 50);
    
    _leftVaule = leftPosition;
    _rightVaule = rightPosition;
}

- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.editAsset.duration) * self.mySAVideoRangeSlider.bounds.size.width;
}

#pragma mark SpeedViewDelegate
- (void)speedViewDidChange:(SpeedView *)speedView {
    self.playView.rate =  pow(2, speedView.currentLevel - 4);
}

#pragma mark GPUImageMovieDelegate
- (void)didCompletePlayingMovie {
    
}

#pragma mark property
- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.playUrl = _editAsset.URL;
        _playView.isEditModel = YES;
        _playView.totalTime = _editAsset.duration;
    }
    return _playView;
}

- (UIView *)functionView {
    if (!_functionView) {
        _functionView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_WIDTH_RATIO * 250, SCREEN_WIDTH, 80)];
        
        NSArray *titleArray = @[@"剪裁",@"变速",@"调整",@"旋转"];
        NSArray *imageArray = @[@"home",@"home",@"home",@"home"];
        CGFloat width = SCREEN_WIDTH / titleArray.count;
        for (int i = 0; i < titleArray.count; i++) {
            UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(i * width, 0, width, _functionView.bounds.size.height)];
            [_functionView addSubview:backview];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((width - 40) / 2, 10, 40, 40)];
            [imageView setImage:[UIImage imageNamed:imageArray[i]]];
            imageView.userInteractionEnabled = YES;
            [backview addSubview:imageView];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, width, 30)];
            label.text = titleArray[i];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [backview addSubview:label];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = backview.bounds;
            button.tag = 1220 + i;
            [button addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
            [backview addSubview:button];
        }
    }
    return _functionView;
}

- (UIView *)functionContent {
    if (!_functionContent) {
        _functionContent = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_WIDTH_RATIO * 250 + 90, SCREEN_WIDTH, 80)];
    }
    return _functionContent ;
}

- (SAVideoRangeSlider *)mySAVideoRangeSlider {
    if (!_mySAVideoRangeSlider) {
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 50) videoUrl:self.editAsset.URL];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        NSTimeInterval endTime = CMTimeGetSeconds(self.editAsset.playTimeRange.start) + CMTimeGetSeconds(self.editAsset.playTimeRange.duration);
        [_mySAVideoRangeSlider setLeftVaule:CMTimeGetSeconds(self.editAsset.playTimeRange.start) rightVaule:endTime];
        _mySAVideoRangeSlider.delegate = self;
        
        
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
        _rightVaule = endTime;
        _rightMask.frame = CGRectMake([self correspondingXWithTime:endTime], 0, self.mySAVideoRangeSlider.bounds.size.width - [self correspondingXWithTime:endTime], 50);
        
    }
    return _mySAVideoRangeSlider;
}

- (SpeedView *)speedView {
    if (!_speedView) {
        NSArray *titleArray = @[@"1/16X", @"1/8X", @"1/4X", @"1/2X", @"1X" ,@"2X",@"4X"];

        _speedView = [[SpeedView alloc] initWithFrame:CGRectMake(10, 20, self.functionContent.bounds.size.width - 20, self.functionContent.bounds.size.height) progressArray:titleArray];
        _speedView.delegate = self;
    }
    return _speedView ;
}


- (UIButton *)ensureButton {
    if (!_ensureButton) {
        _ensureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _ensureButton.frame = CGRectMake(0, self.view.bounds.size.height - 64 - 40, self.view.bounds.size.width, 40);
        [_ensureButton setTitle:@"确定" forState:UIControlStateNormal];
        _ensureButton.backgroundColor = RGB(98, 199, 182);
        [_ensureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_ensureButton addTarget:self action:@selector(makeSureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ensureButton;
}



@end
