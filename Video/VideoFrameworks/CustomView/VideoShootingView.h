//
//  VideoShootingView.h
//  VideoEdit
//
//  Created by 付州  on 16/8/14.
//  Copyright © 2016年 LJ. All rights reserved.
//

// 视频拍摄类

#import <Foundation/Foundation.h>
#import "GPUImage.h"

typedef NS_ENUM(NSInteger, MainFilterType) {
    MainFilterTypeWithNone,                         // slow at beginning and end
    MainFilterTypeWithBulgeDistortion,              // 鱼眼
    MainFilterTypeWithBeautify,                     // 美肤模式
    MainFilterTypeWith
};

typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
    CameraManagerDevicePositionBack,
    CameraManagerDevicePositionFront,
};


@interface VideoShootingView : UIView

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *mainFilter;       // 主要的滤镜
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *subFilter;        // 次要的滤镜
@property (nonatomic, assign) MainFilterType mainFilterType;    // 给定几个主要滤镜，不喜欢，可以用mainFilter自定义

@property (nonatomic, assign) CameraManagerDevicePosition position;        // 是否为前置摄像头
@property (nonatomic, assign) BOOL focusing;        // 是否自动聚焦(默认为yes)
@property (nonatomic, assign) BOOL TorchModeOn;     // 是否打开闪光灯
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign, readonly) BOOL isCamera;        // 正在拍摄


- (void)startRecording;
- (void)pauseRecording;
- (void)endRecordingCompletion:(void (^)(NSMutableArray<NSURL *> *aseetUrlArray))completion;

- (void)startRecordingWithSavePath:(NSURL *)pathUrl;
- (void)pauseRecordingCompletion:(void (^)(NSURL *pathUrl))completion;

@end
