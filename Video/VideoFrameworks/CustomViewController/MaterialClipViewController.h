//
//  MaterialClipViewController.h
//  Video
//
//  Created by 付州  on 16/10/13.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanEditAsset.h"

@interface MaterialClipViewController : UIViewController

@property (nonatomic, assign) NSInteger assetIndex;
@property (nonatomic, strong) CanEditAsset *editAsset;

@property (nonatomic, assign) BOOL isClip;  // 裁剪或分割视频

@end
