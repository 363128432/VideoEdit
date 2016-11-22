//
//  PasterView.m
//  XTPasterManager
//
//  Created by 付州  on 16/9/1.
//  Copyright © 2016年 teason. All rights reserved.
//

#import "SubtitlesView.h"

@interface SubtitlesView ()
{
    CGPoint prevPoint;
    CGFloat prevWidth;
    CGPoint touchStart;
    CGRect  bgRect ;
}

@property (nonatomic,strong) UIImageView    *btDelete ;         // 删除按钮
@property (nonatomic,strong) UIImageView    *btSizeCtrl ;       // 缩放按钮

@end

@implementation SubtitlesView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _title = title;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] ;
        [self addGestureRecognizer:tapGesture] ;
        
        self.userInteractionEnabled = YES ;
        
        [self addSubview:self.contentView];
        [self addSubview:self.textLabel];
        [self addSubview:self.btDelete];
        [self addSubview:self.btSizeCtrl];
        
        _titleFontName = _textLabel.font.fontName;
        _textColor = [UIColor whiteColor];
        self.fontSize = 20;
    }
    return self;
}

- (void)setHideBorder:(BOOL)hideBorder {
    self.contentView.hidden = hideBorder;
    self.btDelete.hidden = hideBorder;
    self.btSizeCtrl.hidden = hideBorder;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    
    self.textLabel.font = [UIFont fontWithName:self.titleFontName size:_fontSize];
    self.contentView.frame = CGRectMake(BT_SIZE / 2, BT_SIZE / 2, BT_SIZE + _title.length * _fontSize, _fontSize + BT_SIZE);
    self.textLabel.frame = CGRectMake(BT_SIZE, BT_SIZE, _title.length * _fontSize, _fontSize);
    self.bounds = CGRectMake(0, 0, self.contentView.frame.size.width + BT_SIZE, self.contentView.frame.size.height + BT_SIZE);
    self.btSizeCtrl.frame = CGRectMake(self.bounds.size.width - BT_SIZE ,
                                       self.bounds.size.height - BT_SIZE ,
                                       BT_SIZE,
                                       BT_SIZE);
}

- (void)setTitleFontName:(NSString *)titleFontName {
    _titleFontName = titleFontName;
    
    self.textLabel.font = [UIFont fontWithName:titleFontName size:self.fontSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLabel.textColor = textColor;
}

- (CABasicAnimation *)addAnimationWithType:(SubtitleAnimationType)animationType {
    CABasicAnimation *rotationAnimation;
    switch (animationType) {
        case 0:
            rotationAnimation = [CABasicAnimation animation];
            break;
        case 1:
            rotationAnimation = [SubTitleAnimation moveAnimationWithFromPosition:CGPointMake(self.layer.position.x + 100, self.layer.position.y) toPosition:self.layer.position];
            break;
        case 2:
            rotationAnimation = [SubTitleAnimation moveAnimationWithFromPosition:CGPointMake(self.layer.position.x, self.layer.position.y + 50) toPosition:self.layer.position];
            break;
        case 3:
            rotationAnimation = [SubTitleAnimation narrowIntoAnimation];
            break;
        case 4:
            rotationAnimation = [SubTitleAnimation fadeInAnimation];
            break;
        case 5:
            rotationAnimation = [SubTitleAnimation transformAnimation];
            break;
            
        default:
            break;
    }
    return rotationAnimation;
}

- (void)tap:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"tap paster become first respond") ;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject] ;
    touchStart = [touch locationInView:self.superview] ;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.btSizeCtrl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    
    CGPoint newCenter = CGPointMake(self.center.x + touch.x - touchStart.x,
                                    self.center.y + touch.y - touchStart.y) ;

    self.center = newCenter;
    
    touchStart = touch;
}

- (void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:self];
        
//        self.contentView.frame = CGRectMake(BT_SIZE / 2, BT_SIZE / 2, self.contentView.bounds.size.width + point.x - prevPoint.x, self.bounds.size.height);
        self.fontSize = (self.contentView.bounds.size.width + point.x - prevPoint.x - BT_SIZE) / self.title.length;
        
        NSLog(@"%@  %@   %f",NSStringFromCGPoint(prevPoint),NSStringFromCGPoint(point),point.x - prevPoint.x);
        
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay] ;
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }

}


- (UIView *)contentView
{
    if (!_contentView)
    {
        CGRect rect = CGRectZero ;
        rect.origin = CGPointMake(BT_SIZE / 2, BT_SIZE / 2) ;
        rect.size = CGSizeMake(self.bounds.size.width - BT_SIZE, self.bounds.size.height - BT_SIZE) ;
        
        _contentView = [[UIView alloc] initWithFrame:rect] ;
//        _contentView.backgroundColor = [UIColor greenColor] ;
        _contentView.layer.borderColor = [UIColor whiteColor].CGColor ;
        _contentView.layer.borderWidth = BORDER_LINE_WIDTH ;
        
    }
    return _contentView ;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(BT_SIZE / 2, BT_SIZE / 2, self.bounds.size.width - 2 * BT_SIZE, self.bounds.size.height - 2 * BT_SIZE)];
        _textLabel.text = self.title;
//        _textLabel.backgroundColor = [UIColor redColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.contentMode = UIViewContentModeScaleAspectFit ;
    }
    return _textLabel;
}

- (UIImageView *)btSizeCtrl
{
    if (!_btSizeCtrl)
    {
        _btSizeCtrl = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - BT_SIZE,
                                                                   self.bounds.size.height - BT_SIZE,
                                                                   BT_SIZE ,
                                                                   BT_SIZE)
                       ] ;
        _btSizeCtrl.userInteractionEnabled = YES;
        _btSizeCtrl.image = [UIImage imageNamed:@"bt_paster_transform"] ;
        
        UIPanGestureRecognizer *panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(resizeTranslate:)] ;
        [_btSizeCtrl addGestureRecognizer:panResizeGesture] ;

    }
    
    return _btSizeCtrl ;
}

- (UIImageView *)btDelete
{
    if (!_btDelete)
    {
        CGRect btRect = CGRectZero ;
        btRect.size = CGSizeMake(BT_SIZE, BT_SIZE) ;
        
        _btDelete = [[UIImageView alloc]initWithFrame:btRect] ;
        _btDelete.userInteractionEnabled = YES;
        _btDelete.image = [UIImage imageNamed:@"bt_paster_delete"] ;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(btDeletePressed:)] ;
        [_btDelete addGestureRecognizer:tap] ;
    }
    
    return _btDelete ;
}

- (void)btDeletePressed:(id)btDel
{
    [_delegate deleteView];
    [self removeFromSuperview] ;
}

@end
