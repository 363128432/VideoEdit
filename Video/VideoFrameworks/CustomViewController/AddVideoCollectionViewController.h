//
//  AddVideoCollectionViewController.h
//  Video
//
//  Created by 付州  on 16/10/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AddVideoCollectionViewCell.h"
#import "AVURLAsset+Custom.h"

@interface AddVideoCollectionViewController : UICollectionViewController

- (void)selectVideoAssetcompletion: (void (^)(NSURL *assetUrl))completion ;

@end
