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
@property (nonatomic, strong) NSURL *previeweditorUrl;          // 编辑时的合成的预览路径，

@property (nonatomic, assign) CMTimeRange playTimeRange;             // 剪裁之后播放的时间
@property (nonatomic, assign) float changeSpeed;                // 变速
@property (nonatomic, assign) float rotation;                   // 旋转角度

// 三种已设置成都是0到1的范围，0.5是正常
@property (nonatomic, assign) float saturationVaule;            // 饱和度
@property (nonatomic, assign) float exposureVaule;              // 亮度
@property (nonatomic, assign) float contrastVaule;              // 对比度

@property (nonatomic, assign) VideoFilterType filterType;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;    // 视频滤镜

@property (nonatomic, strong) UIImage *thumbnailImage;          // 缩略图


- (NSArray<CanEditAsset *> *)componentsSeparatedByTime:(CMTime)time;


- (void)changeFilterWithFilter:(GPUImageOutput<GPUImageInput> *)otherFilter completion: (void (^ __nullable)(void))completion;


@end
