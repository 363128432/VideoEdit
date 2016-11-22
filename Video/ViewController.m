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
#import "VideoFilterObject.h"


@interface ViewController ()

@property (nonatomic, strong) VideoShootingView *videoView;
@property (nonatomic, strong) AVAudioPlayer *audioplayer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *subFilterView;
@property (weak, nonatomic) IBOutlet UIView *functionView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *makeSure;

@property (nonatomic, strong) NSMutableArray *videoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self reloadViewWithRecordType:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _videoView = [[VideoShootingView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
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

- (void)reloadViewWithRecordType:(BOOL)isRecording {
    self.functionView.hidden = isRecording;
    if (isRecording) {
        self.subFilterView.hidden = isRecording;
    }
    if (!isRecording && self.videoArray.count != 0) {
        self.makeSure.hidden = NO;
    }else {
        self.makeSure.hidden = YES;
    }
}

- (IBAction)showFilterAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.subFilterView.hidden = !sender.selected;
}

- (IBAction)subFilterAction:(UISegmentedControl *)sender {
    self.videoView.subFilter = [[VideoFilterObject filterArray][sender.selectedSegmentIndex] objectForKey:@"filter"];
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
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_%lu.mov",(unsigned long)arc4random()]];
        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        [self.videoView startRecordingWithSavePath:movieURL];

        [self reloadViewWithRecordType:YES];
    }else {
        __weak typeof(self) weakself = self;
        [self.videoView pauseRecordingCompletion:^(NSURL *pathUrl) {
            [weakself.videoArray addObject:pathUrl];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself reloadViewWithRecordType:NO];
            });
        }];
    }
}

// 确认
- (IBAction)determineAction:(id)sender {
    VideoObject *currentVideo = [VideoObject currentVideo];
    for (NSURL *url in self.videoArray) {
        CanEditAsset *editAsset = [CanEditAsset assetWithURL:url];
        [currentVideo.materialVideoArray addObject:editAsset];
    }
    _videoArray = nil;
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"VideoEdit" bundle:nil]instantiateInitialViewController];
    [self presentViewController:nav animated:YES completion:^{
        [self.videoView removeFromSuperview];
        self.videoView = nil;
    }];
    [self reloadViewWithRecordType:NO];

    
//    [self.videoView endRecordingCompletion:^(NSMutableArray<NSURL *> *aseetUrlArray) {
//        
//        dispatch_async(dispatch_get_main_queue(),^(){
//            VideoObject *currentVideo = [VideoObject currentVideo];
//            for (NSURL *url in self.videoArray) {
//                CanEditAsset *editAsset = [CanEditAsset assetWithURL:url];
//                [currentVideo.materialVideoArray addObject:editAsset];
//            }
//            _videoArray = nil;
//            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"VideoEdit" bundle:nil]instantiateInitialViewController];
//            [self presentViewController:nav animated:YES completion:^{
//                [self.videoView removeFromSuperview];
//                self.videoView = nil;
//            }];
//        });
//    }];
}

- (NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _videoArray;
}

#pragma mark
//支持旋转
-(BOOL)shouldAutorotate{
    return !self.videoView.isCamera;
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
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        _videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    }else {
        _videoView.frame = self.view.window.bounds;
    }
    _videoView.orientation = toInterfaceOrientation;
}

@end
