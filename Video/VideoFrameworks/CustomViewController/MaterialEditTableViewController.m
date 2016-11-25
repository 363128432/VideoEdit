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
#import "MaterialClipViewController.h"
#import "AddVideoCollectionViewController.h"
#import "MaterialEditFunctionTableViewCell.h"
#import "MaterialCutDownViewController.h"

@interface MaterialEditTableViewController ()<MaterialEditFunctionTableViewCellDelegate>

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
    [self performSegueWithIdentifier:@"AddVideoCollectionViewController" sender:[NSNumber numberWithInteger:button.tag - 1230]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[AddVideoCollectionViewController class]]) {
        AddVideoCollectionViewController *vc = [segue destinationViewController];
        [vc selectVideoAssetcompletion:^(NSURL *assetUrl) {
            CanEditAsset *asset = [CanEditAsset assetWithURL:assetUrl];
            [self.currentVideo insertMaterialObject:asset atIndex:((NSNumber *)sender).integerValue / 2];
            [self.tableView reloadData];
        }];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)funcitonAction:(UISegmentedControl *)segment {
    NSInteger index = (segment.tag - 1230) / 2;
    switch (segment.selectedSegmentIndex) {
        case 0: {
            MaterialClipViewController *vc = [[MaterialClipViewController alloc]init];
            vc.editAsset = self.currentVideo.materialVideoArray[index];
            vc.isClip = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            MaterialClipViewController *vc = [[MaterialClipViewController alloc]init];
            vc.editAsset = self.currentVideo.materialVideoArray[index];
            vc.isClip = NO;
            vc.assetIndex = index;
            [self.navigationController pushViewController:vc animated:YES];
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
        cell.timeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu",(NSUInteger)CMTimeGetSeconds(editAsset.playTimeRange.duration) / 60, (NSUInteger)CMTimeGetSeconds(editAsset.playTimeRange.duration) % 60];
        [cell.thumbnail setImage:editAsset.thumbnailImage];
//        cell.functionSegment.tag = 1230 + indexPath.row;
//        [cell.functionSegment addTarget:self action:@selector(funcitonAction:) forControlEvents:UIControlEventValueChanged];
        cell.delegate = self;
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row % 2 == 0 ? 44 : 60;
}

- (void)materialEditFunctionTableViewCell:(MaterialEditFunctionTableViewCell *)cell didSelectFunctionType:(NSInteger)type {
    NSInteger index = [self.tableView indexPathForCell:cell].row / 2;
    
    switch (type) {
        case 0: {
            MaterialCutDownViewController *vc = [[MaterialCutDownViewController alloc]init];
            vc.editAsset = self.currentVideo.materialVideoArray[index];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            MaterialClipViewController *vc = [[MaterialClipViewController alloc]init];
            vc.editAsset = self.currentVideo.materialVideoArray[index];
            vc.isClip = NO;
            vc.assetIndex = index;
            [self.navigationController pushViewController:vc animated:YES];
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

@end
