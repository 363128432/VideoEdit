//
//  PasterView.h
//  XTPasterManager
//
//  Created by 付州  on 16/9/1.
//  Copyright © 2016年 teason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubtitlesView : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIView *contentView ;         // 内容视图
@property (nonatomic, strong) UILabel *textLabel;            // 文字

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
