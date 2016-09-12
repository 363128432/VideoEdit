//
//  MaterialEditFunctionTableViewCell.h
//  Video
//
//  Created by 付州  on 16/8/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaterialEditFunctionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;        // 缩略图
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *functionSegment;

@end
