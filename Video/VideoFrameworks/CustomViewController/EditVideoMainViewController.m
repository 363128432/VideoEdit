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

@property (nonatomic, strong) VideoPlayView *playView;

@end

@implementation EditVideoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playView];
    
    [self playStartPlay];
}

//- (void)setOriginalVideoArray:(NSMutableArray<NSURL *> *)originalVideoArray {
//    
//    _currentVideo = [[VideoObject alloc]init];
//    // 将原始的视频数据转换成videoObject里
//    for (NSURL *url in originalVideoArray) {
//        CanEditAsset *editAsset = [CanEditAsset assetWithURL:url];
//        [_currentVideo.materialVideoArray addObject:editAsset];
//    }
//    self.playView.currentVideo = _currentVideo ;
//}

- (void)playStartPlay {
    _currentVideo = [VideoObject currentVideo];
    
    __weak typeof(self) weakself = self;
    [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
        weakself.playView.totalTime = _currentVideo.totalTime;
        weakself.playView.playUrl = assetURL;
        
        NSMutableArray *pointArray = [NSMutableArray arrayWithCapacity:10];
        for (AVAsset *asset in _currentVideo.materialVideoArray) {
            NSNumber *number = [NSNumber numberWithFloat:CMTimeGetSeconds(asset.duration) / CMTimeGetSeconds(weakself.playView.totalTime)];
            [pointArray addObject:number];
        }
        weakself.playView.separatePoints = pointArray;
        [weakself.playView startPlayer];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    }
    return _playView;
}


@end
