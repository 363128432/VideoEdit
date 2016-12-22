//
//  EditVideoMainViewController.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "EditVideoMainViewController.h"
#import "VideoPlayView.h"
#import "SelectMusicTableViewController.h"
#import "ThemeObject.h"
#import "UIView+Extra.h"
#import "CustomMacros.h"
#import "MBProgressHUD+Extra.h"

@interface EditVideoMainViewController ()

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIView *function;         // 功能视图

@property (nonatomic, strong) UIView *contentView;      //
@property (nonatomic, strong) UIView *musicView;        // 选择音乐view
@property (nonatomic, strong) UIView *themeView;

@property (nonatomic, strong) NSArray *themeArray;
@property (nonatomic, assign) NSInteger themeSelectIndex;
@property (nonatomic, strong) UIView *themeMaskView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation EditVideoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _currentVideo = [VideoObject currentVideo];

    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.function];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.themeView];
}

- (IBAction)backAction:(id)sender {
    // 退出视频编辑页面，得将当前编辑常量置空
    [VideoObject attemptDealloc];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playView pausePlayer];
    
    [self.HUD hide:YES];
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self combinaAndPlay];
}

// 合成并播放
- (void)combinaAndPlay {
    [self.HUD show:YES];
    __weak typeof(self) weakself = self;
    [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.playView replaceCurrentPlayUrl:assetURL];
            
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[SelectMusicTableViewController class]]) {
        SelectMusicTableViewController *vc = [segue destinationViewController];
        __weak typeof(self) weakself = self;
        [vc selectMusicElementcompletion:^(MusicElementObject *musicElement) {
            [weakself.currentVideo setBackgroundMusic:musicElement];
        }];
    }
}

- (void)functionAction:(UIButton *)button {
    switch (button.tag - 120) {
        case 0:{
            [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            [self.contentView addSubview:self.themeView];
        }
            break;
        case 1:{
            [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            [self.contentView addSubview:self.musicView];
        }
            break;
        case 2:{
            [self performSegueWithIdentifier:@"MaterialEditTableViewController" sender:nil];
        }
            break;
        case 3:{
            [self performSegueWithIdentifier:@"AddSubtitlesViewController" sender:nil];
        }
            break;
        case 4:{
            [self performSegueWithIdentifier:@"AddStickerViewController" sender:nil];
        }
            break;
        case 5:{
            [self performSegueWithIdentifier:@"AddDubbingViewController" sender:nil];
        }
            break;
        case 6:{
        }
            break;
            
        default:
            break;
    }
}

- (void)musicAction:(UIButton *)button {
    if (button.tag == 110) {
        [self performSegueWithIdentifier:@"SelectMusicTableViewController" sender:nil];
    }else {
        [self performSegueWithIdentifier:@"AddMusicViewController" sender:nil];
    }
}

- (void)themeAction:(UIButton *)button {
    [self.playView pausePlayer];
    
    [_themeMaskView removeFromSuperview];
    self.themeSelectIndex = button.tag - 100;
    [button addSubview:self.themeMaskView];
    
    ThemeObject *object = self.themeArray[self.themeSelectIndex];
    [_currentVideo changeThemeWithUUID:object.uuid];
    [self combinaAndPlay];
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) playUrl:_currentVideo.afterEditingPath userFFMPEG:YES];
        _playView.totalTime = _currentVideo.totalTime;
        _playView.showRefresh = YES;
        _playView.separatePoints = _currentVideo.materialPointsArray;
    }
    return _playView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 140 - 64, self.view.bounds.size.width, 140)];
    
    }
    return _contentView;
}

- (UIView *)themeMaskView {
    if (!_themeMaskView) {
        _themeMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 80)];
        _themeMaskView.backgroundColor = RGB(147,211,192);
    }
    return _themeMaskView;
}

- (UIView *)themeView {
    if (!_themeView) {
        _themeView = [[UIView alloc]initWithFrame:self.contentView.bounds];
        
        _themeArray = [ThemeObject allTheme];
        for (int i = 0; i < self.themeArray.count; i++) {
            ThemeObject *object = _themeArray[i];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(30 + i * 90, 0, 60, 80);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = 100 + i;
            UIImage *image = [UIImage imageWithContentsOfFile:[object.savePath stringByAppendingPathComponent:object.cover]];
            [button setImage:image?image:[UIImage imageNamed:@"cover.jpg"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(themeAction:) forControlEvents:UIControlEventTouchUpInside];
            [_themeView addSubview:button];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30 + i * 90, 80, 60, 20)];
            label.text = object.chinaName ? object.chinaName : @"无";
            label.textAlignment = NSTextAlignmentCenter;
            [_themeView addSubview:label];
            
            if (i == self.themeSelectIndex) {
                [button addSubview:self.themeMaskView];
            }
        }
    }
    return _themeView;
}

- (UIView *)musicView {
    if (!_musicView) {
        _musicView = [[UIView alloc]initWithFrame:self.contentView.bounds];
        
        NSArray *array = @[@"背景音乐",@"多段音乐"];
        NSArray *imageArray = @[@"music_flag_green",@"music_flag_green"];
        for (int i = 0; i < 2; i++) {
            UIImage *image = [UIImage imageNamed:imageArray[i]];
            CGFloat width = self.view.bounds.size.width / 2;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * width, 0, width, _musicView.height);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateNormal];
            button.tag = 110 + i;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, (width - 60) / 2, button.height - 65, (width - 60) / 2)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(65, - image.size.width, _musicView.height - 95, 0)];
            [button addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventTouchUpInside];
            [_musicView addSubview:button];
        }
    }
    return _musicView;
}

- (UIView *)function {
    if (!_function) {
        _function = [[UIView alloc]initWithFrame:CGRectMake(0, self.playView.bounds.size.height + 50, self.view.bounds.size.width, 80)];
        
        NSArray *titleArray = @[@"主题",@"音乐",@"编辑",@"字幕",@"贴纸",@"配音"];
        NSArray *imageArray = @[@"message_icon1",@"message_icon1",@"message_icon1",@"message_icon1",@"message_icon1",@"message_icon1"];
        for (int i = 0; i < titleArray.count; i++) {
            UIImage *image = [UIImage imageNamed:imageArray[i]];
            CGFloat width = self.view.bounds.size.width / titleArray.count;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * width, 0, width, _function.height);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateNormal];
            button.tag = 120 + i;
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, (width - 40) / 2, button.height - 45, (width - 40) / 2)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake( 45, - image.size.width, 0, 0)];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
            [_function addSubview:button];
        }
    }
    return _function;
}

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    return _HUD;
}

@end
