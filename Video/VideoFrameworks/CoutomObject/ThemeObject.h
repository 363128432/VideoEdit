//
//  ThemeObject.h
//  Video
//
//  Created by 付州  on 16/9/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeObject : NSObject

@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, strong) NSString *replace;
@property (nonatomic, strong) NSString *cover;              // 海报
@property (nonatomic, strong) NSString *name;               // 名字
@property (nonatomic, readonly) NSString *chinaName;        //
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSDictionary *title;          // 片头视频字典
@property (nonatomic, strong) NSDictionary *trailer;        // 片尾视频字典
@property (nonatomic, strong) NSDictionary *translation;        // 翻译
@property (nonatomic, strong) NSDictionary *musicTrack;
@property (nonatomic, strong) NSURL *musicFile;

@property (nonatomic, strong) NSURL *prefaceTrailer;    // 片头地址
@property (nonatomic, strong) NSURL *endTrailer;


+ (NSMutableArray<ThemeObject *> *)allTheme;

+ (ThemeObject *)getThemeWithUUID:(NSString *)uuid;

@end
