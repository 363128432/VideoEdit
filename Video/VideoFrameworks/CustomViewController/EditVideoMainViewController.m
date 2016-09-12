//
//  EditVideoMainViewController.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "EditVideoMainViewController.h"
#import "VideoPlayView.h"

@interface EditVideoMainViewController ()

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIView *function;         // 功能视图

@property (nonatomic, strong) UIButton *toPlay;         // 重新播放

@end

@implementation EditVideoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _currentVideo = [VideoObject currentVideo];
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.toPlay];
    [self.view addSubview:self.function];
    
    [self playStartPlay];
    

}

- (IBAction)backAction:(id)sender {
    // 退出视频编辑页面，得将当前编辑常量置空
    [VideoObject attemptDealloc];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playView pausePlayer];
}


- (void)playStartPlay {
    __weak typeof(self) weakself = self;
    [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
        weakself.playView.playUrl = assetURL;
        [weakself.playView startPlayer];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)functionAction:(UIButton *)button {
    switch (button.tag - 120) {
        case 0:{
        }
            break;
        case 1:{
            [self performSegueWithIdentifier:@"SelectMusicTableViewController" sender:nil];
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

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.totalTime = _currentVideo.totalTime;
        _playView.separatePoints = _currentVideo.materialPointsArray;
    }
    return _playView;
}

- (UIButton *)toPlay {
    if (!_toPlay) {
        _toPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        _toPlay.frame = CGRectMake(0, self.playView.bounds.size.height, 80, 30);
        [_toPlay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_toPlay setTitle:@"重新播放" forState:UIControlStateNormal];
        [_toPlay addTarget:self action:@selector(playStartPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toPlay;
}

- (UIView *)function {
    if (!_function) {
        _function = [[UIView alloc]initWithFrame:CGRectMake(0, self.playView.bounds.size.height + 50, self.view.bounds.size.width, 40)];
        
        NSArray *titleArray = @[@"主题",@"音乐",@"编辑",@"字幕",@"贴纸",@"配音",@"转场"];
        for (int i = 0; i < 7; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * self.view.bounds.size.width / 7, 0, self.view.bounds.size.width / 7, 40);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = 120 + i;
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
            [_function addSubview:button];
        }
    }
    return _function;
}




@end
