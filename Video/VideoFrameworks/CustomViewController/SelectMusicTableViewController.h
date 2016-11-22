//
//  AddMusicTableViewController.h
//  Video
//
//  Created by 付州  on 16/8/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicElementObject.h"

@interface SelectMusicTableViewController : UITableViewController

- (void)selectMusicElementcompletion: (void (^)(MusicElementObject *musicElement))completion ;

@end
