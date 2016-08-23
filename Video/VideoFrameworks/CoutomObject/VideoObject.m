//
//  VideoObject.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoObject.h"

@implementation VideoObject

+ (instancetype)currentVideo {
    static VideoObject *currentVideo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentVideo = [[self alloc]init];
    });
    return currentVideo;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        range
    }
    return self;
}

- (void)combinationOfMaterialVideoCompletionBlock:(void (^)(NSURL *, NSError *))completion {
    // 2.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    
    CMTime time = kCMTimeZero;  // 循环的下一视频要插入的时间
    CGSize videoSize;
    NSMutableArray *instructionArray = [NSMutableArray arrayWithCapacity:self.materialVideoArray.count];
    NSMutableArray *audioParameterArray = [NSMutableArray arrayWithCapacity:self.materialVideoArray.count];
    for (id video in self.materialVideoArray) {
        // 获取到AVURLAsset
        AVURLAsset *videoAssset;
        if ([video isKindOfClass:[NSString class]]) {
            videoAssset = [AVURLAsset assetWithURL:[NSURL URLWithString:video]];
        }else if ([video isKindOfClass:[NSURL class]]) {
            videoAssset = [AVURLAsset assetWithURL:video];
        }else if ([video isKindOfClass:[AVAsset class]]) {
            videoAssset = video;
        }
        
        videoSize = videoAssset.naturalSize;
        NSLog(@"%f  %f",videoSize.height,videoSize.width);
        
        // 存视频
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssset.duration)
                            ofTrack:[[videoAssset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:time
                              error:nil];
        // 视频架构层，用来规定video样式，比如合并两个视频，怎么放，是转90度还是边放边旋转
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        [layerInstruction setTransform:CGAffineTransformIdentity atTime:kCMTimeZero];
        [instructionArray insertObject:layerInstruction atIndex:0];
        
        
        // 存音频
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssset.duration)
                            ofTrack:[[videoAssset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:time
                              error:nil];
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
        [audioInputParams setVolumeRampFromStartVolume:1.0 toEndVolume:1.0f timeRange:CMTimeRangeMake(time, videoAssset.duration)];
        [audioInputParams setTrackID:audioTrack.trackID];
        [audioParameterArray insertObject:audioInputParams atIndex:0];
        
        
        time = CMTimeAdd(time, videoAssset.duration);
    }
    
    // 3. 设置合并之后视频，音频
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,time);
    mainInstruction.layerInstructions = instructionArray;
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = audioParameterArray;
    
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = videoSize;
    
    //  导出路径
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo.mov"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:myPathDocs error:NULL];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    NSLog(@"URL:-  %@", [url description]);
    
    
    //导出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainComposition;
    exporter.audioMix = audioMix;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            completion(url,nil);
        }else {
            completion(nil,exporter.error);
        }
    }];
}

- (NSMutableArray<CanEditAsset *> *)materialVideoArray {
    if (!_materialVideoArray) {
        _materialVideoArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _materialVideoArray;
}

- (CMTime)totalTime {
    CMTime time = kCMTimeZero;
    for (CanEditAsset *asset in self.materialVideoArray) {
        time = CMTimeAdd(time, asset.playTimeRange.duration);
    }
    return time;
}

@end
