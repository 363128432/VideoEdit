//
//  CanEditAsset.m
//  VideoEdit
//
//  Created by 付州  on 16/8/22.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "CanEditAsset.h"
#import "AVURLAsset+Custom.h"
#import "VideoPlayView.h"

@interface CanEditAsset ()

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *lastFilter;
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *vedioWriter;

@end

@implementation CanEditAsset

+ (instancetype)assetWithURL:(NSURL *)URL {
    CanEditAsset *asset = [super assetWithURL:URL];
    if (asset) {
        asset.playTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        asset.saturationVaule = 1.0;
        asset.brightnessVaule = 0;
        asset.contrastVaule = 1.0;
        asset.changeSpeed = 1.0;
    }
    return asset;
}

- (CMTimeRange)playTimeRange {
    if (CMTIMERANGE_IS_INVALID(_playTimeRange)) {
        _playTimeRange = CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    return _playTimeRange;
}


#pragma mark 更换滤镜

- (void)saveFilterVideoPath:(NSURL *)pathUrl filter:(GPUImageOutput<GPUImageInput> *)filter  completion: (void (^ __nullable)(void))completion{
    
    _filter = filter;
    _filterVideoPath = pathUrl;
    
    _movie = [[GPUImageMovie alloc]initWithURL:self.URL];
    _movie.playAtActualSpeed = NO;
    _movie.runBenchmark = YES;
    [_movie addTarget:_filter];
    
    NSLog(@"asset is %@",_movie);


    NSString *pathToMovie = [[self.URL path] stringByReplacingOccurrencesOfString:@".mov" withString:@"-filter.mov"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    _filterVideoPath = [NSURL fileURLWithPath:pathToMovie];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:pathToMovie error:nil];
    
    _vedioWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_filterVideoPath size:self.naturalSize];
    _vedioWriter.encodingLiveVideo = YES;
    _vedioWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
    [_filter addTarget:_vedioWriter];
    
    _vedioWriter.shouldPassthroughAudio = YES;
    _movie.audioEncodingTarget = _vedioWriter;
    [_movie enableSynchronizedEncodingUsingMovieWriter:_vedioWriter];
    
    [_vedioWriter startRecording];
    [_movie startProcessing];
    
    __weak typeof(self) weakself = self;
    [_vedioWriter setCompletionBlock:^{
        NSLog(@"已完成！！！");
        [weakself.filter removeTarget:weakself.vedioWriter];
        [weakself.vedioWriter finishRecording];
        [weakself.movie cancelProcessing];
        completion();
    }];
}


- (GPUImageMovie *)movie {
    if (!_movie) {
        _movie = [[GPUImageMovie alloc]initWithURL:self.URL];
        _movie.playAtActualSpeed = NO;
        _movie.runBenchmark = YES;
        //        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        //        _contrastFilter = [[GPUImageContrastFilter alloc]init];
        //        _saturationFilter = [[GPUImageSaturationFilter alloc]init];
        //        [_movie addTarget:_brightnessFilter];
        //        [_brightnessFilter addTarget:_contrastFilter];
        //        [_contrastFilter addTarget:_saturationFilter];
        //        [_saturationFilter addTarget:self.gpuImageView];
    }
    return _movie;
}


#pragma mark -get

- (UIImage *)thumbnailImage {
    return [self thumbnailImageAtTime:0];
}




@end
