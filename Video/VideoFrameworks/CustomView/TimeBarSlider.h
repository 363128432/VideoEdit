//
//  TimeBarSlider.h
//  demo
//
//  Created by 付州  on 16/8/18.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeBarSlider;
@protocol TimeBarSliderDelegate <NSObject>
- (void)VauleChangeTimeBarSlider:(TimeBarSlider *)timeBar;
@end

@interface TimeBarSlider : UIView

@property (nonatomic, strong) NSArray<NSNumber *> *separatePoint;

@property (nonatomic, strong) UIView *thumbView;    // 滑块

@property (nonatomic, assign) id<TimeBarSliderDelegate> delegate;

@property (nonatomic, assign) float maxVaule;    // 最大值，，懒得弄，不设最小值 ，为0

@property (nonatomic, assign) float value;  //

@end
