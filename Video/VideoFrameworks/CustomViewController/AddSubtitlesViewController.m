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
#import "UIView+Custom.h"

@interface AddSubtitlesViewController ()<SAVideoRangeSliderDelegate,UIScrollViewDelegate,SubtitlesViewDelegate,VideoPlayViewDelegate>
//{
//    SubtitlesView *subtitleView;
//}

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic, strong) VideoObject *currentVideo;
@property (nonatomic, strong) SubtitlesView *currentSubtitleView;       // 当前编辑的字幕视图
//@property (nonatomic, strong) UIView *currentTimeView;                  // 当前插入时间遮罩视图

@property (nonatomic, strong) UIView *subTitleBackView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIView *styleView;
@property (weak, nonatomic) IBOutlet UIView *styleFunctionView;

@property (weak, nonatomic) IBOutlet UIButton *styleButton;

@property (nonatomic, strong) NSMutableArray<SubtitlesView *> *subtitleArray;    // 字幕视图数组
@property (nonatomic, assign) NSUInteger currentIndex;

@end

@implementation AddSubtitlesViewController
{
    UIButton *playButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.edgesForExtendedLayout = UIRectEdgeNone;

    
    [self.view addSubview:self.playView];
//    [self.view addSubview:self.mySAVideoRangeSlider];
    
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
    
    [self.view bringSubviewToFront:self.backView];

    
    [self currentType:0];
    
    _subTitleBackView = [[UIView alloc]initWithFrame:self.mySAVideoRangeSlider.bounds];
    _subTitleBackView.backgroundColor = [UIColor clearColor];
    [self.mySAVideoRangeSlider addSubview:_subTitleBackView];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.leftThumb];
    [self.mySAVideoRangeSlider bringSubviewToFront:self.mySAVideoRangeSlider.rightThumb];

    [self reloadSubtitleView];
//    [self scrollViewDidScroll:_scrollView];
    
    [self playAction:playButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.playView.delegate = nil;
    [self.playView pausePlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 当前状态，0，正常。1，正在输入。2，添加文字视图，但没选择样式。3，选择样式
- (void)currentType:(NSInteger)type {
    switch (type) {
        case 0: {
            self.backView.hidden = YES;
            self.styleView.hidden = YES;
            self.styleButton.hidden = YES;
        }
            break;
        case 1: {
            self.backView.hidden = NO;
            self.styleView.hidden = YES;
            self.styleButton.hidden = YES;
            [self.textView becomeFirstResponder];
        }
            break;
        case 2: {
            self.backView.hidden = YES;
            self.styleView.hidden = YES;
            self.styleButton.hidden = NO;
        }
            break;
        case 3: {
            self.backView.hidden = YES;
            self.styleView.hidden = NO;
            self.styleButton.hidden = YES;
        }
            break;
        default:
            break;
    }
}

// 根据字幕数组刷新视图，包括进度条和播放视图上的字幕视图
- (void)reloadSubtitleView {

    [self.subTitleBackView removeAllSubViews];
    
    [self.playView.container removeAllSubViews];
    
    for (SubtitlesView *object in self.subtitleArray) {
        // 进度条上表示进度的遮罩
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(object.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(object.insertTime.duration)], 50)];
        view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
        [_subTitleBackView addSubview:view];
        
        object.hidden = YES;
        [self.playView.container addSubview:object];
    }
}

- (void)reloadCurrentEditSubtitleView {
    _currentSubtitleView.hideBorder = NO;
    self.mySAVideoRangeSlider.allHide = NO;
    [self.mySAVideoRangeSlider setLeftVaule:CMTimeGetSeconds(_currentSubtitleView.insertTime.start) rightVaule:(CMTimeGetSeconds(_currentSubtitleView.insertTime.start) + CMTimeGetSeconds(_currentSubtitleView.insertTime.duration))];
}


- (CGFloat)correspondingXWithTime:(NSTimeInterval)time {
    return time / CMTimeGetSeconds(self.currentVideo.totalTime) * self.mySAVideoRangeSlider.bounds.size.width;
}

