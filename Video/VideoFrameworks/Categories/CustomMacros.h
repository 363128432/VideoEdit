//
//  CustomMacros.h
//  baseDemo
//
//  Created by MAC on 15-5-7.
//  Copyright (c) 2015年 FZ. All rights reserved.
//

// 用来定义一些宏定义
#ifndef baseDemo_CustomMacros_h
#define baseDemo_CustomMacros_h

// debug模式下打印
#if DEBUG
#define DebugLog(format, args...) \
NSLog(@"[%s, %d]: " format "\n",  strrchr(__FILE__, '/') + 1, __LINE__, ## args);;
#else
#define DebugLog(format, args...) do {} while(0)
#endif

// 版本信息
#define APPVersionId      [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleVersion"]          // 版本ID
#define APPVersionNumber  [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"]    // 版本号

// 屏幕尺寸
#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH_RATIO SCREEN_WIDTH/320.0

// 颜色设置
#define RGB(A,B,C) [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]
#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 设备系统版本
#define DEVICE_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define IS_IPHONE4 ([UIScreen mainScreen].bounds.size.height == 480)

// 判断是否为IOS7系统
#define SystemVersion [[[UIDevice currentDevice] systemVersion] doubleValue]
#define IOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
#define IOS8 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)



#endif
