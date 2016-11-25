//
//  VideoShootingView.m
//  VideoEdit
//
//  Created by 付州  on 16/8/14.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoShootingView.h"
#import "VideoObject.h"

@interface VideoShootingView ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageOutput <GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageView *preview;                // 预览视图

@property (nonatomic, strong) NSDictionary *audioSettings;          // 录制中音频设置
@property (nonatomic, strong) NSMutableDictionary *videoSettings;   // 录制中视频设置
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;     // 视频写入

@property (nonatomic, strong) NSURL *currentUrl;

@property (nonatomic, strong) NSMutableArray *videoArray;           // 视频数组

@end

@implementation VideoShootingView

#pragma mark property

- (void)setOrientation:(UIInterfaceOrientation)orientation {
    self.videoCamera.outputImageOrientation = orientation;

    self.preview.frame = self.frame;
}

- (NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [[NSMutableArray alloc]initWithCapacity:3];
    }
    return _videoArray;
}

- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [_videoCamera addAudioInputsAndOutputs];
    }
    return _videoCamera;
}

- (NSDictionary *)audioSettings {
    if (!_audioSettings) {
        AudioChannelLayout channelLayout;
        memset(&channelLayout, 0, sizeof(AudioChannelLayout));
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        
        _audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                       [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
                                       [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                                       [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                                       [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,
                                       nil];
    }
    return _audioSettings;
}

- (NSMutableDictionary *)videoSettings {
    if (!_videoSettings) {
        _videoSettings = [[NSMutableDictionary alloc] init];;
        [_videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
        [_videoSettings setObject:[NSNumber numberWithInteger:200] forKey:AVVideoWidthKey];
        [_videoSettings setObject:[NSNumber numberWithInteger:200] forKey:AVVideoHeightKey];
    }
    return _videoSettings;
}

- (void)setMainFilter:(GPUImageFilter *)mainFilter {
    _mainFilter = mainFilter;
    [self reloadFilter];
}

- (void)setSubFilter:(GPUImageFilter *)subFilter {
    _subFilter = subFilter;
    [self reloadFilter];
}

- (void)setMainFilterType:(MainFilterType)mainFilterType {
    _mainFilterType = mainFilterType;
    switch (_mainFilterType) {
        case MainFilterTypeWithNone: {
            self.mainFilter = [[GPUImageFilter alloc]init];
            break;
        }
        case MainFilterTypeWithBulgeDistortion: {
            self.mainFilter = [[GPUImageBulgeDistortionFilter alloc]init];
//            ((GPUImageBulgeDistortionFilter *)_mainFilter).radius = self.frame.size.height;
            break;
        }
        case MainFilterTypeWithBeautify: {
            self.mainFilter = [[GPUImageBilateralFilter alloc]init];
            break;
        }
    }
}

- (void)setPosition:(CameraManagerDevicePosition)position {
    _position = position;
    switch (_position) {
        case CameraManagerDevicePositionBack: {
            if (self.videoCamera.cameraPosition != AVCaptureDevicePositionBack) {
                [self.videoCamera pauseCameraCapture];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self.videoCamera rotateCamera];
                    [self.videoCamera resumeCameraCapture];
                });
            }
        }
            break;
        case CameraManagerDevicePositionFront: {
            if (self.videoCamera.cameraPosition != AVCaptureDevicePositionFront) {
                [self.videoCamera pauseCameraCapture];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self.videoCamera rotateCamera];
                    [self.videoCamera resumeCameraCapture];
                });
            }
        }
            break;
        default:
            break;
    }
}

- (void)setTorchModeOn:(BOOL)TorchModeOn {
    _TorchModeOn = TorchModeOn;
    if (TorchModeOn) {
        [self.videoCamera.inputCamera lockForConfiguration:nil];
        [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self.videoCamera.inputCamera unlockForConfiguration];
    }else {
        [self.videoCamera.inputCamera lockForConfiguration:nil];
        [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
        [self.videoCamera.inputCamera unlockForConfiguration];
    }
}

#pragma mark Method
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _preview = [[GPUImageView alloc] initWithFrame:self.frame];
        _preview.fillMode = kGPUImageFillModeStretch;
        [self addSubview:_preview];
        [self sendSubviewToBack:_preview];
        self.autoresizesSubviews = NO;
        // 添加滤镜
        [self.videoCamera addTarget:_preview];
        [self.videoCamera startCameraCapture];
    }
    return self;
}

- (void)startRecording {
    //然后是初始化文件路径和视频写入对象
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie%lu.mov",(unsigned long)self.videoArray.count]];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    [self.videoArray addObject:movieURL];
    
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:self.bounds.size];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    if (_filter) {
        [_filter addTarget:_movieWriter];
    }else {
        [_videoCamera addTarget:_movieWriter];
    }
    self.videoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
    
    _isCamera = YES;
}

- (void)startRecordingWithSavePath:(NSURL *)pathUrl {
    _currentUrl = pathUrl;
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:pathUrl size:self.bounds.size];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    if (_filter) {
        [_filter addTarget:_movieWriter];
    }else {
        [_videoCamera addTarget:_movieWriter];
    }
    self.videoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
    
    _isCamera = YES;
}

- (void)pauseRecordingCompletion:(void (^)(NSURL *pathUrl))completion {
    _isCamera = NO;
    
    [_movieWriter finishRecordingWithCompletionHandler:^{
        completion(_currentUrl);
    }];
}

- (void)pauseRecording {
    _isCamera = NO;
    [_movieWriter finishRecording];
    _movieWriter = nil;
}

- (void)endRecordingCompletion:(void (^)(NSMutableArray<NSURL *> *))completion {
    _isCamera = NO;

    completion(self.videoArray);
}


- (void)reloadFilter {
    // 移除所有滤镜
    [_videoCamera removeAllTargets];
    [_mainFilter removeAllTargets];
    [_subFilter removeAllTargets];
    
    // 判断是否需要挨个处理滤镜
    if (_mainFilter) {
        [_videoCamera addTarget:_mainFilter];
        if (_subFilter) {
            [_mainFilter addTarget:_subFilter];
            [_subFilter addTarget:_preview];
            _filter = _subFilter;
        }else {
            [_mainFilter addTarget:_preview];
            _filter = _mainFilter;
        }
    }else {
        if (_subFilter) {
            [_videoCamera addTarget:_subFilter];
            [_subFilter addTarget:_preview];
            _filter = _subFilter;
        }else {
            [_videoCamera addTarget:_preview];
            _filter = nil;
        }
    }
    
    [_videoCamera startCameraCapture];
}




@end
