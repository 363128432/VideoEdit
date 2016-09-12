//
//  SubtitleElementObject.h
//  Video
//
//  Created by 付州  on 16/9/4.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddElementObject.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SubtitleAnimationType) {
    SubtitleAnimationTypeWithNone,
    SubtitleAnimationTypeWithFadeIn,
    SubtitleAnimationTypeWithScrolling,
};

typedef NS_ENUM(NSUInteger, SubtitleAlignmentType) {
    SubtitleAlignmentTypeWithNone,
    SubtitleAlignmentTypeWithLeft,
    SubtitleAlignmentTypeWithRight,
    SubtitleAlignmentTypeWithTop,
    SubtitleAlignmentTypeWithBottom,
    SubtitleAlignmentTypeWithCenter,
};
@interface SubtitleElementObject : AddElementObject

@property (nonatomic, assign) CGRect rect;          // 相对视频位置
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) SubtitleAnimationType animationType;
@property (nonatomic, assign) SubtitleAlignmentType alignmentType;

@end
