//
//  UIView+Custom.m
//  Video
//
//  Created by 付州  on 16/10/12.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "UIView+Custom.h"

@implementation UIView (Custom)


#pragma mark 设置坐标
- (void)setX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


- (void)removeAllSubViews {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}


@end
