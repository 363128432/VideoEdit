//
//  UIView+Custom.h
//  Video
//
//  Created by 付州  on 16/10/12.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Custom)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat bottom;

- (void)removeAllSubViews;

@end
