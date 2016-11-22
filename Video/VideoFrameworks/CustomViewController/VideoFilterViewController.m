//
//  VideoFilterViewController.m
//  Video
//
//  Created by 付州  on 16/8/31.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoFilterViewController.h"
#import "VideoPlayView.h"
#import "VideoFilterObject.h"
#import "CustomMacros.h"

@interface VideoFilterViewController ()<GPUImageMovieDelegate,GPUImageMovieWriterDelegate>

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIView *filterSelectView; // 选择滤镜视图
@property (nonatomic, strong) UIButton *ensureButton;   // 确定按钮

@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, strong) NSURL *filterVideoPath;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;


@end

@implementation VideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.filterSelectView];
    [self.view addSubview:self.ensureButton];
    
    [self.playView setPlayUrl:self.editAsset.URL];
    [self.playView startPlayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)selectFilter:(UIButton *)button {
    [self.playView pausePlayer];
    _filter = self.filterArray[button.tag - 300][@"filter"];
//    [self.playView setFilter:_filter];
//    [self.playView toPlay];
    
//    [self.playView saveFilterVideoPath:self.filterVideoPath completion: ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.HUD hide:YES];
//            self.editAsset.filterVideoPath = self.filterVideoPath;
////            [self.navigationController popViewControllerAnimated:YES];
//        });
//    }];
    [self.HUD show:YES];
    [self.editAsset saveFilterVideoPath:nil filter:_filter completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
            self.playView.playUrl = self.editAsset.filterVideoPath;
            [self.playView startPlayer];
//            [self.navigationController popViewControllerAnimated:YES];
        });
    }];

}

- (void)makeSureAction {
//    [self.playView pausePlayer];
//    
//    [self.HUD show:YES];
//    
//    [self.playView saveFilterVideoPath:self.filterVideoPath completion: ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.HUD hide:YES];
//            self.editAsset.filterVideoPath = self.filterVideoPath;
            [self.navigationController popViewControllerAnimated:YES];
//        });
//    }];
//    
//    [self.playView cancelMovieProcessing];
//    [self.editAsset saveFilterVideoPath:nil filter:_filter completion:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.HUD hide:YES];
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//    }];
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.totalTime = self.editAsset.duration;
        
    }
    return _playView;
}

- (UIView *)filterSelectView {
    if (!_filterSelectView) {
        _filterSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 50)];
        
        for (int i = 0; i < self.filterArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * self.view.bounds.size.width / self.filterArray.count, 0, self.view.bounds.size.width / self.filterArray.count, 50);
            button.tag = 300 + i;
            [button setTitle:self.filterArray[i][@"filterTitle"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_filterSelectView addSubview:button];
            [button addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _filterSelectView;
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

- (NSArray *)filterArray {
    if (!_filterArray) {
        _filterArray = [VideoFilterObject filterArray];
    }
    return _filterArray;
}

- (NSURL *)filterVideoPath {
    if (!_filterVideoPath) {
        NSString *pathToMovie = [[self.editAsset.URL path] stringByReplacingOccurrencesOfString:@".mov" withString:@"_filter.mov"];
        unlink([pathToMovie UTF8String]);
        _filterVideoPath = [NSURL fileURLWithPath:pathToMovie];
    }
    return _filterVideoPath;
}


@end
