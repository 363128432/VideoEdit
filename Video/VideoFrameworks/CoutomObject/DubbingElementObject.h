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

@interface DubbingElementObject : AddElementObject

@property (nonatomic, strong) NSURL *pathUrl;
// 音量，从0到1.0
@property (nonatomic, assign) float volume;


@end
