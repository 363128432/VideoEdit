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
@property (nonatomic, strong) AVAudioPlayer *audioplayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    
//    //1.音频文件的url路径
//    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
//    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
//    //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
//    _audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:Nil];
//    //3.缓冲
//    [_audioplayer prepareToPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _videoView = [[VideoShootingView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_videoView];
    [self.view sendSubviewToBack:_videoView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.videoView removeFromSuperview];
    self.videoView = nil;
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
    //4.播放
//    [_audioplayer play];
}

// 确认
- (IBAction)determineAction:(id)sender {
    [self.videoView endRecordingCompletion:^(NSMutableArray<NSURL *> *aseetUrlArray) {
        VideoObject *currentVideo = [VideoObject currentVideo];
        for (NSURL *url  in aseetUrlArray) {
            CanEditAsset *editAsset = [CanEditAsset assetWithURL:url];
            [currentVideo.materialVideoArray addObject:editAsset];
        }
        
//        EditVideoMainViewController *vc = [[EditVideoMainViewController alloc]init];
        UINavigationController *nav = [[UIStoryboard storyboardWithName:@"VideoEdit" bundle:nil]instantiateInitialViewController];
        
        [self presentViewController:nav animated:YES completion:^{
            [self.videoView removeFromSuperview];
            self.videoView = nil;
        }];
    }];
}

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    return (interfaceOrientation == UIInterfaceOrientationPortrait
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _videoView.frame = self.view.window.bounds;
    _videoView.orientation = toInterfaceOrientation;
}
@end
