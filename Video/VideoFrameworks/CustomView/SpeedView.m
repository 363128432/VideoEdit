//
//  SpeedView.m
//  Video
//
//  Created by 付州  on 16/10/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "SpeedView.h"

#define NODEWIDTH 20
#define LINEHEIGHT 2

@implementation SpeedView

- (instancetype)initWithFrame:(CGRect)frame progressArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        _progressLevelArray = array;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, (NODEWIDTH - LINEHEIGHT) / 2, frame.size.width, LINEHEIGHT)];
        line.backgroundColor = [UIColor blackColor];
        [self addSubview:line];
        
        CGFloat interval = (frame.size.width - array.count * NODEWIDTH) / (array.count - 1);
        for (int i = 0; i < array.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * (NODEWIDTH + interval), 0, NODEWIDTH, NODEWIDTH);
            [button setBackgroundImage:[UIImage imageNamed:@"graph_point_annotation"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateSelected];
            button.tag = 6543 + i;
            [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, interval, 20)];
            label.center = CGPointMake(button.center.x, button.center.y + 20);
            label.text = array[i];
            label.font =[UIFont systemFontOfSize:13];
            label.textColor = [UIColor blackColor];
            [self addSubview:label];
        }
        
        UIPanGestureRecognizer  *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(handlePanGestures:)];
        //无论最大还是最小都只允许一个手指
        panGestureRecognizer.minimumNumberOfTouches = 1;
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)action:(UIButton *)sender  {
    [self currentIndex:sender.tag - 6543];
}

- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    if (paramSender.state != UIGestureRecognizerStateFailed){
        //通过使用 locationInView 这个方法,来获取到手势的坐标
        CGPoint location = [paramSender locationInView:paramSender.view];
        CGFloat x = MAX(location.x, 0);   x = MIN(x, self.bounds.size.width);
        NSInteger index = x / (self.bounds.size.width / ((self.progressLevelArray.count - 1) * 2));
        [self currentIndex:(index + 1) / 2];
    }
}

- (void)currentIndex:(NSInteger)index {
    if (_currentLevel == index) {
        return;
    }
    
    _currentLevel = index;
    
    for (int i = 0; i < self.progressLevelArray.count; i++) {
        UIButton *selectButton = (UIButton *)[self viewWithTag:6543 + i];
        if (index == i) {
            selectButton.selected = YES;
        }else {
            selectButton.selected = NO;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(speedViewDidChange:)]) {
        [_delegate speedViewDidChange:self];
    }
}

@end
