//
//  VideoObject.h
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CanEditAsset.h"
#import "MusicElementObject.h"
#import "DubbingElementObject.h"
#import "SubtitleElementObject.h"

@interface VideoObject : NSObject

@property (nonatomic, strong) NSURL *afterEditingPath;    // 经过编辑后的视频
@property (nonatomic, strong) NSMutableArray<CanEditAsset *> *materialVideoArray;   // 合成视频的素材组
@property (nonatomic, assign, readonly) CMTime totalTime;                 // 视频总时长
@property (nonatomic, strong) NSMutableArray<NSNumber *> *materialPointsArray;        // 素材所占时间比例

// 两者只取一个，如果是选择多段音乐，一定要将背景音乐置nil，因为这里是将背景音乐做为多段音乐的特例在处理
@property (nonatomic, strong) NSMutableArray<MusicElementObject *> *musicArray;       // 多段音乐的集合
@property (nonatomic, strong) AVURLAsset *backgroundMusic;                            // 背景音乐
@property (nonatomic, assign) float musicVolume;                                      // 音乐音量

// 配音相关数据
@property (nonatomic, strong) NSMutableArray<DubbingElementObject *> *dubbingArray;     // 配音数组
@property (nonatomic, assign) float dubbingVolume;                                      // 配音音量

// 字幕相关数据
@property (nonatomic, strong) NSMutableArray<SubtitleElementObject *> *subtitleArray;   // 字幕数组


// 我这是只是方便将正在编辑的视频做为单例，其实也可以不用，只是push到单个编辑页面时，传递这个类就行
+ (instancetype)currentVideo;
+ (void)attemptDealloc;     // 销毁单例

// 合并materialVideoArray素材数组里的视频
- (void)combinationOfMaterialVideoCompletionBlock:(void (^)(NSURL *assetURL, NSError *error))completion;


@end
