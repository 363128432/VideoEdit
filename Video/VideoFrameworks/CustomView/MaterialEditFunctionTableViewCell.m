//
//  MaterialEditFunctionTableViewCell.m
//  Video
//
//  Created by 付州  on 16/8/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "MaterialEditFunctionTableViewCell.h"

@interface MaterialEditFunctionTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *functionView;

@end

@implementation MaterialEditFunctionTableViewCell


- (void)awakeFromNib {
    // Initialization code
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width - 100, _functionView.bounds.size.height)];
    [_functionView addSubview:view];
    
    NSArray *titleArray = @[@"剪辑",@"分割",@"滤镜",@"复制",@"删除"];
    NSArray *imageArray = @[@"icon_-delete",@"icon_-delete",@"icon_-delete",@"icon_-delete",@"icon_-delete",@"icon_-delete"];
    CGFloat width = view.bounds.size.width / titleArray.count;
    for (int i = 0; i < titleArray.count; i++) {
        UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(i * width, 0, width, view.bounds.size.height)];
        [view addSubview:backview];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((width - 30) / 2, 10, 30, 30)];
        [imageView setImage:[UIImage imageNamed:imageArray[i]]];
        imageView.userInteractionEnabled = YES;
        [backview addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, width, 20)];
        label.text = titleArray[i];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [backview addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = backview.bounds;
        button.tag = 1120 + i;
        [button addTarget:self action:@selector(functionAction:) forControlEvents:UIControlEventTouchUpInside];
        [backview addSubview:button];
    }
    
}

- (void)functionAction:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(materialEditFunctionTableViewCell:didSelectFunctionType:)]) {
        [_delegate materialEditFunctionTableViewCell:self didSelectFunctionType:button.tag - 1120];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
