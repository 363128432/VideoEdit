//
//  BBStickerView.m
//  XXX
//
//  Created by hjb on 16/11/2.
//  Copyright © 2016年 Guangdong Huanhuan Network Information Technology Co., Ltd. All rights reserved.
//

#import "BBStickerView.h"

#define INSET 10.f

@interface BBStickerView ()
{
    CGSize   _initialSize;
    CGFloat  _initialAngle;
    CGFloat  _initialDistance;
    CGPoint  _beginningPoint;
    CGPoint  _beginningCenter;
    CGPoint  _touchLocation;
    CGRect   _beginBounds;
    CGAffineTransform _startTransform;
}

////贴纸Imgv
//@property (nonatomic, strong) UIImageView *contentImgv;
///删除
@property (nonatomic, strong) UIButton    *deleteBtn;
///旋转放大缩小
@property (nonatomic, strong) UIButton    *rotateBtn;
///静音
@property (nonatomic, strong) UIButton    *voiceBtn;
///翻转
@property (nonatomic, strong) UIButton    *reverseBtn;

@property (nonatomic, strong) CAAnimation *currentAnimation;

@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation BBStickerView


- (instancetype)initWithWithFrame:(CGRect)frame AnimatedStickerObject:(AnimatedStickerObject *)sticker animation:(BOOL)animation{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _animationBeginTime = 0;
        frame.size = CGSizeMake(frame.size.width + 2 * INSET, frame.size.height + 2 * INSET);
        self.frame = frame;
        _customView = [[UIView alloc]initWithFrame:CGRectMake(INSET, INSET, frame.size.width - 2 * INSET, frame.size.height - 2 * INSET)];
        _customView.layer.borderColor = [UIColor whiteColor].CGColor;
        _customView.layer.borderWidth = 1;
        _customView.autoresizesSubviews = YES;
        _customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_customView];
        [self addSubview:self.reverseBtn];
        [self addSubview:self.voiceBtn];
        [self addSubview:self.deleteBtn];
        [self addSubview:self.rotateBtn];
        UIPanGestureRecognizer *movePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePanGesture:)];
        [self addGestureRecognizer:movePan];
        UITapGestureRecognizer *single = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:single];
        
        _coverImageView = [[UIImageView alloc]initWithFrame:_customView.bounds];
        [_coverImageView setImage:[UIImage imageWithContentsOfFile:sticker.coverPath]];
        _coverImageView.autoresizesSubviews = YES;
        _coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_customView addSubview:_coverImageView];
        
        if (sticker.storyboard.track) {
            for (int i = 0; i < sticker.storyboard.track.count; i++) {
                Track *track = sticker.storyboard.track[i];
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:_customView.bounds];
                imageView.layer.opacity = 0;
                imageView.autoresizesSubviews = YES;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [imageView setImage:[UIImage imageWithContentsOfFile:[sticker.savePath stringByAppendingPathComponent:track.source]]];
                [_customView addSubview:imageView];
            }
        }
        
        _sticker = sticker;
        _initialSize = CGSizeMake(_customView.bounds.size.width, _customView.bounds.size.height);
        _initialAngle = atan((_customView.bounds.size.height / 2 + INSET) / (_customView.bounds.size.width / 2 + INSET));
        _ratio = 1;
        _angle = 0;
        _imageOriginalSize = _customView.bounds.size;

        if (animation) {
            [self startImageAnimation];
        }
    }
    return self;
}

