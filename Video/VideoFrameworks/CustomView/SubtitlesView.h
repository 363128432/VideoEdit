//
//  PasterView.h
//  XTPasterManager
//
//  Created by 付州  on 16/9/1.
//  Copyright © 2016年 teason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubtitleElementObject.h"
#import "SubTitleAnimation.h"

#define PASTER_SLIDE        150.0
#define BT_SIZE             20.0        // 按钮直径大小
#define BORDER_LINE_WIDTH   1.0
#define SECURITY_LENGTH     75.0

@protocol SubtitlesViewDelegate <NSObject>

- (void)deleteView;

@end

@interface SubtitlesView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) SubtitleAnimationType animationType;

@property (nonatomic, assign) CMTimeRange insertTime;       // 插入视频的时间段

@property (nonatomic, strong) UIView *contentView ;         // 内容视图
@property (nonatomic, strong) UILabel *textLabel;            // 文字

@property (nonatomic, assign) BOOL hideBorder;              // 隐藏边框，只显示中间文字

@property (nonatomic, assign) id<SubtitlesViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

- (CABasicAnimation *)addAnimationWithType:(SubtitleAnimationType)animationType;

@end
