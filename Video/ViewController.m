//
//  ViewController.m
//  VideoEdit
//
//  Created by 付州  on 16/8/14.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "ViewController.h"
#import "VideoShootingView.h"
#import "EditVideoMainViewController.h"
#import "VideoObject.h"

@interface ViewController ()

@property (nonatomic, strong) VideoShootingView *videoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _videoView = [[VideoShootingView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_videoView];
    [self.view sendSubviewToBack:_videoView];
    
    //    [view startRecording];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)subFilterAction:(id)sender {
    self.videoView.subFilterType = ((UISegmentedControl *)sender).selectedSegmentIndex;
}
- (IBAction)mainFilterAction:(id)sender {
    self.videoView.mainFilterType = ((UISegmentedControl *)sender).selectedSegmentIndex;
}
- (IBAction)torchAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    self.videoView.TorchModeOn = button.isSelected;
}
- (IBAction)cameraAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    self.videoView.position = button.isSelected;
}

// 开始、暂停录制
- (IBAction)recordingAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [self.videoView startRecording];
    }else {
        [self.videoView pauseRecording];
    }
}

// 确认
- (IBAction)determineAction:(id)sender {
    [self.videoView endRecordingCompletion:^(NSMutableArray<NSURL *> *aseetUrlArray) {
        VideoObject *currentVideo = [VideoObject currentVideo];
        for (NSURL *url  in aseetUrlArray) {
            CanEditAsset *editAsset = [CanEditAsset assetWithURL:url];
            [currentVideo.materialVideoArray addObject:editAsset];
        }
        
        EditVideoMainViewController *vc = [[EditVideoMainViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        
        [self presentViewController:nav animated:YES completion:^{
            [self.videoView removeFromSuperview];
            self.videoView = nil;
        }];
    }];
}

@end
