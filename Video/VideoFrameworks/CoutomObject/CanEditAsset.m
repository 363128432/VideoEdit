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
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;   // 饱和
@property (nonatomic, strong) GPUImageExposureFilter *exposureFilter;       // 亮度
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;       // 对比
@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageMovieWriter *vedioWriter;
@property (nonatomic, strong) VideoPlayView *playView;
@property (nonatomic, strong) GPUImageView *preview;

@end

@implementation CanEditAsset

+ (instancetype)assetWithURL:(NSURL *)URL {
    CanEditAsset *asset = [super assetWithURL:URL];
    if (asset) {
        asset.playTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    }
    return asset;
}

- (CMTimeRange)playTimeRange {
    if (&_playTimeRange == NULL) {
        _playTimeRange = CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    return _playTimeRange;
}


#pragma mark 更换滤镜
- (UIView *)filterPreviewViewWithFrame:(CGRect)rect {
    _playView = [[VideoPlayView alloc]initWithFrame:rect];
    [_playView setPlayUrl:self.URL];
    
    _preview = [[GPUImageView alloc]initWithFrame:_playView.container.bounds];
    _preview.backgroundColor = [UIColor blackColor];
    [_playView addSubview:_preview];
    
    return _playView ;
}

- (void)startPlayPreview {
    
}

- (void)changeFilterWithFilter:(GPUImageOutput<GPUImageInput> *)otherFilter {
    [self.movie removeAllTargets];
    [_filter removeAllTargets];
    [self.movie cancelProcessing];
    self.movie = nil;

    _filter = otherFilter;
    
    [self.movie addTarget:_filter];
    [_filter addTarget:self.preview];
    [self.movie startProcessing];
    
    [self startPlayPreview];
    [self.playView toPlay];
}

- (void)identifyAndSaveCurrentFilter {
    
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
        _movie.audioEncodingTarget = nil;
        _movie.playAtActualSpeed = YES;
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

- (UIImage *)thumbnailImage {
    return [self thumbnailImageAtTime:0];
}




@end
