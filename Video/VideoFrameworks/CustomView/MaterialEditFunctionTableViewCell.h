//
//  MaterialEditFunctionTableViewCell.h
//  Video
//
//  Created by 付州  on 16/8/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MaterialEditFunctionTableViewCell ;
@protocol MaterialEditFunctionTableViewCellDelegate <NSObject>

- (void)materialEditFunctionTableViewCell:(MaterialEditFunctionTableViewCell *)cell didSelectFunctionType:(NSInteger)type;

@end

@interface MaterialEditFunctionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;        // 缩略图
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, assign) id<MaterialEditFunctionTableViewCellDelegate> delegate;

@end
