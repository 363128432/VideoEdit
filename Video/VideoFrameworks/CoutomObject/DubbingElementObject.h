//
//  MusicElementObject.h
//  Video
//
//  Created by 付州  on 16/8/26.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddElementObject.h"

// 配音类
@class DubbingElementObject;
@protocol DubbingElementObjectDelegate <NSObject>

- (void)dubbingElementWithTimeChange:(DubbingElementObject *)dubbingObject;

@end



@interface DubbingElementObject : AddElementObject

@property (nonatomic, strong) NSURL *pathUrl;
// 音量，从0到1.0
@property (nonatomic, assign) float volume;

// 从某一时刻开始录音
- (void)startRecordingWithStartTime:(CMTime)time;
// 结束录音，自动计算出insertTime
- (void)stopRecord;

@end
