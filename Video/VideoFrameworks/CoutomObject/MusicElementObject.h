//
//  MusicElementObject.h
//  Video
//
//  Created by 付州  on 16/8/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddElementObject.h"

@interface MusicElementObject : AddElementObject

@property (nonatomic, assign) CMTimeRange playTimeRange;      // 音乐选择播放的时间段

@property (nonatomic, strong) NSURL *pathUrl;               // 音乐播放地址

@end
