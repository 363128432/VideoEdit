//
//  CanEditAsset.h
//  VideoEdit
//
//  Created by 付州  on 16/8/22.
//  Copyright © 2016年 LJ. All rights reserved.
//

// 最小可编辑素材对象，编辑功能进去之后可看见


#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"

typedef NS_ENUM(NSInteger, VideoFilterType) {
    VideoFilterTypeWithNone,
    VideoFilterTypeWithLookup,
    VideoFilterTypeWithAmatorka,
    VideoFilterTypeWithMissEtikate,
    VideoFilterTypeWithSoftElegance,
};

@interface CanEditAsset : AVURLAsset

@property (nonatomic, strong) NSURL *filterVideoPath;           // 编辑后的视频路径

@property (nonatomic, assign) CMTimeRange playTimeRange;             // 剪裁之后播放的时间
@property (nonatomic, assign) float changeSpeed;                // 变速
@property (nonatomic, assign) float angle;                   // 旋转角度

// Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
@property (nonatomic, assign) float saturationVaule;            // 饱和度
// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property (nonatomic, assign) float brightnessVaule;              // 亮度
// Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
@property (nonatomic, assign) float contrastVaule;              // 对比度

@property (nonatomic, assign) VideoFilterType filterType;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;    // 视频滤镜

@property (nonatomic, strong) UIImage *thumbnailImage;          // 缩略图


// 根据时间分割
//- (NSArray<CanEditAsset *> *)componentsSeparatedByTime:(CMTime)time;


- (void)saveFilterVideoPath:(NSURL *)pathUrl filter:(GPUImageOutput<GPUImageInput> *)filter  completion: (void (^ __nullable)(void))completion;


@end
