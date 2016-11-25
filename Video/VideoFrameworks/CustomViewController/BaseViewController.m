//
//  BaseViewController.m
//  Video
//
//  Created by 付州  on 16/11/13.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    return _HUD;
}

@end
