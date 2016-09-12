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

@interface AddDubbingViewController ()

@property (nonatomic, strong) DubbingElementObject *dubbing;

@property (nonatomic, strong) VideoPlayView *playView;  // 播放视图
@property (nonatomic, strong) VideoObject *currentVideo;    //

@end

@implementation AddDubbingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _currentVideo = [VideoObject currentVideo];
    
    [self.view addSubview:self.playView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDubbingAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [self.dubbing startRecordingWithStartTime:kCMTimeZero];
    }else {
        [self.dubbing stopRecord];
        
        [self.currentVideo.dubbingArray addObject:self.dubbing];
    }
}


- (IBAction)playAction:(id)sender {
    __weak typeof(self) weakself = self;
    [_currentVideo combinationOfMaterialVideoCompletionBlock:^(NSURL *assetURL, NSError *error) {
        weakself.playView.playUrl = assetURL;
        [weakself.playView startPlayer];
    }];
}

- (DubbingElementObject *)dubbing {
    if (!_dubbing) {
        _dubbing = [[DubbingElementObject alloc]init];
    }
    return _dubbing;
}

- (VideoPlayView *)playView {
    if (!_playView) {
        _playView = [[VideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        _playView.totalTime = _currentVideo.totalTime;
        _playView.separatePoints = _currentVideo.materialPointsArray;
    }
    return _playView;
}

@end
