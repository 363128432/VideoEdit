//
//  AnimatedStickerObject.m
//  Video
//
//  Created by 付州  on 16/11/2.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AnimatedStickerObject.h"
#import "YYModel.h"

@implementation AnimatedStickerObject


+ (NSMutableArray<AnimatedStickerObject *> *)allAnimatedSticker {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *stickerPath =  [documentsDirectory stringByAppendingPathComponent:
                            @"animatedsticker"];
    
    NSData *fileData = [NSData dataWithContentsOfFile:[stickerPath stringByAppendingPathComponent:@"order.json"]];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];
    NSMutableArray *allArray = [NSMutableArray arrayWithCapacity:12];
    for (int i = 0; i < jsonArray.count; i++) {
        AnimatedStickerObject *object = [[AnimatedStickerObject alloc]init];
        object.uuid = [jsonArray[i] objectForKey:@"id"];
        object.comment = [jsonArray[i] objectForKey:@"comment"];
        object.savePath = [stickerPath stringByAppendingPathComponent:object.uuid];
        
        NSData *infoData = [NSData dataWithContentsOfFile:[object.savePath stringByAppendingPathComponent:@"info.json"]];
        NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:infoData options:kNilOptions error:nil];
        object.coverPath = [object.savePath stringByAppendingPathComponent:infoDic[@"cover"]];
        object.previewPath = [object.savePath stringByAppendingPathComponent:infoDic[@"preview"]];
        
        NSData *storyboardData = [NSData dataWithContentsOfFile:[object.savePath stringByAppendingPathComponent:@"sticker.json"]];
        NSDictionary *storyboardDic = [NSJSONSerialization JSONObjectWithData:storyboardData options:kNilOptions error:nil];
        object.storyboard = [Storyboard yy_modelWithDictionary:storyboardDic[@"storyboard"]];
        [allArray addObject:object];
    }
    
    return allArray;
}

+ (instancetype)getStickerWithUUID:(NSString *)uuid {
    AnimatedStickerObject *object = [[AnimatedStickerObject alloc]init];
    
    for (AnimatedStickerObject *obj in [AnimatedStickerObject allAnimatedSticker]) {
        if ([obj.uuid isEqualToString:uuid]) {
            object = obj;
            break;
        }
    }
    
    return object;
}



- (Storyboard *)storyboard {
    if ([_storyboard isKindOfClass:[NSDictionary class]]) {
        _storyboard = [Storyboard yy_modelWithDictionary:(NSDictionary *)_storyboard];
        return _storyboard;
    }
    return _storyboard;
}

@end


@implementation Storyboard

- (double)widthRatio {
    return [self.stickerWidth doubleValue] / [self.sceneWidth doubleValue];
}

- (double)heightRatio {
    return [self.stickerHeight doubleValue] / [self.sceneHeight doubleValue];
}


- (NSString *)stickerDuration {
    return [NSString stringWithFormat:@"%.03f",[_stickerDuration floatValue] / 1000];
}

- (NSArray<Trackgroup *> *)trackGroup {
    if (_trackGroup.count > 0) {
        if ([_trackGroup[0] isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:_trackGroup.count];
            for (NSDictionary *dic in _trackGroup) {
                [array addObject:[Trackgroup yy_modelWithDictionary:dic]];
            }
            _trackGroup = array;
        }
    }
    return _trackGroup;
}

- (NSArray<Track *> *)track {
    if (_track.count > 0) {
        if ([_track[0] isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:_track.count];
            for (NSDictionary *dic in _track) {
                [array addObject:[Track yy_modelWithDictionary:dic]];
            }
            _track = array;
        }
    }
    return _track;
}

@end




@implementation Trackgroup

+ (NSDictionary *)objectClassInArray{
    return @{@"track" : [Track class]};
}

@end


@implementation Effect

+ (NSDictionary *)objectClassInArray{
    return @{@"param" : [Param class]};
}

- (Animation *)animation {
    if ([_animation isKindOfClass:[NSDictionary class]]) {
        _animation = [Animation yy_modelWithDictionary:(NSDictionary *)_animation];
        return _animation;
    }
    return _animation;
}

@end


@implementation Param

@end


@implementation Track

- (NSString *)clipStart {
    return [NSString stringWithFormat:@"%.03f",[_clipStart floatValue] / 1000];
}

- (NSString *)clipDuration {
    return [NSString stringWithFormat:@"%.03f",[_clipDuration floatValue] / 1000];
}

- (NSString *)repeatInterval {
    if (!_repeatInterval) {
        return nil;
    }
    return [NSString stringWithFormat:@"%.03f",[_repeatInterval floatValue] / 1000];
}

- (Effect *)effect {
    if ([_effect isKindOfClass:[NSDictionary class]]) {
        _effect = [Effect yy_modelWithDictionary:(NSDictionary *)_effect];
        return _effect;
    }
    return _effect;
}

@end


@implementation Animation

+ (NSDictionary *)objectClassInArray{
    return @{@"key" : [Key class]};
}

- (NSArray<Key *> *)key {
    if (_key.count > 0) {
        if ([_key[0] isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:_key.count];
            for (NSDictionary *dic in _key) {
                [array addObject:[Key yy_modelWithDictionary:dic]];
            }
            _key = array;
        }
    }
    return _key;
}

@end


@implementation Key

- (NSString *)time {
    return [NSString stringWithFormat:@"%.03f",[_time floatValue] / 1000];
}

@end


