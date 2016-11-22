//
//  UIView+Extra.h
//  baseDemo
//
//  Created by 付州  on 15/9/7.
//  Copyright (c) 2015年 FZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extra)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat bottom;

- (void)removeAllSubViews;

- (void)setLayarCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth  borderColor:(UIColor *)borderColor;

@end