- (NSTimeInterval)currentTime {
    return self.scrollView.contentOffset.x / self.mySAVideoRangeSlider.bounds.size.width * CMTimeGetSeconds(self.currentVideo.totalTime);
}

// 选择动画类型
- (void)selectAnimation:(NSInteger)type {
    for (int i = 0; i < 6; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:11000 + i];
        button.selected = type == i ? YES : NO;
    }
}

- (void)selectTextcolor:(NSInteger)type {
    for (int i = 0; i < 6; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:11100 + i];
        button.layer.borderColor = [UIColor cyanColor].CGColor;
        button.layer.borderWidth = type == i ? 1 : 0;
    }
}

- (void)selectTextFont:(NSInteger)type {
    for (int i = 0; i < 6; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:11100 + i];
        button.layer.borderColor = [UIColor cyanColor].CGColor;
        button.layer.borderWidth = type == i ? 1 : 0;
    }
}

#pragma mark - action

- (void)playAction:(UIButton *)button {
    if (!button.isSelected) {
        for (SubtitlesView *view in self.playView.container.subviews) {
            if (CMTimeGetSeconds(view.insertTime.start) >= CMTimeGetSeconds(self.playView.nowTime)) {
                view.hidden = NO;
                view.hideBorder = YES;
                if (CMTimeGetSeconds(view.insertTime.start) >= CMTimeGetSeconds(self.playView.nowTime)) {
                    view.layer.opacity = 0;
                    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    opacityAnim.fromValue = [NSNumber numberWithFloat:1];
                    opacityAnim.toValue = [NSNumber numberWithFloat:1];
                    opacityAnim.removedOnCompletion = NO;
                    CABasicAnimation *rotationAnimation = [view addAnimationWithType:view.animationType];
                    CAAnimationGroup *group = [CAAnimationGroup animation];
                    group.animations = @[opacityAnim, rotationAnimation];
                    group.beginTime = CACurrentMediaTime() + CMTimeGetSeconds(view.insertTime.start) - CMTimeGetSeconds(self.playView.nowTime);
                    group.duration = CMTimeGetSeconds(view.insertTime.duration);
                    [view.layer addAnimation:group forKey:nil];
                }else {
                    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    opacityAnim.fromValue = [NSNumber numberWithFloat:1];
                    opacityAnim.toValue = [NSNumber numberWithFloat:1];
                    opacityAnim.removedOnCompletion = NO;
                    CAAnimationGroup *group = [CAAnimationGroup animation];
                    group.animations = @[opacityAnim];
                    group.beginTime = CACurrentMediaTime() + CMTimeGetSeconds(view.insertTime.start) + CMTimeGetSeconds(view.insertTime.duration) - CMTimeGetSeconds(self.playView.nowTime);
                    group.duration = CMTimeGetSeconds(view.insertTime.duration);
                    [view.layer addAnimation:group forKey:nil];
                }
            }
        }
        [self.playView startPlayer];
    }else {
        [self.playView pausePlayer];
    }
    
    playButton.selected = !playButton.isSelected;
}


