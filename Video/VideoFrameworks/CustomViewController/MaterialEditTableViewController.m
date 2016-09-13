//
//  MaterialEditTableViewController.m
//  Video
//
//  Created by 付州  on 16/8/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "MaterialEditTableViewController.h"
#import "VideoObject.h"
#import "MaterialEditAddTableViewCell.h"
#import "MaterialEditFunctionTableViewCell.h"
#import "VideoFilterViewController.h"
@interface MaterialEditTableViewController ()

@property (nonatomic, strong) VideoObject *currentVideo;    //

@end

@implementation MaterialEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentVideo = [VideoObject currentVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addMaterialAction:(UIButton *)button {
    
}

- (void)funcitonAction:(UISegmentedControl *)segment {
    NSInteger index = (segment.tag - 1230) / 2;
    switch (segment.selectedSegmentIndex) {
        case 0: {
        }
            break;
        case 1: {
        }
            break;
        case 2: {
            VideoFilterViewController *vc = [[VideoFilterViewController alloc]init];
            vc.editAsset = self.currentVideo.materialVideoArray[index];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3: {
            [self.currentVideo copyMaterialWithIndex:index];
            [self.tableView reloadData];
        }
            break;
        case 4: {
            [self.currentVideo deleteMaterialWithIndex:index];
            [self.tableView reloadData];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentVideo.materialVideoArray.count * 2 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        MaterialEditAddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaterialEditAddTableViewCell" forIndexPath:indexPath];
        cell.addButton.tag = 1230 + indexPath.row;
        [cell.addButton addTarget:self action:@selector(addMaterialAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    }else {
        MaterialEditFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaterialEditFunctionTableViewCell" forIndexPath:indexPath];
        CanEditAsset *editAsset = self.currentVideo.materialVideoArray[indexPath.row / 2];
        cell.timeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",(NSUInteger)CMTimeGetSeconds(editAsset.duration) / 60, (NSUInteger)CMTimeGetSeconds(editAsset.duration) % 60];
        [cell.thumbnail setImage:editAsset.thumbnailImage];
        cell.functionSegment.tag = 1230 + indexPath.row;
        [cell.functionSegment addTarget:self action:@selector(funcitonAction:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row % 2 == 0 ? 44 : 60;
}

@end
