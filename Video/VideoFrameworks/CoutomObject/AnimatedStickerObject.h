//
//  AnimatedStickerObject.h
//  Video
//
//  Created by 付州  on 16/11/2.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYModel.h"
#import "AddElementObject.h"

@class qwertyu,Trackgroup,Effect,Param,Track,Effect,Animation,Key,Storyboard;
@interface AnimatedStickerObject : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *savePath;   //内容路径
@property (nonatomic, strong) NSString *comment;    //内容
@property (nonatomic, strong) NSString *coverPath;      //封面路径
@property (nonatomic, strong) NSString *previewPath;    //预览视频路径
@property (nonatomic, strong) Storyboard *storyboard;


+ (NSMutableArray<AnimatedStickerObject *> *)allAnimatedSticker;

+ (instancetype)getStickerWithUUID:(NSString *)uuid;

@end


@interface Storyboard : NSObject

@property (nonatomic, strong) NSString *sceneWidth;
@property (nonatomic, copy) NSString *stickerCenterX;
@property (nonatomic, copy) NSString *sceneHeight;
@property (nonatomic, strong) NSArray<Trackgroup *> *trackGroup;
@property (nonatomic, strong) NSArray<Track *> *track;
@property (nonatomic, copy) NSString *stickerCenterY;
@property (nonatomic, copy) NSString *stickerDuration;
@property (nonatomic, copy) NSString *stickerHeight;
@property (nonatomic, copy) NSString *stickerPosterTimeHint;
@property (nonatomic, copy) NSString *stickerWidth;
@property (nonatomic, assign) double widthRatio;
@property (nonatomic, assign) double heightRatio;

@end


@interface Trackgroup : NSObject

@property (nonatomic, strong) NSArray<Track *> *track;

@property (nonatomic, strong) Effect *effect;

@end

@interface Effect : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSArray<Param *> *param;

@property (nonatomic, strong) Animation *animation;

@end

@interface Param : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *value;

@end

@interface Track : NSObject

@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *height;

@property (nonatomic, copy) NSString *clipStart;

@property (nonatomic, copy) NSString *repeat;

@property (nonatomic, strong) Effect *effect;

@property (nonatomic, copy) NSString *width;

@property (nonatomic, copy) NSString *clipDuration;

@property (nonatomic, strong) NSString *repeatInterval;

@end


@interface Animation : NSObject

@property (nonatomic, strong) NSArray<Key *> *key;

@property (nonatomic, copy) NSString *paramName;

@end

@interface Key : NSObject

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *time;

@end