- (IBAction)addSubtitleAction:(id)sender {
    self.backView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (IBAction)cancelAction:(id)sender {
    self.backView.hidden = YES;
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
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                    [button addTarget:self action:@selector(textAddAnimation:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
            [self selectAnimation:_currentSubtitleView.animationType];
        }
            break;
            
        case 1: {
            for (int i = 0; i < 3; i ++) {
                for (int j = 0; j < 10; j ++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j * self.styleFunctionView.bounds.size.width / 10, i * self.styleFunctionView.bounds.size.height / 3, self.styleFunctionView.bounds.size.width / 10, self.styleFunctionView.bounds.size.height / 3);
                    button.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1];
                    button.tag = 11100 + i * 10 + j;
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
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                    [button addTarget:self action:@selector(textAdjustFont:) forControlEvents:UIControlEventTouchUpInside];
                    [self.styleFunctionView addSubview:button];
                }
            }
//            self selectTextFont:subtitleView.f
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
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                    [self.styleFunctionView addSubview:button];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

// 确定样式
- (IBAction)textStyleDetermineAction:(id)sender {
    [self determineAddAction:nil];
}

- (void)textAddAnimation:(UIButton *)button {
    _currentSubtitleView.animationType = button.tag - 11000;
    [self selectAnimation:button.tag - 11000];
}

- (void)textFontSizeChange:(UISlider *)slider {
    _currentSubtitleView.fontSize = slider.value;
}

- (void)textAdjustColor:(UIButton *)button {
    _currentSubtitleView.textColor = button.backgroundColor ;
}

- (void)textAdjustFont:(UIButton *)button {
    _currentSubtitleView.titleFontName = button.titleLabel.font.fontName;
}

- (void)textAdjustPosition:(UIButton *)button {
    CGRect rect = _currentSubtitleView.frame;
    CGSize superViewSize = _currentSubtitleView.superview.frame.size;
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
    _currentSubtitleView.frame = rect;

}

- (IBAction)showStyleViewAction:(id)sender {
    [self styleAction:nil];

    [self currentType:3];
}

// 添加字幕
- (IBAction)determineAction:(id)sender {
    [self.playView pausePlayer];
    
    [self currentType:2];
    
    _currentSubtitleView.hideBorder = YES;
    
    // 添加字幕
    SubtitlesView *subview = [[SubtitlesView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) title:self.textView.text];
    subview.center = self.playView.container.center;
    subview.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds([self currentTime], 600), CMTimeMakeWithSeconds(MIN(2, CMTimeGetSeconds(self.currentVideo.totalTime) - [self currentTime]), 600));
    [self.playView.container addSubview:subview];
    [self.subtitleArray addObject:subview];
    _currentSubtitleView = subview;
    _currentSubtitleView.delegate = self;
    
    // 时间范围遮罩
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake([self correspondingXWithTime:CMTimeGetSeconds(subview.insertTime.start)], 0, [self correspondingXWithTime:CMTimeGetSeconds(subview.insertTime.duration)], 50)];
    view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3];
//    _currentTimeView = view;
    _currentIndex = self.subtitleArray.count - 1;
    [_subTitleBackView addSubview:view];
    
    [self reloadCurrentEditSubtitleView];
    
    [self cancelAction:nil];
}

- (IBAction)determineAddAction:(id)sender {
    [self currentType:0];
    self.styleButton.hidden = YES;
}

// 保存此次编辑
- (IBAction)saveAction:(id)sender {
    NSMutableArray *subtitleElementArray = [NSMutableArray arrayWithCapacity:self.subtitleArray.count];
    // 将所有的字幕视图转化为字幕元素
    [self.subtitleArray enumerateObjectsUsingBlock:^(SubtitlesView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SubtitleElementObject *subtitle = [[SubtitleElementObject alloc]init];
        subtitle.fontName = obj.titleFontName;
        CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
        CGRect textRect = [obj convertRect:obj.textLabel.frame toView:self.playView.container];
        
        subtitle.rect = CGRectMake(textRect.origin.x * ratio, (self.playView.container.bounds.size.height - textRect.origin.y) * ratio - textRect.size.height * ratio, textRect.size.width * ratio, textRect.size.height * ratio);
        subtitle.fontSize = obj.fontSize * ratio;
        subtitle.title = obj.title;
        subtitle.textColor = obj.textColor;
        subtitle.animationType = obj.animationType;
        subtitle.insertTime = obj.insertTime;
        
        [subtitleElementArray addObject:subtitle];
    }];
    
    self.currentVideo.subtitleArray = subtitleElementArray;
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 放弃此次编辑
- (IBAction)giveUpEditAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否放弃此次编辑" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *makeSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:cancle];
    [alert addAction:makeSure];
    [self presentViewController:alert animated:YES completion:nil];
}

    
#pragma mark VideoPlayViewDelegate
- (void)videoPlayViewPlayerIsPlay:(VideoPlayView *)playView {
//    playButton.selected = YES;
    self.scrollView.contentOffset = CGPointMake([self correspondingXWithTime:CMTimeGetSeconds(playView.nowTime)], 0);
}

