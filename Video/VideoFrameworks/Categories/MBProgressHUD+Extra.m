//
//  MBProgressHUD+Extra.m
//  GaH4Parents
//
//  Created by sagles on 15/5/12.
//  Copyright (c) 2015年 SA. All rights reserved.
//

#import "MBProgressHUD+Extra.h"

@implementation MBProgressHUD (Extra)

+ (UIWindow *)window {
    return [[UIApplication sharedApplication].delegate window] ;
}

+ (void)showWindowWithText:(NSString *)text {
    UIWindow *window = [[UIApplication sharedApplication].delegate window] ;
    [MBProgressHUD showHUDInView:window text:text];
}

+ (void)showHUDInView:(UIView *)view text:(NSString *)text {
    [self showHUDInView:view text:text complate:nil];
}

+ (void)showHUDInView:(UIView *)view text:(NSString *)text complate:(void (^)(void))complate {
    if (!view) {
        return;
    }
    
    [MBProgressHUD hideAllHUDsForView:view animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 100.0, 0);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.f], NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    UILabel *custom = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    custom.numberOfLines = 0;
    custom.font = [UIFont systemFontOfSize:15.f];
    custom.text = text;
    custom.textColor = [UIColor whiteColor];
    custom.textAlignment = NSTextAlignmentCenter;
    custom.backgroundColor = [UIColor clearColor];
    hud.completionBlock = ^() {
        if (complate) {
            complate();
        }
    };
    
    hud.customView = custom;
    
    [hud hide:YES afterDelay:2.f];
}

@end
