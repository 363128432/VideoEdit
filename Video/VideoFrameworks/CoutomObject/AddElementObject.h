//
//  AddElementObject.h
//  Video
//
//  Created by 付州  on 16/8/26.
//  Copyright © 2016年 LJ. All rights reserved.
//

// 视频添加的元素对象，如音乐，字幕，贴纸，配音都继承自这

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AddElementObject : NSObject

// 插入视频的时间段，，录音类不能自己设置
@property (nonatomic, assign) CMTimeRange insertTime;

@end
