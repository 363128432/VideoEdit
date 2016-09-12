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
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *writer;
@property (nonatomic, strong) GPUImageView *preview;            // 预览视图
@property (nonatomic, strong) NSURL *filterMovieURL;
@property (nonatomic, strong) UIView *videoView;
@end

@implementation VideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    [self.view addSubview:self.playView];
    [self.view addSubview:self.filterSelectView];
//
//    _preview = [[GPUImageView alloc] initWithFrame:self.playView.container.bounds];
//    [self.playView.container addSubview:_preview];
    [self.view addSubview:self.videoView];
    
//    [self.playView setPlayUrl:self.editAsset.URL];
//    [self.playView startPlayer];
}

- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [self.editAsset filterPreviewViewWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    }
    return _videoView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)selectFilter:(UIButton *)button {
    _filter = self.filterArray[button.tag - 300][@"filter"];
    [self.editAsset changeFilterWithFilter:_filter];
//    [self.playView pausePlayer];
    
//    if (_filter) {
//        [self.movie removeAllTargets];
//        [_filter removeAllTargets];
//        [self.movie cancelProcessing];
//    }
//    
//    _filter = self.filterArray[button.tag - 300][@"filter"];
//    
//    
//    [self.movie addTarget:_filter];
//    [_filter addTarget:self.preview];
//    [self.movie startProcessing];
    
//    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:self.filterMovieURL size:self.editAsset.naturalSize];
//    _writer.delegate = self;
//    _writer.encodingLiveVideo = NO;
//    _writer.shouldPassthroughAudio = NO;
//    _movie.audioEncodingTarget = _writer;
//    self.movie.audioEncodingTarget = self.writer;
//    self.movie.playAtActualSpeed = NO;
//    [self.movie addTarget:self.filter];
//    [self.filter addTarget:self.writer];
//    [self.movie enableSynchronizedEncodingUsingMovieWriter:self.writer];
//    [self.writer startRecording];
//    [self.movie startProcessing];
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

- (GPUImageMovie *)movie {
    if (!_movie) {
        _movie = [[GPUImageMovie alloc] initWithURL:self.editAsset.URL];
        _movie.shouldRepeat = NO;           // 控制视频是否循环播放。
        _movie.playAtActualSpeed = YES;     // 控制GPUImageView预览视频时的速度是否要保持真实的速度,设为YES，则会根据视频本身时长计算出每帧的时间间隔，然后每渲染一帧，就sleep一个时间间隔，从而达到正常的播放速度
        _movie.delegate = self;
    }
    return _movie;
}

- (NSURL *)filterMovieURL {
    if (!_filterMovieURL) {
        NSString *filterMovieString = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie_Filter.mov"];
        unlink([filterMovieString UTF8String]);
        _filterMovieURL = [NSURL fileURLWithPath:filterMovieString];
    }
    return _filterMovieURL;
}

//- (GPUImageMovieWriter *)writer {
//    if (!_writer) {
//        
//    }
//    return _writer;
//}

- (void)didCompletePlayingMovie {
    
    NSLog(@"1");
}

- (void)movieRecordingCompleted {
    [self.playView setPlayUrl:self.filterMovieURL];
    [self.playView startPlayer];
}

@end
