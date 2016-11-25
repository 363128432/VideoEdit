//
//  VideoPlayView.h
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoObject.h"
#import "GPUImage.h"

@class VideoPlayView;
@protocol VideoPlayViewDelegate <NSObject>

- (void)videoPlayViewPlayerIsPlay:(VideoPlayView *)playView;
- (void)videoPlayViewPlayerPlayEnd:(VideoPlayView *)playView;
- (void)videoPlayViewPlayerStart:(VideoPlayView *)playView;
- (void)videoPlayViewPlayerPause:(VideoPlayView *)playView;



@end


@interface VideoPlayView : UIView

@property (nonatomic, strong) NSMutableArray<NSURL *> *videoPathArray;  // 播放视频路径地址

@property (nonatomic, strong) UIView *container;            // 播放器容器
@property (nonatomic, strong) UIView *statusView;           // 状态条，显示进度，素材之间分隔的地，播放时间等
@property (nonatomic, assign) BOOL hideStatusView;          // 隐藏状态条

@property (nonatomic, strong) NSURL *playUrl;               // 视频播放地址
@property (nonatomic, assign) CMTime totalTime;             // 视频总时长
@property (nonatomic, assign) CMTime nowTime;               // 当前播放时间
@property (nonatomic, strong) NSArray<NSNumber *> *separatePoints;  // 分隔

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign, readonly) BOOL isPlay;    // 正在播放

@property (nonatomic, assign) BOOL showRefresh;

@property (nonatomic, assign) BOOL isEditModel; // 必须先设置此参数为yes，才会添加调节滤镜的预览视图，才能调节以下参数
@property (nonatomic, assign) CGFloat rate; // 速度
@property (nonatomic, assign) CGFloat angle; // 视频旋转角度
// Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
@property (nonatomic, assign) float saturationVaule;            // 饱和度
// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property (nonatomic, assign) float brightnessVaule;              // 亮度
// Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
@property (nonatomic, assign) float contrastVaule;              // 对比度
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;    // 视频滤镜
@property (nonatomic, assign) VideoFilterType filterType;


@property (nonatomic, assign) id<VideoPlayViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame playUrl:(NSURL *)playUrl;

- (void)toPlay;             // 从最开始播放

- (void)startPlayer;        // 开始播放，暂停后从暂停地方开始播放，和toplay有区别

- (void)pausePlayer;

- (void)startPlayerWithTime:(CMTime)time;

- (void)cancelMovieProcessing;

- (void)startPlayerWithTimeRange:(CMTimeRange)range completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)saveFilterVideoPath:(NSURL *)pathUrl completion: (void (^ __nullable)(void))completion;

@end
