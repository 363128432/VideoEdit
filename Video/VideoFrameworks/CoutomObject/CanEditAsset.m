//
//  CanEditAsset.m
//  VideoEdit
//
//  Created by 付州  on 16/8/22.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "CanEditAsset.h"

@interface CanEditAsset ()

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *lastFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;   // 饱和
@property (nonatomic, strong) GPUImageExposureFilter *exposureFilter;       // 亮度
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;       // 对比
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *vedioWriter;

@end

@implementation CanEditAsset

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playTimeRange = CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    return self;
}

#pragma mark -set
- (void)setContrastVaule:(float)contrastVaule {
    _contrastVaule = contrastVaule;
    _contrastFilter.contrast = 2 * contrastVaule;
}

- (void)setExposureVaule:(float)exposureVaule {
    _exposureVaule = exposureVaule;
    _exposureFilter.exposure = (exposureVaule - 0.5) * 10;
}

- (void)setSaturationVaule:(float)saturationVaule {
    _saturationVaule = saturationVaule;
    _saturationFilter.saturation = 2 * saturationVaule;
}

#pragma mark -get
- (GPUImageMovie *)movie {
    if (!_movie) {
        _movie = [[GPUImageMovie alloc] initWithURL:self.URL];
        _movie.runBenchmark = YES;
        _movie.audioEncodingTarget = nil;
        _movie.playAtActualSpeed = NO;
    }
    return _movie;
}

- (GPUImageMovieWriter *)vedioWriter {
    if (!_vedioWriter) {
        _vedioWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:@""] size:self.naturalSize];
        _vedioWriter.shouldPassthroughAudio = YES;
    }
    return _vedioWriter;
}

@end