- (void)startImageAnimation {
    _coverImageView.hidden = YES;
    if (self.animationTime == 0) {
        self.animationTime = [self.sticker.storyboard.stickerDuration floatValue];
    }
    
    for (int i = 0; i < self.sticker.storyboard.track.count; i++) {
        UIImageView *imageView = self.customView.subviews[i];
        Track *track = self.sticker.storyboard.track[i];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.beginTime = self.animationBeginTime;
        group.duration = self.animationTime;
        group.delegate = self;

        if (track.effect) {
            Animation *animation = track.effect.animation;
            NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:10];
            
            for (int i = 0; i < animation.key.count; i++) {
                Key *key = animation.key[i];
    
                [timeArray addObject:[NSNumber numberWithFloat:[key.time floatValue]]];
                [valueArray addObject:[NSNumber numberWithFloat:[key.value floatValue]]];
            }
            
            
            CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
            keyAnimation.keyPath = animation.paramName;
            keyAnimation.values = valueArray;
            keyAnimation.keyTimes = timeArray;
            keyAnimation.beginTime = [track.clipStart floatValue];
            keyAnimation.duration = [track.clipDuration floatValue];
            if (track.repeat) {
                keyAnimation.repeatCount = MAXFLOAT;
            }
            
            group.animations = @[keyAnimation];
            
            [imageView.layer addAnimation:group forKey:nil];
        }else {
            if (track.repeatInterval) {
            
                CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
                keyAnimation.keyPath = @"opacity";
                keyAnimation.values = @[@(1),@(1),@(0)];
                keyAnimation.keyTimes = @[@([track.clipStart floatValue]),@([track.clipDuration floatValue] - 0.001),@([track.repeatInterval floatValue])];
                keyAnimation.beginTime = [track.clipStart floatValue];
                keyAnimation.duration = [track.repeatInterval floatValue];
                if (track.repeat) {
                    keyAnimation.repeatCount = MAXFLOAT;
                }
                
                group.animations = @[keyAnimation];
                
                [imageView.layer addAnimation:group forKey:nil];
            }else {
                CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacityAnim.fromValue = [NSNumber numberWithFloat:1];
                opacityAnim.toValue = [NSNumber numberWithFloat:1];
                opacityAnim.beginTime = [track.clipStart floatValue];
                opacityAnim.duration = [track.clipDuration floatValue];
                if (track.repeat) {
                    opacityAnim.repeatCount = MAXFLOAT;
                }
                group.animations = @[opacityAnim];
            }
            [imageView.layer addAnimation:group forKey:nil];
        }
    }
}

- (CAKeyframeAnimation *)theTrackHaveEffectWithTrack:(Track *)track {
    Animation *animation = track.effect.animation;
    NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < animation.key.count; i++) {
        Key *key = animation.key[i];
        [timeArray addObject:[NSNumber numberWithFloat:[key.time floatValue] + [track.clipStart floatValue]]];
        [valueArray addObject:[NSNumber numberWithFloat:[key.value floatValue]]];
    }
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
    keyAnimation.keyPath = animation.paramName;
    keyAnimation.values = valueArray;
    keyAnimation.keyTimes = timeArray;
    
    return keyAnimation;
}


#pragma mark animationDelegate 
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _coverImageView.hidden = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(BBStickerViewDidAnimationFinish:)]) {
        [_delegate BBStickerViewDidAnimationFinish:self];
    }
}


#pragma mark 初始化工具栏
#pragma mark ====================
- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.frame.size.width - INSET*2, 0, INSET*2, INSET*2);
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"photograph_icon_shutdown.png"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIButton *)rotateBtn
{
    if (!_rotateBtn) {
        _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotateBtn.frame = CGRectMake(self.frame.size.width - INSET*2, self.frame.size.height - INSET*2, INSET*2, INSET*2);
        [_rotateBtn setBackgroundImage:[UIImage imageNamed:@"photograph_icon_stretch.png"] forState:UIControlStateNormal];
        _rotateBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        UIPanGestureRecognizer *rotate = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(rotateViewPanGesture:)];
        [_rotateBtn addGestureRecognizer:rotate];
    }
    return _rotateBtn;
}

- (UIButton *)reverseBtn
{
    if (!_reverseBtn) {
        _reverseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reverseBtn.frame = CGRectMake(0, 0, INSET*2, INSET*2);
        [_reverseBtn setBackgroundImage:[UIImage imageNamed:@"photograph_icon_stretch.png"] forState:UIControlStateNormal];
        [_reverseBtn addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reverseBtn;
}

- (UIButton *)voiceBtn
{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake(0, self.frame.size.height - INSET*2, INSET*2, INSET*2);
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"photograph_icon_shutdown.png"] forState:UIControlStateNormal];
        [_voiceBtn addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

- (void)dealloc
{
    _delegate = nil;
}

#pragma mark ====================

#pragma mark 点击自己
- (void)singleTap:(UITapGestureRecognizer *)recognizer{
    
    [self setOperaterHidden:YES];
}

#pragma mark 移动手势
//view的移动
- (void)movePanGesture:(UIPanGestureRecognizer *)recognizer{
    if (self.operaterHidden) {
        return;
    }
    
    //选中设置操作按钮显示
    [self setOperaterHidden:NO];
    _touchLocation = [recognizer locationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _beginningPoint = _touchLocation;
        _beginningCenter = self.center;
        [self setCenter:CGPointMake(_beginningCenter.x+(_touchLocation.x-_beginningPoint.x), _beginningCenter.y+(_touchLocation.y-_beginningPoint.y))];
        _beginBounds = self.bounds;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setCenter:CGPointMake(_beginningCenter.x+(_touchLocation.x-_beginningPoint.x), _beginningCenter.y+(_touchLocation.y-_beginningPoint.y))];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setCenter:CGPointMake(_beginningCenter.x+(_touchLocation.x-_beginningPoint.x),_beginningCenter.y+(_touchLocation.y-_beginningPoint.y))];
        
        if (_delegate && [_delegate respondsToSelector:@selector(BBStickerViewDidMoveAndRotateFinish:)]) {
            [_delegate BBStickerViewDidMoveAndRotateFinish:self];
        }
    }
}

