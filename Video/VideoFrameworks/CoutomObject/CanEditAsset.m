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



#pragma mark -get

- (UIImage *)thumbnailImage {
    return [self thumbnailImageAtTime:0];
}




@end
