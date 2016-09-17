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

@interface VideoFilterViewController ()<GPUImageMovieDelegate,GPUImageMovieWriterDelegate>

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) UIView *filterSelectView; // 选择滤镜视图
@property (nonatomic, strong) NSArray *filterArray;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@end

@implementation VideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.filterSelectView];
    
    [self.playView setPlayUrl:self.editAsset.URL];
    [self.playView startPlayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)selectFilter:(UIButton *)button {
    _filter = self.filterArray[button.tag - 300][@"filter"];
    [self.editAsset changeFilterWithFilter:_filter completion:^{
        [self.playView setPlayUrl:self.editAsset.filterVideoPath];
        [self.playView startPlayer];
    }];
    
    

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
        _filterSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 150, self.view.bounds.size.width, 50)];
        
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

- (NSArray *)filterArray {
    if (!_filterArray) {
        _filterArray = [VideoFilterObject filterArray];
    }
    return _filterArray;
}



@end
