//
//  StickerElementObject.h
//  Video
//
//  Created by 付州  on 16/11/7.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddElementObject.h"
#import "AnimatedStickerObject.h"
#import "BBStickerView.h"

@interface StickerElementObject : AddElementObject

@property (nonatomic, strong) AnimatedStickerObject *animatedSticker;

@property (nonatomic, strong) BBStickerView *stickerView;

@end
