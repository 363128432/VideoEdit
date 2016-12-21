//
//  AddStickerViewController.m
//  Video
//
//  Created by 付州  on 16/11/2.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddStickerViewController.h"
#import "VideoPlayView.h"
#import "SAVideoRangeSlider.h"
#import "UIView+Extra.h"
#import "CustomMacros.h"
#import "AnimatedStickerObject.h"
#import "BBStickerView.h"
#import "StickerElementObject.h"

@interface AddStickerViewController ()<SAVideoRangeSliderDelegate,UIScrollViewDelegate,BBStickerViewDelegate,VideoPlayViewDelegate>

@property (nonatomic, strong) VideoObject *currentVideo;

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *stickerTimeBackView;  //滑动上的贴纸标识的父视图
@property (nonatomic, strong) UIView *stickerSelectView;    //贴纸选择视图
@property (weak, nonatomic) IBOutlet UIView *maskView;      //贴纸选择的父视图
@property (weak, nonatomic) IBOutlet UIButton *addButton;   //

@property (nonatomic, strong) NSMutableArray *stickerChooseArray; //可供选择的贴纸

@property (nonatomic, strong) StickerElementObject *currentStickerElement;//当前贴纸元素
@property (nonatomic, strong) BBStickerView *currentStickerView; //当前贴纸视图
@property (nonatomic, strong) UIView *currentTimeView; ////当前贴纸时间标签

@end

@implementation AddStickerViewController
{
    UIButton *playButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playView];
    [self.addButton setLayarCornerRadius:25 borderWidth:1 borderColor:[UIColor grayColor]];
    
    playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 250, 40, 50)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(40, 250, self.view.frame.size.width-40, 50) ];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    // 指示条
    UIView *markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 54)];
    markView.center = _scrollView.center;
    markView.backgroundColor = [UIColor redColor];
    [self.view addSubview:markView];
    
    [self.scrollView addSubview:self.mySAVideoRangeSlider];
    _scrollView.contentSize = CGSizeMake(_scrollView.width + _mySAVideoRangeSlider.bounds.size.width, 50);
    
    _stickerTimeBackView = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _stickerTimeBackView.backgroundColor = [UIColor clearColor];
    [self.mySAVideoRangeSlider addSubview:_stickerTimeBackView];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.leftThumb];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.rightThumb];
    
    for (int i = 0; i < self.currentVideo.stickerArray.count; i++) {
        [self addStickerViewAndStickerTimeViewWithStickerElement:self.currentVideo.stickerArray[i] animation:NO];
    }
    
    [self.maskView addSubview:self.stickerSelectView];
    [self.view bringSubviewToFront:self.maskView];
    [self currentTimeViewStyle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.playView.delegate = nil;
}

- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.currentVideo.totalTime) * self.mySAVideoRangeSlider.bounds.size.width;
}

- (NSTimeInterval)currentTime {
    return self.scrollView.contentOffset.x / self.mySAVideoRangeSlider.bounds.size.width * CMTimeGetSeconds(self.currentVideo.totalTime);
}

// 根据AnimatedStickerObject创建对应的贴纸元素
- (StickerElementObject *)createStickerElementObjectWith:(AnimatedStickerObject *)animatedSticker {
    BBStickerView *stickerView = [[BBStickerView alloc]initWithWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * animatedSticker.storyboard.widthRatio, self.playView.contentView.bounds.size.height * animatedSticker.storyboard.heightRatio) AnimatedStickerObject:animatedSticker animation:NO];
    stickerView.center = self.playView.contentView.center;
    
    StickerElementObject *stickerElement = [[StickerElementObject alloc]init];
    stickerElement.stickerView = stickerView;
    stickerElement.animatedSticker = animatedSticker;
    stickerElement.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds([self currentTime], 600), CMTimeMakeWithSeconds(MIN([animatedSticker.storyboard.stickerDuration floatValue], CMTimeGetSeconds(self.currentVideo.totalTime) - [self currentTime]), 600));
    
    return stickerElement;
}

/**
 * 添加贴纸视图和时间标签视图
 *
 * @param stickerElement 贴纸元素
 * @param animation      贴纸动画
 */
