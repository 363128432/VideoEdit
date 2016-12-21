//
//  AddMusicViewController.m
//  Video
//
//  Created by 付州  on 16/9/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddMusicViewController.h"
#import "SAVideoRangeSlider.h"
#import "VideoPlayView.h"
#import "SelectMusicTableViewController.h"

@interface AddMusicViewController ()<SAVideoRangeSliderDelegate,UIScrollViewDelegate,VideoPlayViewDelegate>

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addButton;

@property (nonatomic, strong) UIView *musicViewBackView;
@property (nonatomic, strong) UIView *currentDubbingView;
@property (nonatomic, strong) MusicElementObject *currentMusicElement;

@property (nonatomic, strong) VideoObject *currentVideo;    //


@end

@implementation AddMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _currentVideo = [VideoObject currentVideo];
    
    [self.view addSubview:self.playView];
    
    UIButton *playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 250, 40, 50)];
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
    
    
    _musicViewBackView = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _musicViewBackView.backgroundColor = [UIColor clearColor];
    [self.mySAVideoRangeSlider addSubview:_musicViewBackView];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.leftThumb];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.rightThumb];
    
    [self reloadMusicView];
    
    
    _addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _addButton.center = CGPointMake(200, CGRectGetHeight(self.view.bounds) - 104);
    [_addButton setTitle:@"添加" forState:UIControlStateNormal];
    [_addButton setTitle:@"删除" forState:UIControlStateSelected];
    [_addButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addOrDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
}

// 刷新视图
- (void)reloadMusicView {
    [self.musicViewBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    for (MusicElementObject *object in self.currentVideo.musicArray) {
        [self addTimeViewWithEmusicElement:object];
    }
}

// 根据MusicElementObject添加时间标记视图
- (UIView *)addTimeViewWithEmusicElement:(MusicElementObject *)musicElement {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(musicElement.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(musicElement.insertTime.duration)], 50)];
    view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
    [_musicViewBackView addSubview:view];
    return view;
}

- (void)reloadEditMusicElementStyle {
    if (_currentMusicElement) {
        self.mySAVideoRangeSlider.allHide = NO;
        [self.mySAVideoRangeSlider setLeftVaule:CMTimeGetSeconds(_currentMusicElement.insertTime.start) rightVaule:(CMTimeGetSeconds(_currentMusicElement.insertTime.start) + CMTimeGetSeconds(_currentMusicElement.insertTime.duration))];
    }else {
        self.mySAVideoRangeSlider.allHide = YES;
    }
}

- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.currentVideo.totalTime) * self.mySAVideoRangeSlider.bounds.size.width;
}

- (NSTimeInterval)currentTime {
    return self.scrollView.contentOffset.x / self.mySAVideoRangeSlider.bounds.size.width * CMTimeGetSeconds(self.currentVideo.totalTime);
}

#pragma mark Action
- (IBAction)playAction:(UIButton *)button {
    if (!button.isSelected) {
        [self.HUD show:YES];
        __weak typeof(self) weakself = self;
        [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
            [weakself.playView replaceCurrentPlayUrl:assetURL];
//            [weakself.playView startPlayerWithTime:CMTimeMakeWithSeconds([self currentTime], 600)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.playView startPlayerWithTime:CMTimeMakeWithSeconds([self currentTime], 600)];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.HUD hide:YES];
                [weakself.HUD removeFromSuperview];
                weakself.HUD = nil;
                weakself.playView.totalTime = _currentVideo.totalTime;
                weakself.playView.separatePoints = _currentVideo.materialPointsArray;
                if (error) {
                    [MBProgressHUD showHUDInView:self.view.window text:@"合成失败"];
                }
            });
        }];
    }else {
        [self.playView pausePlayer];
    }
    
    button.selected = !button.isSelected;
}


- (void)addOrDeleteAction:(UIButton *)button {
    if (button.isSelected) {
        NSInteger index = [self.currentVideo.musicArray indexOfObject:_currentMusicElement];
        [self.currentVideo.musicArray removeObject:_currentMusicElement];
        [self.musicViewBackView.subviews[index] removeFromSuperview];
        _currentMusicElement = nil;
        _currentDubbingView = nil;
        self.mySAVideoRangeSlider.allHide = YES;
//        [self reloadMusicView];
    }else {
        [self performSegueWithIdentifier:@"SelectMusicTableViewController" sender:nil];
    }
}

#pragma mark delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.playView.isPlay) {
        return;
    }
    
    self.playView.nowTime = CMTimeMakeWithSeconds([self currentTime], 600);

    _currentMusicElement = [self.currentVideo searchHaveMusicElementWithThisTime:[self currentTime]];
    if (_currentMusicElement) {
        self.addButton.selected = YES;
        
        NSInteger index = [self.currentVideo.musicArray indexOfObject:_currentMusicElement];
        _currentDubbingView = self.musicViewBackView.subviews[index];
    }else {
        self.addButton.selected = NO;
    }
    [self reloadEditMusicElementStyle];
}

#pragma mark VideoPlayViewDelegate
- (void)videoPlayViewPlayerIsPlay:(VideoPlayView *)playView {
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:CMTimeGetSeconds(playView.nowTime)], 0);
    NSLog(@"%f",CMTimeGetSeconds(playView.nowTime));
}

#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.playView.nowTime = CMTimeMakeWithSeconds(videoRange.isMoveLeft?leftPosition:rightPosition, 600);
    
    _currentDubbingView.frame = CGRectMake([self correspondingXWithTime:leftPosition], 0, [self correspondingXWithTime:rightPosition] - [self correspondingXWithTime:leftPosition], 50);
    _currentMusicElement.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds(leftPosition, 600), CMTimeMakeWithSeconds(rightPosition - leftPosition, 600));
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) playUrl:_currentVideo.afterEditingPath userFFMPEG:YES];
        _playView.totalTime = _currentVideo.totalTime;
        _playView.separatePoints = _currentVideo.materialPointsArray;
        _playView.delegate = self;
    }
    return _playView;
}

- (SAVideoRangeSlider *)mySAVideoRangeSlider {
    if (!_mySAVideoRangeSlider) {
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width / 2, 0, self.scrollView.frame.size.width, 50) videoUrl:self.currentVideo.afterEditingPath];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        _mySAVideoRangeSlider.delegate = self;
        _mySAVideoRangeSlider.allHide = YES;
    }
    return _mySAVideoRangeSlider;
}

#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([[segue destinationViewController] isKindOfClass:[SelectMusicTableViewController class]]) {
         SelectMusicTableViewController *vc = [segue destinationViewController];
         __weak typeof(self) weakself = self;
         [vc selectMusicElementcompletion:^(MusicElementObject *musicElement) {
             musicElement.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds([self currentTime], 600), musicElement.playTimeRange.duration);
             musicElement = [weakself.currentVideo addMusicArrayObject:musicElement];
             _currentDubbingView = [self addTimeViewWithEmusicElement:musicElement];
             _currentMusicElement = musicElement;
             [self reloadEditMusicElementStyle];
//             [weakself reloadMusicView];
         }];
     }
 }

@end
