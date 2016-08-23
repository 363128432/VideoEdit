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

@interface VideoPlayView : UIView

@property (nonatomic, strong) NSMutableArray<NSURL *> *videoPathArray;  // 播放视频路径地址

@property (nonatomic, strong) UIView *container;            // 播放器容器
@property (nonatomic, strong) UIView *statusView;           // 状态条，显示进度，素材之间分隔的地，播放时间等
@property (nonatomic, assign) BOOL hideStatusView;          // 隐藏状态条

@property (nonatomic, strong) NSURL *playUrl;               // 视频播放地址
@property (nonatomic, assign) CMTime totalTime;             // 视频总时长
@property (nonatomic, strong) NSArray<NSNumber *> *separatePoints;  // 分隔


- (void)startPlayer;

- (void)pausePlayer;

@end
