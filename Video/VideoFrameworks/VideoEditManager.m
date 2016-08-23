//
//  VideoEditManager.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoEditManager.h"

@implementation VideoEditManager

+ (void)mergeMultipleVideos:(NSArray *)videos completionBlock:(void (^)(AVURLAsset *assetURL, NSError *error))completion{
    // 2.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    
    CMTime time = kCMTimeZero;  // 循环的下一视频要插入的时间
    CGSize videoSize;
    NSMutableArray *instructionArray = [NSMutableArray arrayWithCapacity:videos.count];
    NSMutableArray *audioParameterArray = [NSMutableArray arrayWithCapacity:videos.count];
    for (id video in videos) {
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
            completion([AVURLAsset assetWithURL:url],nil);
        }else {
            completion(nil,exporter.error);
        }
    }];
}
//
//+ (void)exportDidFinish:(AVAssetExportSession*)session {
//    
//    NSLog(@"exportDidFinish");
//    
//    NSLog(@"session = %d",(int)session.status);
//    if (session.status == AVAssetExportSessionStatusCompleted) {
//        
//        NSURL *outputURL = session.outputURL;
//        
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])  {
//            
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (!error) {
//                        NSLog(@"存档成功");
//                    }else {
//                        NSLog(@"存档失败");
//                    }
//                });
//            }];
//            
//        }
//        
//    }else {
//        NSLog(@"存档失败");
//    }
//    
//}

@end
