//
//  MaterialEditAddTableViewCell.m
//  Video
//
//  Created by 付州  on 16/8/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "MaterialEditAddTableViewCell.h"

@implementation MaterialEditAddTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.addButton.layer.cornerRadius = 10;
    self.addButton.layer.borderColor = [UIColor greenColor].CGColor;
    self.addButton.layer.borderWidth = 1;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
