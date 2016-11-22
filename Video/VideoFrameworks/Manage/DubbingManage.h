//
//  DubbingManage.h
//  Video
//
//  Created by 付州  on 16/9/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DubbingElementObject.h"

@class DubbingManage;
@protocol DubbingManageDelegate <NSObject>

- (void)dubbingElementWithTimeChange:(DubbingElementObject *)dubbingObject;

@end

@interface DubbingManage : NSObject

@property (nonatomic, assign) id<DubbingManageDelegate> delegate;

// 从某一时刻开始录音
- (void)startRecordingWithStartTime:(NSTimeInterval)time;
// 结束录音，自动计算出insertTime
- (DubbingElementObject *)stopRecord;

@end
