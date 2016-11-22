//
//  BBStickerView.h
//  XXX
//
//  Created by hjb on 16/11/2.
//  Copyright © 2016年 Guangdong Huanhuan Network Information Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBStickerView.h"
#import "AnimatedStickerObject.h"

typedef NS_ENUM(NSUInteger, StickerViewButtonType) {
    StickerViewButtonTypeWithDelege,
    StickerViewButtonTypeWithReverse,
    StickerViewButtonTypeWithSounds,
};

@class BBStickerView;
@protocol BBStickerViewDelegate <NSObject>

- (void)BBStickerViewDidAnimationFinish:(BBStickerView *)stickerView;
- (void)BBStickerView:(BBStickerView *)stickerView btnType:(StickerViewButtonType)btnType;
- (void)BBStickerViewDidMoveAndRotateFinish:(BBStickerView *)stickerView;

@end

@interface BBStickerView : UIView

//角度
@property (nonatomic, assign) CGFloat     angle;
//放大或缩小比例
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, assign, readonly) CGSize imageOriginalSize;
//是否水平翻转
@property (nonatomic, assign) BOOL        haveTransFlag;
//是否隐藏按钮
@property (nonatomic, assign) BOOL  operaterHidden;

@property (nonatomic, assign) NSTimeInterval animationTime;
@property (nonatomic, assign) NSTimeInterval animationBeginTime;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) AnimatedStickerObject *sticker;
@property (nonatomic, assign) CMTimeRange insetTime;

@property (nonatomic, assign) id<BBStickerViewDelegate> delegate;

- (instancetype)initWithWithFrame:(CGRect)frame AnimatedStickerObject:(AnimatedStickerObject *)sticker animation:(BOOL)animation;

- (void)startImageAnimation;

@end