- (void)addStickerViewAndStickerTimeViewWithStickerElement:(StickerElementObject *)stickerElement animation:(BOOL)animation{
    BBStickerView *stickerView = stickerElement.stickerView;
    stickerView.operaterHidden = YES;
    if (animation) {
        [stickerView startImageAnimation];
    }
    stickerView.delegate = self;
    stickerView.insetTime = stickerElement.insertTime;
    _currentStickerView = stickerView;
    [self.playView.contentView addSubview:stickerView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(stickerElement.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(stickerElement.insertTime.duration)], 50)];
    view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
    _currentTimeView = view;
    [_stickerTimeBackView addSubview:view];
    
}

- (void)getTheCurrentWithIndex:(NSInteger)index {
    _currentStickerView = self.playView.contentView.subviews[index];
    _currentTimeView = self.stickerTimeBackView.subviews[index];
    _currentStickerElement = self.currentVideo.stickerArray[index];
}

- (void)removeCurrentDataEmpty {
    [_currentStickerView removeFromSuperview];
    self.mySAVideoRangeSlider.allHide = YES;
    [_currentTimeView removeFromSuperview];
    [self.currentVideo.stickerArray removeObject:_currentStickerElement];
    
    [self currentDataEmpty];
}

- (void)currentDataEmpty {
    _currentStickerElement = nil;
    _currentTimeView = nil;
    _currentStickerView = nil;
}

- (void)reloadCurrentEditStickerView {
    _currentStickerView.operaterHidden = NO;
    self.mySAVideoRangeSlider.allHide = NO;
    [self.mySAVideoRangeSlider setLeftVaule:CMTimeGetSeconds(_currentStickerElement.insertTime.start) rightVaule:(CMTimeGetSeconds(_currentStickerElement.insertTime.start) + CMTimeGetSeconds(_currentStickerElement.insertTime.duration))];
}


#pragma mark Action
- (void)playAction:(UIButton *)button {
    if (!button.isSelected) {
        [self.HUD show:YES];
        __weak typeof(self) weakself = self;
        [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.playView replaceCurrentPlayUrl:assetURL];
                [weakself.playView startPlayer];
            });
//            [weakself.playView replaceCurrentPlayUrl:assetURL];
//            [weakself.playView startPlayer];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.HUD hide:YES];
                [weakself.HUD removeFromSuperview];
                _currentStickerView.hidden = YES;
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

// 添加按钮
- (IBAction)addAction:(id)sender {
    [self.playView pausePlayer];
    playButton.selected = NO;
    
    self.maskView.hidden = NO;
    _currentStickerView.operaterHidden = YES;
    [self currentDataEmpty];
}

// 上一个内容
- (IBAction)previousAction:(id)sender {
    NSTimeInterval nowTime = [self currentTime];
    nowTime -= 1;
    nowTime = MAX(nowTime, 0);
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:nowTime], 0);
}

// 下一个内容
- (IBAction)nextAction:(id)sender {
    NSTimeInterval nowTime = [self currentTime];
    nowTime += 1;
    nowTime = MIN(nowTime, CMTimeGetSeconds(self.currentVideo.totalTime));
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:nowTime], 0);
}

// 确定
- (IBAction)makeSureAction:(id)sender {
    self.maskView.hidden = YES;
}

- (void)selectStickerAction:(UIButton *)button {
    // 如果有贴纸对象，表示是更换贴纸，获取更换前的（即最后个贴纸）删除
    if (_currentStickerElement) {
        [self getTheCurrentWithIndex:self.currentVideo.stickerArray.count - 1];
        [self removeCurrentDataEmpty];
    }
    
    AnimatedStickerObject *stick = self.stickerChooseArray[button.tag - 5000];
    
    StickerElementObject *stickerElement = [self createStickerElementObjectWith:stick];
    [self.currentVideo addStickerObject:stickerElement];
    _currentStickerElement = stickerElement;
    [self addStickerViewAndStickerTimeViewWithStickerElement:stickerElement animation:YES];
    
    [self.playView startPlayerWithTime:stickerElement.insertTime.start];
    [self performSelector:@selector(animationPlayFinish) withObject:nil afterDelay:CMTimeGetSeconds(stickerElement.insertTime.duration)];
}

- (void)animationPlayFinish {
    [self.playView pausePlayer];
}

