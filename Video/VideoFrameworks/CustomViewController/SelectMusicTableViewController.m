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
#import "DoubleSlider.h"


@interface SelectMusicTableViewController ()
{
    //two labels to show the currently selected values
    UILabel *leftLabel;
    UILabel *rightLabel;
}

@property (nonatomic, strong) NSMutableArray<NSURL *> *musicPathArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIView *suspensionView;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) DoubleSlider *slider;
@property (nonatomic, copy) void (^ block)(MusicElementObject *musicElement);

@property (nonatomic, retain) AVAudioPlayer *player;


@end

@implementation SelectMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"无音乐" style:UIBarButtonItemStyleDone target:self action:@selector(noMusicAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    [self.player pause];
}

- (void)noMusicAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider
{
    leftLabel.text = [self timeWithSecond: slider.minSelectedValue];
    rightLabel.text = [self timeWithSecond:slider.maxSelectedValue];
}

- (void)selectMusicElementcompletion: (void (^)(MusicElementObject *musicElement))completion {
    _block = completion ;
}


- (void)userElementAction {
    MusicElementObject *object = [[MusicElementObject alloc]init];
    object.pathUrl = self.musicPathArray[self.tableView.indexPathForSelectedRow.row];
    object.playTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(self.slider.minSelectedValue, 600), CMTimeMakeWithSeconds(self.slider.maxSelectedValue - self.slider.minSelectedValue, 600));
    _block(object);
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)valueChangedEnd:(DoubleSlider *)slider {
    _player.currentTime = slider.minSelectedValue;
    [_player play];
}

// 如果超出时间，重头开始播放
- (void)updateTime {
    if (_player.currentTime > self.slider.maxSelectedValue || _player.currentTime < self.slider.minSelectedValue) {
        _player.currentTime = self.slider.minSelectedValue;
        [_player play];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {    
    _suspensionView.frame = CGRectMake(0, self.view.bounds.size.height - _suspensionView.bounds.size.height + scrollView.contentOffset.y, self.view.bounds.size.width, _suspensionView.bounds.size.height);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicPathArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectMusicTableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    VideoObject *object = [VideoObject currentVideo];
//    object.backgroundMusic = [AVURLAsset assetWithURL:self.musicArray[indexPath.row]];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicPathArray[indexPath.row] error:nil];
    //     设置循环次数，-1为一直循环
    _player.numberOfLoops = -1;
    //     准备播放
    [_player play];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    if (!self.suspensionView.superview) {
        [self.view addSubview:self.suspensionView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.suspensionView removeFromSuperview];
    self.suspensionView = nil;
}

- (NSMutableArray<NSURL *> *)musicPathArray {
    if (!_musicPathArray) {
        _musicPathArray = [NSMutableArray arrayWithCapacity:10];
        
        _titleArray = @[@"台北不是伤心地",@"音乐1",@"音乐2"];
        NSArray *pathArray = @[@"123",@"music0",@"music1"];
        for (int i = 0; i < 3; i++) {
            NSURL *url;
            if (i == 0) {
                url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"]];
            }else {
                url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:pathArray[i] ofType:@"m4a"]];
            }
            [_musicPathArray addObject:url];
        }
    }
    return _musicPathArray;
}

- (UIView *)suspensionView {
    if (!_suspensionView) {
        _suspensionView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 70 - 64, self.view.bounds.size.width, 70)];
        _suspensionView.backgroundColor = [UIColor redColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 40, 30);
        [button setTitle:@"使用" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(userElementAction) forControlEvents:UIControlEventTouchUpInside];
        [_suspensionView addSubview:button];
        
        NSInteger time = _player.duration;
        _slider = [[DoubleSlider alloc]initWithFrame:CGRectMake(30, 30, self.view.bounds.size.width - 60, 20) minValue:0 maxValue:time barHeight:20];
        [_slider addTarget:self action:@selector(valueChangedForDoubleSlider:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(valueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_slider moveSlidersToPosition:@(0) rightSlider:@(time) animated:NO];
        _slider.tag = 1234; //for testing purposes only
        [_suspensionView addSubview:_slider];
        
        leftLabel = [[UILabel alloc] initWithFrame:CGRectOffset(_slider.frame, 0, 20)];
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.text = [self timeWithSecond:0];
        leftLabel.backgroundColor = [UIColor clearColor];
        [_suspensionView addSubview:leftLabel];
        
        rightLabel = [[UILabel alloc] initWithFrame:CGRectOffset(_slider.frame, 0, 20)];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.text = [self timeWithSecond:_player.duration];
        rightLabel.backgroundColor = [UIColor clearColor];
        [_suspensionView addSubview:rightLabel];

    }
    return _suspensionView;
}

- (NSString *)timeWithSecond:(NSTimeInterval)timeInterval {
    return [NSString stringWithFormat:@"%ld:%ld",(NSInteger)timeInterval/60,(NSInteger)timeInterval%60];
}



@end