#pragma mark 旋转放大缩小
//旋转放大缩小
- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer{
    // 计算本视图父视图上的位置，方便和中心点坐标计算
    _touchLocation = [recognizer locationInView:self.superview.superview];
    // 使用计算两点间距离计算对角线长度，计算出比例
    self.ratio = [self distanceFromPointX:_touchLocation distanceToPointY:self.center] / [self distanceFromPointX:CGPointZero distanceToPointY:CGPointMake(_initialSize.width / 2, _initialSize.height / 2)];
    
    
    // 对角线角度，原始对角线角度在数学坐标系第4象限，即右下角
    CGFloat diagonalAngle = 0.0;
    if (_touchLocation.x > self.center.x && _touchLocation.y > self.center.y) {
        diagonalAngle = atan(fabs((_touchLocation.y - self.center.y) / (_touchLocation.x - self.center.x)));
        self.angle = diagonalAngle - _initialAngle;
    }else if (_touchLocation.x < self.center.x && _touchLocation.y > self.center.y) {
        diagonalAngle = atan(fabs((_touchLocation.x - self.center.x) / (_touchLocation.y - self.center.y)));
        self.angle = diagonalAngle + (M_PI_2 - _initialAngle);
    }else if (_touchLocation.x < self.center.x && _touchLocation.y < self.center.y) {
        diagonalAngle = atan(fabs((_touchLocation.x - self.center.x) / (_touchLocation.y - self.center.y)));
        self.angle = - (diagonalAngle + _initialAngle + M_PI_2);
    }else if (_touchLocation.x > self.center.x && _touchLocation.y < self.center.y) {
        diagonalAngle = atan(fabs((_touchLocation.y - self.center.y) / (_touchLocation.x - self.center.x)));
        self.angle = - (diagonalAngle + _initialAngle);
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(BBStickerViewDidMoveAndRotateFinish:)]) {
            [_delegate BBStickerViewDidMoveAndRotateFinish:self];
        }
    }
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setTransform:CGAffineTransformMakeRotation(angle)];
    [self setNeedsDisplay];
}

- (void)setRatio:(CGFloat)ratio {
    _ratio = ratio;
    self.bounds = CGRectMake(0, 0, _initialSize.width * ratio + 2 * INSET, _initialSize.height * ratio  + 2 * INSET);
    _customView.frame = CGRectMake(INSET, INSET, _initialSize.width * ratio, _initialSize.height * ratio);
    _reverseBtn.frame = CGRectMake(0, 0, INSET*2, INSET*2);
    _deleteBtn.frame = CGRectMake(self.bounds.size.width - INSET*2, 0, INSET*2, INSET*2);
    _rotateBtn.frame = CGRectMake(self.bounds.size.width - INSET*2, self.bounds.size.height - INSET*2, INSET*2, INSET*2);
    _voiceBtn.frame = CGRectMake(0, self.bounds.size.height - INSET*2, INSET*2, INSET*2);
    
}

// 计算两点间距离
-(float)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    float distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

/**
 *  显示隐藏贴纸按钮边框
 *  @param hidden  Yes 隐藏
 */
- (void)setOperaterHidden:(BOOL)hidden
{
    self.customView.layer.borderColor = hidden?[UIColor clearColor].CGColor:[UIColor whiteColor].CGColor;
    self.customView.layer.borderWidth = hidden?0:1;
    self.deleteBtn.hidden = hidden;
    self.rotateBtn.hidden = hidden;
    self.reverseBtn.hidden = hidden;
    self.voiceBtn.hidden = hidden;
    [self setNeedsDisplay];
}

#pragma mark 按钮事件
- (void)toolBtnClick:(UIButton *)btn
{
    NSInteger btnType = 0;
    if (btn == _deleteBtn) {
//        [self removeFromSuperview];
        btnType = StickerViewButtonTypeWithDelege;
    }else if (btn == _reverseBtn){
        if (!_haveTransFlag) {
            self.customView.transform = CGAffineTransformMakeScale(-1, 1);
            _haveTransFlag = YES;
        }else{
            self.customView.transform = CGAffineTransformMakeScale(1, 1);
            _haveTransFlag = NO;
        }
        btnType = StickerViewButtonTypeWithReverse;
    }else if (btn == _voiceBtn){
        btnType = StickerViewButtonTypeWithSounds;
    }
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(BBStickerView:btnType:)]) {
        [_delegate BBStickerView:self btnType:btnType];
    }
}


@end
