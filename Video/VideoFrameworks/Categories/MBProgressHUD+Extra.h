//
//  MBProgressHUD+Extra.h
//  GaH4Parents
//
//  Created by sagles on 15/5/12.
//  Copyright (c) 2015年 SA. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Extra)

+ (UIWindow *)window;

+ (void)showWindowWithText:(NSString *)text;

+ (void)showHUDInView:(UIView *)view text:(NSString *)text;

+ (void)showHUDInView:(UIView *)view text:(NSString *)text complate:(void(^)(void))complate;

@end
