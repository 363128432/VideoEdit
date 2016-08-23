//
//  AddContent.h
//  VideoEdit
//
//  Created by 付州  on 16/8/14.
//  Copyright © 2016年 LJ. All rights reserved.
//

// 视频要添加的类，如：文字，贴纸都继承自这类

#import <Foundation/Foundation.h>

@interface AddContent : NSObject

@property (nonatomic, assign) float startTime;      // 添加内容的开始时间
@property (nonatomic, assign) float endTime;        // 添加内容的结束时间

@end
