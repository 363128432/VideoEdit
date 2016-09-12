//
//  AddMusicTableViewController.m
//  Video
//
//  Created by 付州  on 16/8/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "SelectMusicTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoObject.h"

@interface SelectMusicTableViewController ()

@property (nonatomic, strong) NSMutableArray<NSURL *> *musicArray;

@end

@implementation SelectMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectMusicTableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = @"台北不是伤心地";
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoObject *object = [VideoObject currentVideo];
    object.backgroundMusic = [AVURLAsset assetWithURL:self.musicArray[indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSMutableArray<NSURL *> *)musicArray {
    if (!_musicArray) {
        _musicArray = [NSMutableArray arrayWithCapacity:10];
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
        NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
        [_musicArray addObject:audioUrl];
    }
    return _musicArray;
}

@end
