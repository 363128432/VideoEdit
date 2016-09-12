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

    
    self.maskView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)determineAction:(id)sender {
    subtitleView = [[SubtitlesView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) title:self.textView.text];
    subtitleView.center = self.playView.container.center;
    [self.playView addSubview:subtitleView];
    
    [self cancelAction:nil];
}

- (IBAction)determineAddAction:(id)sender {
    SubtitleElementObject *subtitle = [[SubtitleElementObject alloc]init];
    subtitle.font = subtitleView.titleFont;
    CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    CGRect textRect = [subtitleView convertRect:subtitleView.textLabel.frame toView:self.playView.container];
//    subtitle.rect = CGRectMake(0, 0, textRect.size.width * ratio, textRect.size.height * ratio);
    subtitle.rect = CGRectMake(textRect.origin.x * ratio, (self.playView.container.bounds.size.height - textRect.origin.y) * ratio - textRect.size.height * ratio, textRect.size.width * ratio, textRect.size.height * ratio);
    subtitle.fontSize = subtitleView.fontSize * ratio;
    subtitle.title = subtitleView.title;
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
