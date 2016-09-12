//
//  AVURLAsset+Custom.h
//  Video
//
//  Created by 付州  on 16/8/30.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVURLAsset (Custom)

- (UIImage*) thumbnailImageAtTime:(NSTimeInterval)time;

@end
