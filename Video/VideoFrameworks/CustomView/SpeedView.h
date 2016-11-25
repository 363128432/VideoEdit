//
//  SpeedView.h
//  Video
//
//  Created by 付州  on 16/10/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeedView;
@protocol SpeedViewDelegate <NSObject>

- (void)speedViewDidChange:(SpeedView *)speedView;

@end


@interface SpeedView : UIView

@property(nonatomic, copy) NSArray *progressLevelArray;
@property(nonatomic, assign) NSInteger currentLevel;
@property(nonatomic, assign) id<SpeedViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame progressArray:(NSArray *)array;

@end
