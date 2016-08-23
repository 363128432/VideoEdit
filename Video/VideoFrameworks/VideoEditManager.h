//
//  VideoEditManager.h
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoEditManager : NSObject

// 合并多个视频，videos可传pathString,pathUrl,AVURLAsset
+ (void)mergeMultipleVideos:(NSArray *)videos completionBlock:(void (^)(AVURLAsset *assetURL, NSError *error))completion;

@end