#pragma mark VideoPlayViewDelegate
- (void)videoPlayViewPlayerPlayEnd:(VideoPlayView *)playView {
    playButton.selected = NO;
    [self.playView replaceCurrentPlayUrl:self.currentVideo.noSubtitleVideoPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.playView pausePlayer];
    });
}

- (void)videoPlayViewPlayerIsPlay:(VideoPlayView *)playView {
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:CMTimeGetSeconds(playView.nowTime)], 0);
}

#pragma mark BBStickerViewDelegate
- (void)BBStickerViewDidAnimationFinish:(BBStickerView *)stickerView {
    stickerView.operaterHidden = NO;
}

- (void)BBStickerViewDidMoveAndRotateFinish:(BBStickerView *)stickerView {
    
}

- (void)BBStickerView:(BBStickerView *)stickerView btnType:(StickerViewButtonType)btnType {
    if (btnType == StickerViewButtonTypeWithDelege) {
        [self removeCurrentDataEmpty];
    }else if (btnType == StickerViewButtonTypeWithReverse) {

    }
}

#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.playView.nowTime = CMTimeMakeWithSeconds(videoRange.isMoveLeft?leftPosition:rightPosition, 600);
    
    _currentTimeView.frame = CGRectMake([self correspondingXWithTime:leftPosition], 0, [self correspondingXWithTime:rightPosition] - [self correspondingXWithTime:leftPosition], 50);
    _currentStickerElement.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds(leftPosition, 600), CMTimeMakeWithSeconds(rightPosition - leftPosition, 600));
}


#pragma mark scrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.playView.isPlay) {
        return;
    }
    
    self.playView.nowTime = CMTimeMakeWithSeconds([self currentTime], 600);

    [self currentTimeViewStyle];
}

// 当前时间view的一些状态，显示，隐藏，显示边框
- (void)currentTimeViewStyle {
    NSArray *array = [self.currentVideo searchHaveStickerElementWithThisTime:[self currentTime]];
    for (int i = 0; i < self.currentVideo.stickerArray.count; i++) {
        StickerElementObject *stickerElement = self.currentVideo.stickerArray[i];
        BBStickerView *stickerView = self.playView.contentView.subviews[i];
        stickerView.hidden = ([array indexOfObject:stickerElement] == NSNotFound)?YES:NO;
    }
    
    if (array.count == 1) {
        NSInteger index = [self.currentVideo.stickerArray indexOfObject:array[0]];
        [self getTheCurrentWithIndex:index];
        [self reloadCurrentEditStickerView];
        _currentStickerView.operaterHidden = NO;
    }else {
        _currentStickerView.operaterHidden = YES;
        self.mySAVideoRangeSlider.allHide = YES;
    }
}


#pragma mark - property
- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) playUrl:self.currentVideo.afterEditingPath userFFMPEG:YES];
        _playView.delegate = self;
        _playView.statusView.hidden = YES;
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
        _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width / 2, 0, CMTimeGetSeconds(self.currentVideo.totalTime) * 20, 50) videoUrl:self.currentVideo.afterEditingPath];
        _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
        _mySAVideoRangeSlider.allHide = YES;
        _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
        _mySAVideoRangeSlider.delegate = self;
    }
    return _mySAVideoRangeSlider;
}

- (UIView *)stickerSelectView {
    if (!_stickerSelectView) {
        _stickerSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
        
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 6; j++) {
                if (i * 6 + j == self.stickerChooseArray.count) {
                    break;
                }
                AnimatedStickerObject *object = self.stickerChooseArray[i * 6 + j];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(10 + j * SCREEN_WIDTH / 6,  i * 80, 50, 60);
                [button setImage:[UIImage imageWithContentsOfFile:object.coverPath] forState:UIControlStateNormal];
                button.tag = 5000 + i * 6 + j;
                [button addTarget:self action:@selector(selectStickerAction:) forControlEvents:UIControlEventTouchUpInside];
                [_stickerSelectView addSubview:button];
            }
        }
    }
    return _stickerSelectView ;
}

- (NSMutableArray *)stickerChooseArray {
    if (!_stickerChooseArray) {
        _stickerChooseArray = [AnimatedStickerObject allAnimatedSticker];
    }
    return _stickerChooseArray;
}

@end
