//
//  TimeBarSlider.m
//  demo
//
//  Created by 付州  on 16/8/18.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "TimeBarSlider.h"

@implementation TimeBarSlider

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, frame.size.height)];
        _thumbView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor greenColor];
        [self addSubview:_thumbView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.backgroundColor = [UIColor greenColor];

    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 1.0);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    
    float currentPoint = 0.0;
    for (NSNumber *number in _separatePoint) {
        currentPoint += [number floatValue];
        CGContextMoveToPoint(context, rect.size.width * currentPoint, 0);
        //设置下一个坐标点
        CGContextAddLineToPoint(context, rect.size.width * currentPoint, rect.size.height);
    }
    CGContextStrokePath(context);
}

- (void)setSeparatePoint:(NSArray<NSNumber *> *)separatePoint {
    _separatePoint = separatePoint;
    [self setNeedsDisplay];
}

- (void)setValue:(float)value {
    _value = value;
    [self setRatio:(value / _maxVaule)];
}

- (void)setRatio:(float)ratio {
    self.thumbView.center = CGPointMake(MIN(MAX(self.bounds.size.width * ratio, self.thumbView.bounds.size.width / 2), self.bounds.size.width - self.thumbView.bounds.size.width / 2) , self.bounds.size.height / 2);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint lastPoint = [[touches anyObject] locationInView:self];
    
    [self setRatio:(lastPoint.x / self.bounds.size.width)];
    _value = (lastPoint.x / self.bounds.size.width) * _maxVaule;
    
    if (_delegate && [_delegate respondsToSelector:@selector(VauleChangeTimeBarSlider:)]) {
        [_delegate VauleChangeTimeBarSlider:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint lastPoint = [[touches anyObject] locationInView:self];
    
    [self setRatio:(lastPoint.x / self.bounds.size.width)];
    _value = (lastPoint.x / self.bounds.size.width) * _maxVaule;
    
    if (_delegate && [_delegate respondsToSelector:@selector(VauleChangeTimeBarSlider:)]) {
        [_delegate VauleChangeTimeBarSlider:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint lastPoint = [[touches anyObject] locationInView:self];
    
    [self setRatio:(lastPoint.x / self.bounds.size.width)];
    _value = (lastPoint.x / self.bounds.size.width) * _maxVaule;
    
    if (_delegate && [_delegate respondsToSelector:@selector(VauleChangeFinishTimeBarSlider:)]) {
        [_delegate VauleChangeFinishTimeBarSlider:self];
    }
}

@end
