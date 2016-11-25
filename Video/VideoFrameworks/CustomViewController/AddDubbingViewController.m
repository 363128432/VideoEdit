//
//  AddDubbingViewController.m
//  Video
//
//  Created by 付州  on 16/8/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddDubbingViewController.h"
#import "DubbingElementObject.h"
#import "VideoObject.h"
#import "VideoPlayView.h"
#import "SAVideoRangeSlider.h"
#import "DubbingManage.h"

@interface AddDubbingViewController ()<SAVideoRangeSliderDelegate,UIScrollViewDelegate,DubbingManageDelegate,VideoPlayViewDelegate>
{
    UIButton *playButton;
}

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *dubbingButton;

@property (nonatomic, strong) UIView *dubbingViewBackView;
@property (nonatomic, strong) UIView *currentDubbingView;

@property (nonatomic, assign) BOOL isStartDubbing;      // 是否正在录音

@property (nonatomic, strong) VideoObject *currentVideo;    //

@property (nonatomic, strong) DubbingManage *manage;

@end

@implementation AddDubbingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.manage = [[DubbingManage alloc]init];
    self.manage.delegate = self;
    
    [self.view addSubview:self.playView];
    
    playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 250, 40, 50)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(40, 250, self.view.frame.size.width-40, 50) ];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(2 * _scrollView.bounds.size.width, 50);
    [self.view addSubview:_scrollView];
    
    UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 54)];
    markView.center = _scrollView.center;
    markView.backgroundColor = [UIColor redColor];
    [self.view addSubview:markView];
    
    
    [self.scrollView addSubview:self.mySAVideoRangeSlider];
    
    
    _dubbingViewBackView = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _dubbingViewBackView.backgroundColor = [UIColor clearColor];
    [self.mySAVideoRangeSlider addSubview:_dubbingViewBackView];
    
    [self reloadDubbingView];
    
}

- (void)reloadDubbingView {
    [self.dubbingViewBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    for (DubbingElementObject *object in self.currentVideo.dubbingArray) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(object.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(object.insertTime.duration)], 50)];
        view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
        [_dubbingViewBackView addSubview:view];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dubbingElementWithTimeChange:(DubbingElementObject *)dubbingObject {
    _currentDubbingView.frame = CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(dubbingObject.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(dubbingObject.insertTime.duration)], 50);
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:CMTimeGetSeconds(dubbingObject.insertTime.start)] + [self correspondingXWithTime:CMTimeGetSeconds(dubbingObject.insertTime.duration)], 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.playView.isPlay) {
        return;
    }
    
    self.playView.nowTime = CMTimeMakeWithSeconds([self currentTime], 600);
    if (!_isStartDubbing) {
        if ([self.currentVideo searchHaveDubbingElementWithThisTime:[self currentTime]]) {
            [self.dubbingButton setTitle:@"删除" forState:UIControlStateNormal];
        }else {
            [self.dubbingButton setTitle:@"开始配音" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)startDubbingAction:(id)sender {
    [self.playView pausePlayer];
    playButton.selected = NO;
    
    if ([self.dubbingButton.titleLabel.text isEqualToString:@"删除"]) {
        [self.currentVideo.dubbingArray removeObject:[self.currentVideo searchHaveDubbingElementWithThisTime:[self currentTime]]];
        [self reloadDubbingView];
    }else if ([self.dubbingButton.titleLabel.text isEqualToString:@"开始配音"]) {
        [self.dubbingButton setTitle:@"停止配音" forState:UIControlStateNormal];
        [self.manage startRecordingWithStartTime:[self currentTime]];
        self.isStartDubbing = YES;
        
        _currentDubbingView = [[UIView alloc]initWithFrame:CGRectZero];
        _currentDubbingView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
        [_dubbingViewBackView addSubview:_currentDubbingView];
    }else if ([self.dubbingButton.titleLabel.text isEqualToString:@"停止配音"]) {
        [self.currentVideo addDubbingArrayObject:[self.manage stopRecord]];
        [self reloadDubbingView];
        [self.dubbingButton setTitle:@"删除" forState:UIControlStateNormal];
        self.isStartDubbing = NO;
    }
}

- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.currentVideo.totalTime) * self.mySAVideoRangeSlider.bounds.size.width;
}

- (NSTimeInterval)currentTime {
    return self.scrollView.contentOffset.x / self.mySAVideoRangeSlider.bounds.size.width * CMTimeGetSeconds(self.currentVideo.totalTime);
}

- (void)videoPlayViewPlayerPlayEnd:(VideoPlayView *)playView {
    playButton.selected = NO;
}

- (IBAction)playAction:(UIButton *)button {
    if (!button.isSelected) {
        [self.HUD show:YES];
        __weak typeof(self) weakself = self;
        [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
            weakself.playView.playUrl = assetURL;
            [weakself.playView startPlayer];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.HUD hide:YES];
                [weakself.HUD removeFromSuperview];
                weakself.HUD = nil;
                weakself.playView.totalTime = _currentVideo.totalTime;
                weakself.playView.separatePoints = _currentVideo.materialPointsArray;
                if (error) {
                    [MBProgressHUD showHUDInView:self.view.window text:@"合成失败"];
                    [self.playView pausePlayer];
                }
            });
        }];
    }else {
        [self.playView pausePlayer];
    }
    
    button.selected = !button.isSelected;
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.totalTime = self.currentVideo.totalTime;
        _playView.separatePoints = self.currentVideo.materialPointsArray;
        _playView.delegate = self;
        _playView.playUrl = self.currentVideo.afterEditingPath;
        [self.playView startPlayer];
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
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width / 2, 0, self.scrollView.frame.size.width, 50) videoUrl:self.currentVideo.afterEditingPath];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        _mySAVideoRangeSlider.delegate = self;
    }
    return _mySAVideoRangeSlider;
}

@end
