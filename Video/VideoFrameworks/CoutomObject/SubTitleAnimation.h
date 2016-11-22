//
//  SubTitleAnimation.h
//  Video
//
//  Created by 付州  on 16/9/18.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface SubTitleAnimation : NSObject

+ (CABasicAnimation *)transformAnimation;

// 缩入
+ (CABasicAnimation *)narrowIntoAnimation;

+ (CABasicAnimation *)fadeInAnimation;

// 移动
+ (CABasicAnimation *)moveAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition;

@end