- (void)videoPlayViewPlayerPlayEnd:(VideoPlayView *)playView {
    playButton.selected = NO;
    for (SubtitlesView *view in self.playView.container.subviews) {
        [view.layer removeAllAnimations];
        view.layer.opacity = 1;
    }
}

- (void)videoPlayViewPlayerStart:(VideoPlayView *)playView {

}

- (void)videoPlayViewPlayerPause:(VideoPlayView *)playView {
//    [self videoPlayViewPlayerPlayEnd:playView];
    for (SubtitlesView *view in self.playView.container.subviews) {
        [view.layer removeAllAnimations];
        view.layer.opacity = 1;
    }
}

#pragma mark delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.playView.isPlay) {
        return;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];   // 用来统计当前时间有多少字幕
    // 遍历播放视图上的字幕视图，在当前时间段的显示
    for (SubtitlesView *subView in self.playView.container.subviews) {
        if ([self currentTime] >= CMTimeGetSeconds(subView.insertTime.start) && [self currentTime] <= CMTimeGetSeconds(subView.insertTime.start) + CMTimeGetSeconds(subView.insertTime.duration)) {
            subView.hidden = NO;
            [array addObject:subView];
        }else {
            subView.hidden = YES;
        }
        subView.hideBorder = YES;
    }
    // 如果当前时间只有一个字幕，表示可编辑
    if (array.count == 1) {
        _currentSubtitleView = array[0];
        _currentSubtitleView.delegate = self;
        _currentIndex = [self.playView.container.subviews indexOfObject:_currentSubtitleView];
        [self reloadCurrentEditSubtitleView];
        _styleButton.hidden = NO;
    }else {
        self.mySAVideoRangeSlider.allHide = YES;
    }
    
    self.playView.nowTime = CMTimeMakeWithSeconds([self currentTime], 600);
}

- (void)deleteView {
    [self.subtitleArray removeObject:_currentSubtitleView];
    [self.subTitleBackView.subviews[_currentIndex] removeFromSuperview];
    
    if (self.subtitleArray.count == 0) {
        [self.subTitleBackView removeAllSubViews];
    }
    self.mySAVideoRangeSlider.allHide = YES;
}

#pragma mark SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.playView.nowTime = CMTimeMakeWithSeconds(videoRange.isMoveLeft?leftPosition:rightPosition, 600);
    UIView *timeMaskView = self.subTitleBackView.subviews[_currentIndex];
    timeMaskView.frame = CGRectMake([self correspondingXWithTime:leftPosition], 0, [self correspondingXWithTime:rightPosition] - [self correspondingXWithTime:leftPosition], 50);
    _currentSubtitleView.insertTime = CMTimeRangeMake(CMTimeMakeWithSeconds(leftPosition, 600), CMTimeMakeWithSeconds(rightPosition - leftPosition, 600));
}

#pragma mark - property
- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.playUrl = self.currentVideo.noSubtitleVideoPath;
        _playView.totalTime = _currentVideo.totalTime;
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

- (NSMutableArray<SubtitlesView *> *)subtitleArray {
    if (!_subtitleArray) {
        _subtitleArray = [NSMutableArray arrayWithCapacity:self.currentVideo.subtitleArray.count];
        
        CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
        [self.currentVideo.subtitleArray enumerateObjectsUsingBlock:^(SubtitleElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 播放视力上的字幕视图
            
            CGRect subtitleViewRect = CGRectMake(obj.rect.origin.x / ratio - BT_SIZE, self.playView.container.height - obj.rect.origin.y / ratio - obj.rect.size.height / ratio - BT_SIZE, obj.rect.size.width / ratio + 2 * BT_SIZE, obj.rect.size.height / ratio + 2 * BT_SIZE);
            SubtitlesView *subView = [[SubtitlesView alloc]initWithFrame:subtitleViewRect title:obj.title];
            subView.titleFontName = obj.fontName;
            subView.fontSize = obj.fontSize / ratio;
            subView.textColor = obj.textColor;
            subView.animationType = obj.animationType;
            subView.insertTime = obj.insertTime;
            subView.hideBorder = YES;
            
            [_subtitleArray addObject:subView];
        }];
    }
    return _subtitleArray;
}



@end
