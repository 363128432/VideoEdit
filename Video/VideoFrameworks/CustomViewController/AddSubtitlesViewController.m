//
//  AddSubtitlesViewController.m
//  Video
//
//  Created by 付州  on 16/9/3.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddSubtitlesViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayView.h"
#import "SAVideoRangeSlider.h"
#import "SubtitleElementObject.h"
#import "SubtitlesView.h"
#import "SubtitleElementObject.h"

@interface AddSubtitlesViewController ()<SAVideoRangeSliderDelegate>
{
    SubtitlesView *subtitleView;
}

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;

@property (nonatomic, strong) VideoObject *currentVideo;

@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIView *styleView;
@property (weak, nonatomic) IBOutlet UIView *styleFunctionView;

@property (weak, nonatomic) IBOutlet UIButton *styleButton;

@end

@implementation AddSubtitlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.edgesForExtendedLayout = UIRectEdgeNone;

    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.mySAVideoRangeSlider];
    
    [self.view bringSubviewToFront:self.maskView];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    
    [self currentType:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 当前状态，0，正常。1，正在输入。2，添加文字视图，但没选择样式。3，选择样式
- (void)currentType:(NSInteger)type {
    switch (type) {
        case 0: {
            self.maskView.hidden = YES;
            self.styleView.hidden = YES;
            self.styleButton.hidden = YES;
        }
            break;
        case 1: {
            self.maskView.hidden = NO;
            self.styleView.hidden = YES;
            self.styleButton.hidden = YES;
            [self.textView becomeFirstResponder];
        }
            break;
        case 2: {
            self.maskView.hidden = YES;
            self.styleView.hidden = YES;
            self.styleButton.hidden = NO;
        }
            break;
        case 3: {
            self.maskView.hidden = YES;
            self.styleView.hidden = NO;
            self.styleButton.hidden = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - action
- (IBAction)addSubtitleAction:(id)sender {
    self.maskView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (IBAction)cancelAction:(id)sender {
    self.maskView.hidden = YES;
    [self.textView resignFirstResponder];
}

- (IBAction)styleAction:(id)sender {
    [self.styleFunctionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0: {
            NSArray *array = @[@"无",@"左滚屏",@"上滚屏",@"缩入",@"淡出",@"旋转"];
            for (int i = 0; i < 2; i ++) {
                for (int j = 0; j < 3; j ++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j * self.styleFunctionView.bounds.size.width / 3, i * self.styleFunctionView.bounds.size.height / 2, self.styleFunctionView.bounds.size.width / 3, self.styleFunctionView.bounds.size.height / 2);
                    [button setTitle:array[i * 3 + j] forState:UIControlStateNormal];
                    button.tag = 11000 + i * 3 + j;
                    [button addTarget:self action:@selector(textAddAnimation:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
        }
            break;
            
        case 1: {
            for (int i = 0; i < 3; i ++) {
                for (int j = 0; j < 10; j ++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j * self.styleFunctionView.bounds.size.width / 10, i * self.styleFunctionView.bounds.size.height / 3, self.styleFunctionView.bounds.size.width / 10, self.styleFunctionView.bounds.size.height / 3);
                    button.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1];
//                    button.tag = 11100 + i;
                    [button addTarget:self action:@selector(textAdjustColor:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
        }
            break;
            
        case 2: {
            NSArray * array = @[@"AmericanTypewriter-Bold",@"TimesNewRomanPS-ItalicMT",@"Verdana-Boldltalic",@"CourierNewPS-BoldMT",@"Zapfino",@"Georgia-Bold"];
            for (int i = 0; i < 2; i ++) {
                for (int j = 0; j < 3; j ++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j * self.styleFunctionView.bounds.size.width / 3, i * self.styleFunctionView.bounds.size.height / 2, self.styleFunctionView.bounds.size.width / 3, self.styleFunctionView.bounds.size.height / 2);
                    [button setTitle:@"美摄" forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont fontWithName:array[i * 3 + j] size:15];
                    button.tag = 11200 + i * 3 + j;
                    [button addTarget:self action:@selector(textAdjustFont:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
            
        }
            break;
            
        case 3: {
            UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, self.styleFunctionView.bounds.size.width, 40)];
            [slider addTarget:self action:@selector(textFontSizeChange:) forControlEvents:UIControlEventValueChanged];
            slider.minimumValue = 5;
            slider.maximumValue = 50;
            slider.value = 20;
            [self.styleFunctionView addSubview:slider];
        }
            break;
            
        case 4: {
            NSArray * array = @[@"居左",@"左右居中",@"居右",@"居上",@"上下居中",@"居下"];
            for (int i = 0; i < 2; i ++) {
                for (int j = 0; j < 3; j ++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j * self.styleFunctionView.bounds.size.width / 3, i * self.styleFunctionView.bounds.size.height / 2, self.styleFunctionView.bounds.size.width / 3, self.styleFunctionView.bounds.size.height / 2);
                    [button setTitle:array[i * 3 + j] forState:UIControlStateNormal];
                    button.tag = 11400 + i * 3 + j;
                    [button addTarget:self action:@selector(textAdjustPosition:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)textStyleDetermineAction:(id)sender {
    [self determineAddAction:nil];
}

- (void)textAddAnimation:(UIButton *)button {
    subtitleView.animationType = button.tag - 11000;
}

- (void)textFontSizeChange:(UISlider *)slider {
    subtitleView.fontSize = slider.value;
}

- (void)textAdjustColor:(UIButton *)button {
    subtitleView.textColor = button.backgroundColor ;
}

- (void)textAdjustFont:(UIButton *)button {
    subtitleView.titleFont = [button.titleLabel.font fontWithSize:subtitleView.fontSize];
}

- (void)textAdjustPosition:(UIButton *)button {
    CGRect rect = subtitleView.frame;
    CGSize superViewSize = subtitleView.superview.frame.size;
    switch (button.tag - 11400) {
        case 0: {
            rect.origin.x = 0;
        }
            break;
        case 1: {
            rect.origin.x = (superViewSize.width - rect.size.width) / 2;
        }
            break;
        case 2: {
            rect.origin.x = superViewSize.width - rect.size.width;
        }
            break;
        case 3: {
            rect.origin.y = 0;
        }
            break;
        case 4: {
            rect.origin.y = (superViewSize.height - rect.size.height) / 2;
        }
            break;
        case 5: {
            rect.origin.y = superViewSize.height - rect.size.height;
        }
            break;
        default:
            break;
    }
    subtitleView.frame = rect;

}

- (IBAction)showStyleViewAction:(id)sender {
    [self styleAction:nil];

    [self currentType:3];
}

- (IBAction)determineAction:(id)sender {
    [self currentType:2];
    
    subtitleView = [[SubtitlesView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) title:self.textView.text];
    subtitleView.center = self.playView.container.center;
    [self.playView.container addSubview:subtitleView];
    
    [self cancelAction:nil];
}

- (IBAction)determineAddAction:(id)sender {
//    [self currentType:0];
    self.styleButton.hidden = YES;
    
    SubtitleElementObject *subtitle = [[SubtitleElementObject alloc]init];
    subtitle.font = subtitleView.titleFont;
    CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    CGRect textRect = [subtitleView convertRect:subtitleView.textLabel.frame toView:self.playView.container];

    subtitle.rect = CGRectMake(textRect.origin.x * ratio, (self.playView.container.bounds.size.height - textRect.origin.y) * ratio - textRect.size.height * ratio, textRect.size.width * ratio, textRect.size.height * ratio);
    subtitle.fontSize = subtitleView.fontSize * ratio;
    subtitle.title = subtitleView.title;
    subtitle.textColor = subtitleView.textColor;
    subtitle.animationType = subtitleView.animationType;
    subtitle.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds(self.mySAVideoRangeSlider.leftPosition, 600), CMTimeMakeWithSeconds(self.mySAVideoRangeSlider.rightPosition - self.mySAVideoRangeSlider.leftPosition, 600));
    
    [self.currentVideo.subtitleArray addObject:subtitle];
    
    [subtitleView removeFromSuperview];
    
    __weak typeof(self) weakself = self;
    [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
        weakself.playView.playUrl = assetURL;
        [weakself.playView startPlayer];
    }];
}

#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.playView.nowTime = CMTimeMakeWithSeconds(leftPosition, 600);
}

#pragma mark - property
- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.playUrl = self.currentVideo.afterEditingPath;
        _playView.totalTime = _currentVideo.totalTime;
    }
    return _playView;
}

- (VideoObject *)currentVideo {
    if (!_currentVideo) {
        _currentVideo = [VideoObject currentVideo];
    }
    return _currentVideo;
}

- (SAVideoRangeSlider *)mySAVideoRangeSlider {
    if (!_mySAVideoRangeSlider) {
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width-40, 50) videoUrl:self.currentVideo.afterEditingPath];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        _mySAVideoRangeSlider.delegate = self;
    }
    return _mySAVideoRangeSlider;
}

@end
