//
//  VideoObject.h
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CanEditAsset.h"

@interface VideoObject : NSObject

@property (nonatomic, strong) AVURLAsset *afterEditingVideo;    // 经过编辑后的视频
@property (nonatomic, strong) NSMutableArray<CanEditAsset *> *materialVideoArray;   // 合成视频的素材组
@property (nonatomic, assign, readonly) CMTime totalTime;                 // 视频总时长

// 添加背景音乐的两个参数
@property (nonatomic, assign) BOOL isAddMusic;                  // 是否添加了音乐
@property (nonatomic, assign) BOOL isBackgroundMusic;           // 添加的是不是背景音乐，
//@property (nonatomic, )           // 当添加的是背景音乐时，背景音乐是哪首歌曲
@property (nonatomic, strong) NSMutableArray *musicArray;       // 多段音乐的集合


+ (instancetype)currentVideo;

// 合并materialVideoArray素材数组里的视频
- (void)combinationOfMaterialVideoCompletionBlock:(void (^)(NSURL *assetURL, NSError *error))completion;


@end
