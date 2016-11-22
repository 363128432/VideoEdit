//
//  SubTitleAnimation.m
//  Video
//
//  Created by 付州  on 16/9/18.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "SubTitleAnimation.h"

@implementation SubTitleAnimation


+ (CABasicAnimation *)transformAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.repeatCount = 1; // forever
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnimation.removedOnCompletion = NO;
    
    return rotationAnimation;
}

// 缩入
+ (CABasicAnimation *)narrowIntoAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.3];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    return scaleAnimation;
}

// 移动
+ (CABasicAnimation *)moveAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition {
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    moveAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
    return moveAnimation;
}

// 淡入
+ (CABasicAnimation *)fadeInAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0];
    return scaleAnimation;
}

@end
