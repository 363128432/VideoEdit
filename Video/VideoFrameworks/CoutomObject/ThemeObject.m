//
//  ThemeObject.m
//  Video
//
//  Created by 付州  on 16/9/29.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "ThemeObject.h"
#import "YYModel.h"

@implementation ThemeObject

+ (NSMutableArray<ThemeObject *> *)allTheme {
    NSMutableArray *themeArray = [NSMutableArray arrayWithObject:[[ThemeObject alloc]init]];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *themePath =  [documentsDirectory stringByAppendingPathComponent:
                            @"theme"];
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    NSArray *fileList = [myFileManager contentsOfDirectoryAtPath:themePath error:nil];
    
    [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[obj substringToIndex:1] isEqualToString:@"."]) {
            NSString *path = [themePath stringByAppendingPathComponent:obj];
            
            NSData *fileData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"theme.json"]];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];//此处data参数是我上面提到的key为"data"的数组
            
            ThemeObject *object = [ThemeObject yy_modelWithDictionary:jsonDic[@"theme"]];
            object.savePath = path;
            
//            if ([object.uuid isEqualToString:@"7FE423C8CA844F7E8DFF47744DF8D8A7"] || []) {
                [themeArray addObject:object];
//                *stop = YES;
//            }
        }
    }];
    
    return themeArray;
}

+ (ThemeObject *)getThemeWithUUID:(NSString *)uuid {
    ThemeObject *object = [[ThemeObject alloc]init];
    
    for (ThemeObject *obj in [ThemeObject allTheme]) {
        if ([obj.uuid isEqualToString:uuid]) {
            object = obj;
            break;
        }
    }
    return object;
}

- (NSURL *)prefaceTrailer {
    if (!_prefaceTrailer) {
        NSString *file = [self.title objectForKey:@"file"];
        if (file) {
            _prefaceTrailer = [[NSURL alloc] initFileURLWithPath:[self.savePath stringByAppendingPathComponent:file]];
        }else {
            return nil;
        }
    }
    return _prefaceTrailer;
}

- (NSURL *)musicFile {
    if (!_musicFile) {
        NSString *file = [[self.musicTrack objectForKey:@"music"]objectForKey:@"file"];
        if (file) {
            _musicFile = [[NSURL alloc] initFileURLWithPath:[self.savePath stringByAppendingPathComponent:file]];
        }else {
            return nil;
        }
    }
    return _musicFile;
}

- (NSURL *)endTrailer {
    if (!_endTrailer) {
        NSString *file = [self.title objectForKey:@"file"];
        if (file) {
            _endTrailer = [[NSURL alloc] initFileURLWithPath:[self.savePath stringByAppendingPathComponent:file]];
        }else {
            return nil;
        }
    }
    return _endTrailer;
}

- (NSString *)chinaName {
    return [[[self.translation objectForKey:@"entry"]firstObject] objectForKey:@"targetText"];
}

@end
