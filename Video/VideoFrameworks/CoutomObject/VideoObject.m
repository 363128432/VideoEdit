//
//  VideoObject.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoObject.h"

@interface VideoObject ()

@property (nonatomic, strong) NSMutableArray *subtitleLabelArray;   // 字幕数组，防止添加layer时释放

@end

@implementation VideoObject

static VideoObject *currentVideo = nil;

+ (instancetype)currentVideo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentVideo = [[self alloc]init];
    });
    return currentVideo;
}

+ (void)attemptDealloc { currentVideo = [[self alloc]init]; }


- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicVolume = 0.5;
        _dubbingVolume = 0.5;
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
        
        // 存视频
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssset.duration)
                            ofTrack:[[videoAssset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:time
                              error:nil];
        // 视频架构层，用来规定video样式，比如合并两个视频，怎么放，是转90度还是边放边旋转
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        [layerInstruction setTransform:CGAffineTransformIdentity atTime:kCMTimeZero];
        NSLog(@"%f  %f",videoTrack.naturalSize.width,[UIScreen mainScreen].bounds.size.width);
        if (videoTrack.naturalSize.width == [UIScreen mainScreen].bounds.size.width + 1) {
            
            [layerInstruction setCropRectangle:CGRectMake(([UIScreen mainScreen].bounds.size.height - videoTrack.naturalSize.width) / 2, 0, videoTrack.naturalSize.width, [UIScreen mainScreen].bounds.size.height) atTime:kCMTimeZero];
        }
        
        [instructionArray insertObject:layerInstruction atIndex:0];
        
        videoSize = (videoSize.width >= videoTrack.naturalSize.width)?videoSize:videoTrack.naturalSize;
//        NSLog(@"%f  %f",videoSize.height,videoSize.width);
        
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
        NSLog(@"timescale is %d",time.timescale);
        
    }
    
    
    // 给视频添加背景音乐，背景音乐是多段音乐的特例，即self.musicArray为1，且timeRange为整个视频
    if (self.backgroundMusic) {
        MusicElementObject *musicElement = [[MusicElementObject alloc]init];
        musicElement.insertTime = CMTimeRangeMake(kCMTimeZero, CMTimeMinimum(self.backgroundMusic.duration, time));
        musicElement.pathUrl = self.backgroundMusic.URL;
        self.musicArray = [NSMutableArray arrayWithObject:musicElement];
    }
    
    for (MusicElementObject *musicElement in self.musicArray) {
//        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"];
//        NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
        AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicElement.pathUrl options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:musicElement.insertTime
                            ofTrack:[[musicAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:musicElement.insertTime.start
                              error:nil];
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
        [audioInputParams setVolumeRampFromStartVolume:_musicVolume toEndVolume:_musicVolume timeRange:musicElement.insertTime];
        [audioInputParams setTrackID:audioTrack.trackID];
        [audioParameterArray insertObject:audioInputParams atIndex:0];
    }
    
    // 添加配音
    for (DubbingElementObject *dubbingElement in self.dubbingArray) {
        AVURLAsset *dubbingAsset = [[AVURLAsset alloc] initWithURL:dubbingElement.pathUrl options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:dubbingElement.insertTime
                            ofTrack:[[dubbingAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:dubbingElement.insertTime.start
                              error:nil];
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
        [audioInputParams setVolumeRampFromStartVolume:_dubbingVolume toEndVolume:_dubbingVolume timeRange:dubbingElement.insertTime];
        [audioInputParams setTrackID:audioTrack.trackID];
        [audioParameterArray insertObject:audioInputParams atIndex:0];
    }

    // 添加字幕


    
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
    
    
    // 添加字幕
    // videoLayer是视频layer,parentLayer是最主要的，videoLayer和字幕，贴纸的layer都要加在该layer上
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    
    _subtitleLabelArray = [NSMutableArray arrayWithCapacity:self.subtitleArray.count];
    for (SubtitleElementObject *subtitleObject in self.subtitleArray) {
        UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:subtitleObject.rect];
        subtitleLabel.text = subtitleObject.title;
        subtitleLabel.font = [subtitleObject.font fontWithSize:subtitleObject.fontSize];
        [_subtitleLabelArray addObject:subtitleLabel];
        
        subtitleLabel.layer.opacity = 0;

        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1];
        opacityAnim.toValue = [NSNumber numberWithFloat:1];
//        opacityAnim.beginTime = 2;
        opacityAnim.duration = 3;
        opacityAnim.removedOnCompletion = NO;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.repeatCount = 1; // forever
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
//        rotationAnimation.delegate = self;
        rotationAnimation.removedOnCompletion = NO;
//        rotationAnimation.beginTime = 2;
        rotationAnimation.duration = 3; // repeat every 3 seconds
        
        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = @[opacityAnim, rotationAnimation];
        groupAnimation.duration = 5;
        rotationAnimation.beginTime = 1;

        [subtitleLabel.layer addAnimation:groupAnimation forKey:nil];
        
//        subtitleLabel.layer.opacity = 0;
//        // 只有在插入的时间段才显示
//        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        opacityAnim.fromValue = [NSNumber numberWithFloat:1];
//        opacityAnim.toValue = [NSNumber numberWithFloat:1];
//        opacityAnim.beginTime = CMTimeGetSeconds(subtitleObject.insertTime.start);
//        opacityAnim.duration = CMTimeGetSeconds(subtitleObject.insertTime.duration);
//        opacityAnim.removedOnCompletion = NO;
//        
//        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
//        rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
////        rotationAnimation.additive = YES;
//        rotationAnimation.removedOnCompletion = NO;
//        rotationAnimation.beginTime = CMTimeGetSeconds(subtitleObject.insertTime.start);
//        rotationAnimation.duration = CMTimeGetSeconds(subtitleObject.insertTime.duration); // repeat every 3 seconds
//        
//        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
//        groupAnimation.animations = @[opacityAnim, rotationAnimation];
//        groupAnimation.duration = CMTimeGetSeconds(time);
//        
//        [subtitleLabel.layer addAnimation:groupAnimation forKey:nil];
        
        [parentLayer addSublayer:subtitleLabel.layer];

    }
    
    mainComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    
    //  导出路径
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo.mov"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:myPathDocs error:NULL];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    _afterEditingPath = url;
    
    
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

- (NSMutableArray<NSNumber *> *)materialPointsArray {
    if (!_materialPointsArray) {
        _materialPointsArray = [NSMutableArray arrayWithCapacity:10];
        for (AVAsset *asset in _materialVideoArray) {
            NSNumber *number = [NSNumber numberWithFloat:CMTimeGetSeconds(asset.duration) / CMTimeGetSeconds(self.totalTime)];
            [_materialPointsArray addObject:number];
        }
    }
    return _materialPointsArray;
}

- (NSMutableArray<MusicElementObject *> *)musicArray {
    if (!_musicArray) {
        _musicArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _musicArray;
}

- (NSMutableArray<DubbingElementObject *> *)dubbingArray {
    if (!_dubbingArray) {
        _dubbingArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dubbingArray;
}

- (NSMutableArray<SubtitleElementObject *> *)subtitleArray {
    if (!_subtitleArray) {
        _subtitleArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _subtitleArray;
}

@end
