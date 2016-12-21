//
//  VideoObject.m
//  VideoEdit
//
//  Created by 付州  on 16/8/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoObject.h"
#import "SubTitleAnimation.h"

@interface VideoObject ()

@property (nonatomic, strong) NSMutableArray *subtitleLabelArray;   // 字幕数组，防止添加layer时释放

@end

@implementation VideoObject
@synthesize totalTime = _totalTime;

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
        _originalVolume = 0.5;
        _musicVolume = 0.5;
        _dubbingVolume = 0.5;
    }
    return self;
}

#pragma mark Method
- (CMTime)startTimeWithIndex:(NSInteger)index {
    CMTime startTime = kCMTimeZero;
    for (int i  = 0 ; i < index; i++) {
        CanEditAsset *editAsset = _materialVideoArray[i];
        startTime = CMTimeAdd(startTime, editAsset.playTimeRange.duration);
    }
    return startTime;
}

- (void)combinationOfMaterialVideoCompletionBlock:(void (^)(NSURL *, NSError *))completion {
    //  导出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo.mov"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:myPathDocs error:NULL];
    _afterEditingPath = [NSURL fileURLWithPath:myPathDocs];
    
    [self combinationOfMaterialVideoWithSavePath:_afterEditingPath CompletionBlock:completion];
}

- (void)combinationOfMaterialVideoWithSavePath:(NSURL *)pathUrl CompletionBlock:(void (^)(NSURL *, NSError *))completion {
    _afterEditingPath = pathUrl;
    
    // 2.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    
    _totalTime = kCMTimeZero;  // 循环的下一视频要插入的时间
    CGSize videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    NSMutableArray *instructionArray = [NSMutableArray arrayWithCapacity:self.materialVideoArray.count];//存视频的
    NSMutableArray *audioParameterArray = [NSMutableArray arrayWithCapacity:self.materialVideoArray.count];//存音频的
    
    // 循环获取素材里的视频和音频数据
    for (CanEditAsset *video in self.materialVideoArray) {
        // 获取到AVURLAsset
        AVURLAsset *videoAssset;
        if (video.filterVideoPath) {
            videoAssset = [AVURLAsset assetWithURL:video.filterVideoPath];
        }else {
            videoAssset = video;
        }
        
        // 存视频
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:video.playTimeRange
                            ofTrack:[[videoAssset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:_totalTime
                              error:nil];

        // 视频架构层，用来规定video样式，比如合并两个视频，怎么放，是转90度还是边放边旋转
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        [layerInstruction setOpacity:0 atTime:CMTimeAdd(_totalTime, video.playTimeRange.duration)];
        if (videoTrack.naturalSize.width == videoTrack.naturalSize.height) {  // 如果是竖直拍摄的视频，平移到中间
            [layerInstruction setTransform:CGAffineTransformMakeTranslation(([UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width) / 2, 0) atTime:kCMTimeZero];
        }
        [instructionArray insertObject:layerInstruction atIndex:0];
        
        
        // 存音频
        if ([videoAssset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:video.playTimeRange
                                ofTrack:[[videoAssset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                 atTime:_totalTime
                                  error:nil];
            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
            [audioInputParams setVolumeRampFromStartVolume:_originalVolume toEndVolume:_originalVolume timeRange:CMTimeRangeMake(_totalTime, video.playTimeRange.duration)];
            [audioInputParams setTrackID:audioTrack.trackID];
            [audioParameterArray insertObject:audioInputParams atIndex:0];
        }
        
        _totalTime = CMTimeAdd(_totalTime, video.playTimeRange.duration);
    }
    
    
    // 给视频添加背景音乐
    for (MusicElementObject *musicElement in self.musicArray) {
        AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicElement.pathUrl options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
        if (CMTIMERANGE_IS_INVALID(musicElement.playTimeRange)) {
            musicElement.playTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(CMTimeGetSeconds(musicAsset.duration), 600));
        }
        // 根据选定音乐的长度，来判断是否需要循环
        CMTime musicLoopTime = CMTimeMakeWithSeconds(0, 600);
        while (CMTimeGetSeconds(musicLoopTime) <= CMTimeGetSeconds(musicElement.insertTime.duration)) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            CMTimeRange musicPlayRange = CMTimeRangeMake(musicElement.playTimeRange.start, CMTimeMinimum(musicElement.playTimeRange.duration, CMTimeSubtract(musicElement.insertTime.duration, musicLoopTime)));
            [audioTrack insertTimeRange:musicPlayRange
                                ofTrack:[[musicAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                 atTime:CMTimeAdd(musicElement.insertTime.start, musicLoopTime)
                                  error:nil];
            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
            [audioInputParams setVolumeRampFromStartVolume:_musicVolume toEndVolume:_musicVolume timeRange:musicPlayRange];
            [audioInputParams setTrackID:audioTrack.trackID];
            [audioParameterArray insertObject:audioInputParams atIndex:0];
            
            musicLoopTime = CMTimeAdd(musicLoopTime, musicElement.playTimeRange.duration);
        }
    }
    
    // 添加配音
    for (DubbingElementObject *dubbingElement in self.dubbingArray) {
        AVURLAsset *dubbingAsset = [[AVURLAsset alloc] initWithURL:dubbingElement.pathUrl options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, dubbingElement.insertTime.duration)
                            ofTrack:[[dubbingAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:dubbingElement.insertTime.start
                              error:nil];
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack] ;
        [audioInputParams setVolumeRampFromStartVolume:_dubbingVolume toEndVolume:_dubbingVolume timeRange:dubbingElement.insertTime];
        [audioInputParams setTrackID:audioTrack.trackID];
        [audioParameterArray insertObject:audioInputParams atIndex:0];
    }




    
    // 3. 设置合并之后视频，音频
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,_totalTime);
    mainInstruction.layerInstructions = instructionArray;
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = audioParameterArray;
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = videoSize;
    
    
    
    // 以下是导出不含字幕的视频路径
    //  导出路径
    NSString *noSubtitlePath = [[_afterEditingPath path] stringByReplacingOccurrencesOfString:@".mov" withString:@"_noSubtitle.mov"];
    unlink([noSubtitlePath UTF8String]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:noSubtitlePath error:NULL];
    _noSubtitleVideoPath = [NSURL fileURLWithPath:noSubtitlePath];
    //导出
    AVAssetExportSession *exporter1 = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter1.outputURL = _noSubtitleVideoPath;
    exporter1.outputFileType = AVFileTypeQuickTimeMovie;
    exporter1.shouldOptimizeForNetworkUse = YES;
    exporter1.videoComposition = [mainComposition copy];
    exporter1.audioMix = audioMix;
    [exporter1 exportAsynchronouslyWithCompletionHandler:^{
        
    }];
    
    
    
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
        subtitleLabel.textColor = subtitleObject.textColor;
        subtitleLabel.font = [UIFont fontWithName:subtitleObject.fontName size:subtitleObject.fontSize];
        [_subtitleLabelArray addObject:subtitleLabel];
        
        // 这个是透明度动画主要是使在插入的才显示，其它时候都是不显示的
        subtitleLabel.layer.opacity = 0;
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1];
        opacityAnim.toValue = [NSNumber numberWithFloat:1];
        opacityAnim.removedOnCompletion = NO;
        
        CABasicAnimation *rotationAnimation;
        switch (subtitleObject.animationType) {
            case 0:
            
                break;
            case 1:
                rotationAnimation = [SubTitleAnimation moveAnimationWithFromPosition:CGPointMake(subtitleLabel.layer.position.x + 100, subtitleLabel.layer.position.y) toPosition:subtitleLabel.layer.position];
                break;
            case 2:
                rotationAnimation = [SubTitleAnimation moveAnimationWithFromPosition:CGPointMake(subtitleLabel.layer.position.x, subtitleLabel.layer.position.y + 50) toPosition:subtitleLabel.layer.position];
                break;
            case 3:
                rotationAnimation = [SubTitleAnimation narrowIntoAnimation];
                break;
            case 4:
                rotationAnimation = [SubTitleAnimation fadeInAnimation];
                break;
            case 5:
                rotationAnimation = [SubTitleAnimation transformAnimation];
                break;
                
            default:
                break;
        }
        
        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = [NSArray arrayWithObjects:opacityAnim, rotationAnimation, nil];
        if (CMTimeGetSeconds(subtitleObject.insertTime.start) == 0) {
            groupAnimation.beginTime = 0.01;
        }else {
            groupAnimation.beginTime = CMTimeGetSeconds(subtitleObject.insertTime.start);
        }
        groupAnimation.duration = CMTimeGetSeconds(subtitleObject.insertTime.duration);

        [subtitleLabel.layer addAnimation:groupAnimation forKey:nil];
        [parentLayer addSublayer:subtitleLabel.layer];
    }
    
    
    
    // 添加贴纸
    for (int i = 0; i < self.stickerArray.count; i++) {
        StickerElementObject *stickerElement = self.stickerArray[i];
        [self addSubLayerWithParentLayer:parentLayer stickerElement:stickerElement];
    }
    
    
    
    mainComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    

    //导出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = _afterEditingPath;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainComposition;
    exporter.audioMix = audioMix;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            completion(_afterEditingPath,nil);
        }else {
            completion(nil,exporter.error);
        }
    }];
}



#pragma mark ThemeMethod
- (void)changeThemeWithUUID:(NSString *)uuid {
    if ([self.theme.uuid isEqualToString:uuid]) {
        return;
    }
    
//     如果之前的主题前后有视频之类，先删除
    if (self.theme.endTrailer) {
        [self deleteMaterialWithIndex:_materialVideoArray.count - 1];
    }
    if (self.theme.prefaceTrailer) {
        [self deleteMaterialWithIndex:0];
    }
    
    
    ThemeObject *newtheme = [ThemeObject getThemeWithUUID:uuid];
    
    if (newtheme.uuid) {
        CanEditAsset *asset = [CanEditAsset assetWithURL:newtheme.prefaceTrailer];
        [self insertMaterialObject:asset atIndex:0];
        CanEditAsset *endAsset = [CanEditAsset assetWithURL:newtheme.endTrailer];
        [self insertMaterialObject:endAsset atIndex:_materialVideoArray.count];
        
        CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
        SubtitleElementObject *subtitleElement = [[SubtitleElementObject alloc]init];
        subtitleElement.insertTime = CMTimeRangeMake(kCMTimeZero, asset.duration);
        subtitleElement.title = @"美摄 记录美好生活";
        subtitleElement.fontSize = 20 * ratio;
        subtitleElement.textColor = [UIColor whiteColor];
        subtitleElement.rect = [self themeSubtitleRectWithText:subtitleElement.title fontSize:20];
        if ([newtheme.uuid isEqualToString:@"7FE423C8CA844F7E8DFF47744DF8D8A7"]) {
            subtitleElement.animationType = SubtitleAnimationTypeWithLeftMove;
        }else {
            subtitleElement.animationType = SubtitleAnimationTypeWithNarrow;
        }
        [self.subtitleArray addObject:subtitleElement];
        
        
        SubtitleElementObject *endSubtitleElement = [[SubtitleElementObject alloc]init];
        endSubtitleElement.insertTime = CMTimeRangeMake(CMTimeSubtract(_totalTime, asset.duration), endAsset.duration);
        endSubtitleElement.title = @"美摄 电影";
        endSubtitleElement.fontSize = 20 * ratio;
        endSubtitleElement.textColor = [UIColor whiteColor];
        endSubtitleElement.rect = [self themeSubtitleRectWithText:endSubtitleElement.title fontSize:20];
        if ([newtheme.uuid isEqualToString:@"7FE423C8CA844F7E8DFF47744DF8D8A7"]) {
            endSubtitleElement.animationType = SubtitleAnimationTypeWithLeftMove;
        }else {
            endSubtitleElement.animationType = SubtitleAnimationTypeWithNarrow;
        }
        [self.subtitleArray addObject:endSubtitleElement];
        
        
        MusicElementObject *musicObject = [[MusicElementObject alloc]init];
        musicObject.pathUrl = newtheme.musicFile;
        [self setBackgroundMusic:musicObject];
    }
    

    
    self.theme = newtheme;
    
}

#pragma mark MusicMethod
- (MusicElementObject *)searchHaveMusicElementWithThisTime:(NSTimeInterval)time {
    for (MusicElementObject *object in self.musicArray) {
        if (time >= CMTimeGetSeconds(object.insertTime.start) && time <= CMTimeGetSeconds(object.insertTime.start) + CMTimeGetSeconds(object.insertTime.duration)) {
            return object;
        }
    }
    return nil;
}

- (void)setBackgroundMusic:(MusicElementObject *)object {
    [self.musicArray removeAllObjects];
   
    object.insertTime = CMTimeRangeMake(kCMTimeZero, _totalTime);
    
    [self.musicArray addObject:object];
}

- (MusicElementObject *)addMusicArrayObject:(MusicElementObject *)object {
    // 查询是否有覆盖某背景，然后进行调整
    CMTime minDuration = object.insertTime.duration;
    for (MusicElementObject *elementObject in self.musicArray) {
        CMTimeRange intersectionRange = CMTimeRangeGetIntersection(elementObject.insertTime, object.insertTime);
        if (CMTimeGetSeconds(intersectionRange.duration) != 0) {  // 有覆盖，算出最小的视频长度
            minDuration =  CMTimeSubtract(elementObject.insertTime.start, object.insertTime.start);
        }
    }
    
    object.insertTime = CMTimeRangeMake(object.insertTime.start, minDuration);
    object.insertTime = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, _totalTime), object.insertTime);
    
    [self.musicArray addObject:object];
    
    return object;
}


#pragma mark DubbingMethod

- (DubbingElementObject *)searchHaveDubbingElementWithThisTime:(NSTimeInterval)time {
    for (DubbingElementObject *object in self.dubbingArray) {
        if (time >= CMTimeGetSeconds(object.insertTime.start) && time <= CMTimeGetSeconds(object.insertTime.start) + CMTimeGetSeconds(object.insertTime.duration)) {
            return object;
        }
    }
    return nil;
}

- (void)addDubbingArrayObject:(DubbingElementObject *)object {
    for (NSInteger i = self.dubbingArray.count - 1; i >= 0; i--) {
        DubbingElementObject *obj = self.dubbingArray[i];
        CMTimeRange intersectionRange = CMTimeRangeGetIntersection(obj.insertTime, object.insertTime);
        if (CMTimeGetSeconds(intersectionRange.duration) != 0) {  // 如果全覆盖，直接删除，没全覆盖，将覆盖对象裁剪
            if (CMTimeRangeEqual(intersectionRange, obj.insertTime)) {
                [self.dubbingArray removeObject:obj];
            }else {
                obj.insertTime = CMTimeRangeMake(CMTimeAdd(intersectionRange.start, intersectionRange.duration), CMTimeSubtract(obj.insertTime.duration,intersectionRange.duration));
            }
        }
    }

    object.insertTime = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, _totalTime), object.insertTime);
    
    [self.dubbingArray addObject:object];
}


#pragma mark SubtitleMethod
- (void)addSubtitleArrayObject:(SubtitleElementObject *)object {
    [self.subtitleArray addObject:object];
}

- (NSMutableArray *)searchHaveSubtitleElementWithThisTime:(NSTimeInterval)time {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    [self.subtitleArray enumerateObjectsUsingBlock:^(SubtitleElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (time >= CMTimeGetSeconds(obj.insertTime.start) && time <= CMTimeGetSeconds(obj.insertTime.start) + CMTimeGetSeconds(obj.insertTime.duration)) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (CGRect)themeSubtitleRectWithText:(NSString *)string fontSize:(CGFloat)fontSize {
    CGSize size = CGSizeMake(string.length * fontSize, fontSize);
    
    CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    CGFloat playViewHeight =  [UIScreen mainScreen].bounds.size.width / ratio;
    CGRect textRect = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) / 2, (playViewHeight - size.height) / 2, size.width, size.height);
    
    return CGRectMake(textRect.origin.x * ratio, (playViewHeight - textRect.origin.y) * ratio - textRect.size.height * ratio, textRect.size.width * ratio, textRect.size.height * ratio);
}



#pragma mark StickerMethod
- (void)addSubLayerWithParentLayer:(CALayer *)parentLayer stickerElement:(StickerElementObject *)stickerElement {
    for (int i = 0; i < stickerElement.animatedSticker.storyboard.track.count; i++) {
        Track *track = stickerElement.animatedSticker.storyboard.track[i];
        
        CALayer *stickerLayer = [CALayer layer];
        stickerLayer.opacity = 0;
        stickerLayer.contents = (id)[UIImage imageWithContentsOfFile:[stickerElement.animatedSticker.savePath stringByAppendingPathComponent:track.source]].CGImage;
        
        CGFloat ratio = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
        CGSize nowSize = CGSizeMake(stickerElement.stickerView.imageOriginalSize.width * stickerElement.stickerView.ratio * ratio, stickerElement.stickerView.imageOriginalSize.height * stickerElement.stickerView.ratio * ratio);
        stickerLayer.frame = CGRectMake(0, 0, nowSize.width, nowSize.height);
        stickerLayer.position = CGPointMake(stickerElement.stickerView.center.x * ratio, [UIScreen mainScreen].bounds.size.width - stickerElement.stickerView.center.y * ratio);
        stickerLayer.affineTransform = CGAffineTransformMakeRotation(- stickerElement.stickerView.angle);
        
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.beginTime = MAX(CMTimeGetSeconds(stickerElement.insertTime.start), 0.001);
        group.duration = CMTimeGetSeconds(stickerElement.insertTime.duration);
        
        if (track.effect) {
            Animation *animation = track.effect.animation;
            NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:10];
            
            for (int i = 0; i < animation.key.count; i++) {
                Key *key = animation.key[i];
                
                [timeArray addObject:[NSNumber numberWithFloat:[key.time floatValue]]];
                [valueArray addObject:[NSNumber numberWithFloat:[key.value floatValue]]];
            }
            
            
            CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
            keyAnimation.keyPath = animation.paramName;
            keyAnimation.values = valueArray;
            keyAnimation.keyTimes = timeArray;
            keyAnimation.beginTime = [track.clipStart floatValue];
            keyAnimation.duration = [track.clipDuration floatValue];
            if (track.repeat) {
                keyAnimation.repeatCount = MAXFLOAT;
            }
            
            group.animations = @[keyAnimation];
            
            [stickerLayer addAnimation:group forKey:nil];
        }else {
            if (track.repeatInterval) {
                
                CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
                keyAnimation.keyPath = @"opacity";
                keyAnimation.values = @[@(1),@(1),@(0)];
                keyAnimation.keyTimes = @[@([track.clipStart floatValue]),@([track.clipDuration floatValue] - 0.001),@([track.repeatInterval floatValue])];
                keyAnimation.beginTime = [track.clipStart floatValue];
                keyAnimation.duration = [track.repeatInterval floatValue];
                if (track.repeat) {
                    keyAnimation.repeatCount = MAXFLOAT;
                }
                
                group.animations = @[keyAnimation];
                
                [stickerLayer addAnimation:group forKey:nil];
            }else {
                CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacityAnim.fromValue = [NSNumber numberWithFloat:1];
                opacityAnim.toValue = [NSNumber numberWithFloat:1];
                opacityAnim.beginTime = [track.clipStart floatValue];
                opacityAnim.duration = [track.clipDuration floatValue];
                if (track.repeat) {
                    opacityAnim.repeatCount = MAXFLOAT;
                }
                group.animations = @[opacityAnim];
            }
            [stickerLayer addAnimation:group forKey:nil];
        }
        
        
        [parentLayer addSublayer:stickerLayer];
    }
}

- (NSMutableArray<StickerElementObject *> *)stickerArray {
    if (!_stickerArray) {
        _stickerArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _stickerArray;
}

- (void)addStickerObject:(StickerElementObject *)object {
    [self.stickerArray addObject:object];
}

- (NSMutableArray *)searchHaveStickerElementWithThisTime:(NSTimeInterval)time {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    [self.stickerArray enumerateObjectsUsingBlock:^(StickerElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (time >= CMTimeGetSeconds(obj.insertTime.start) && time <= CMTimeGetSeconds(obj.insertTime.start) + CMTimeGetSeconds(obj.insertTime.duration)) {
            [array addObject:obj];
        }
    }];
    return array;
}

#pragma mark Edit
- (void)insertMaterialObject:(CanEditAsset *)editAsset atIndex:(NSUInteger)index {
    [self.materialVideoArray insertObject:editAsset atIndex:index];
    
    // 计算插入所在时间段
    CMTime insertTime = kCMTimeZero;
    for (int i  = 0 ; i < index; i++) {
        CanEditAsset *editAsset = _materialVideoArray[i];
        insertTime = CMTimeAdd(insertTime, editAsset.playTimeRange.duration);
    }
    
    
    [self.musicArray enumerateObjectsUsingBlock:^(MusicElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CMTimeGetSeconds(obj.insertTime.start) >= CMTimeGetSeconds(insertTime)) {   // 如果在插入时间之后，直接将时间推迟一个插入素材的时长
            obj.insertTime = CMTimeRangeMake(CMTimeAdd(obj.insertTime.start, editAsset.duration), obj.insertTime.duration);
        }else { // 在插入时间之前
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(obj.insertTime, CMTimeRangeMake(insertTime, editAsset.duration));
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {    // 计算音乐时间区域是否在插入之后的时间里，是就的去后面部分剪切，只要前面的
                obj.insertTime = CMTimeRangeMake(obj.insertTime.start, CMTimeSubtract(obj.insertTime.duration, intersectionRange.duration));
            }
        }
    }];
    
    
    [self.subtitleArray enumerateObjectsUsingBlock:^(SubtitleElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CMTimeGetSeconds(obj.insertTime.start) >= CMTimeGetSeconds(insertTime)) {   // 如果在插入时间之后，直接将时间推迟一个插入素材的时长
            obj.insertTime = CMTimeRangeMake(CMTimeAdd(obj.insertTime.start, editAsset.duration), obj.insertTime.duration);
        }else { // 在插入时间之前
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(obj.insertTime, CMTimeRangeMake(insertTime, editAsset.duration));
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {    // 计算音乐时间区域是否在插入之后的时间里，是就的去后面部分剪切，只要前面的
                obj.insertTime = CMTimeRangeMake(obj.insertTime.start, CMTimeSubtract(obj.insertTime.duration, intersectionRange.duration));
            }
        }
    }];
    
    [self.dubbingArray enumerateObjectsUsingBlock:^(DubbingElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CMTimeGetSeconds(obj.insertTime.start) >= CMTimeGetSeconds(insertTime)) {   // 如果在插入时间之后，直接将时间推迟一个插入素材的时长
            obj.insertTime = CMTimeRangeMake(CMTimeAdd(obj.insertTime.start, editAsset.duration), obj.insertTime.duration);
        }else { // 在插入时间之前
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(obj.insertTime, CMTimeRangeMake(insertTime, editAsset.duration));
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {    // 计算音乐时间区域是否在插入之后的时间里，是就的去后面部分剪切，只要前面的
                obj.insertTime = CMTimeRangeMake(obj.insertTime.start, CMTimeSubtract(obj.insertTime.duration, intersectionRange.duration));
            }
        }
    }];
    
    [self.stickerArray enumerateObjectsUsingBlock:^(StickerElementObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CMTimeGetSeconds(obj.insertTime.start) >= CMTimeGetSeconds(insertTime)) {   // 如果在插入时间之后，直接将时间推迟一个插入素材的时长
            obj.insertTime = CMTimeRangeMake(CMTimeAdd(obj.insertTime.start, editAsset.duration), obj.insertTime.duration);
        }else { // 在插入时间之前
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(obj.insertTime, CMTimeRangeMake(insertTime, editAsset.duration));
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {    // 计算音乐时间区域是否在插入之后的时间里，是就的去后面部分剪切，只要前面的
                obj.insertTime = CMTimeRangeMake(obj.insertTime.start, CMTimeSubtract(obj.insertTime.duration, intersectionRange.duration));
            }
        }
    }];
    
    _totalTime = CMTimeAdd(_totalTime, editAsset.playTimeRange.duration);
}


// 剪切
- (void)changeEditAssetPlayTimeRangeWithAsset:(CanEditAsset *)editAsset playTimeRange:(CMTimeRange)playTimeRange {
    NSInteger index = [self.materialVideoArray indexOfObject:editAsset];
    self.musicArray = [self changeEditAssetPlayTimeRangeWithOldPlayTimeRange:editAsset.playTimeRange newPlayTimeRange:playTimeRange assetStartTime:[self startTimeWithIndex:index] withAddElementObjectArray:self.musicArray];
    self.dubbingArray = [self changeEditAssetPlayTimeRangeWithOldPlayTimeRange:editAsset.playTimeRange newPlayTimeRange:playTimeRange assetStartTime:[self startTimeWithIndex:index] withAddElementObjectArray:self.dubbingArray];
    self.subtitleArray = [self changeEditAssetPlayTimeRangeWithOldPlayTimeRange:editAsset.playTimeRange newPlayTimeRange:playTimeRange assetStartTime:[self startTimeWithIndex:index] withAddElementObjectArray:self.subtitleArray];
    self.stickerArray = [self changeEditAssetPlayTimeRangeWithOldPlayTimeRange:editAsset.playTimeRange newPlayTimeRange:playTimeRange assetStartTime:[self startTimeWithIndex:index] withAddElementObjectArray:self.stickerArray];
    
    editAsset.playTimeRange = playTimeRange ;
    
}

// 更改视频播放时长时，插入元素的插入时间的更改
- (NSMutableArray *)changeEditAssetPlayTimeRangeWithOldPlayTimeRange:(CMTimeRange)oldPlayTimeRange newPlayTimeRange:(CMTimeRange)newPlayTimeRange assetStartTime:(CMTime)assetStartTime withAddElementObjectArray:(NSMutableArray *)array {
        for (int i = (int)array.count - 1; i >= 0; i--) {
            AddElementObject *object = array[i];
            // 如果和之前的视频播放时间段有重复，直接删除，没有话，是之前的，时间不变，之后的，时间改为之后的时间
            if (CMTimeGetSeconds(CMTimeRangeGetIntersection(CMTimeRangeMake(assetStartTime, oldPlayTimeRange.duration), object.insertTime).duration) != 0) {
                [array removeObject:object];
            }else if (CMTimeGetSeconds(object.insertTime.start) +  CMTimeGetSeconds(object.insertTime.duration) <= CMTimeGetSeconds(assetStartTime)) { // 是之前的，时间不变
                
            }else { // 是之前的，时间不变
                object.insertTime = CMTimeRangeMake(CMTimeAdd(assetStartTime, newPlayTimeRange.duration), object.insertTime.duration);
            }
            
//        if (CMTimeGetSeconds(object.insertTime.start) < CMTimeGetSeconds(assetStartTime)) {
//            if (CMTimeGetSeconds(object.insertTime.start) +  CMTimeGetSeconds(object.insertTime.duration) > CMTimeGetSeconds(assetStartTime)) {
//                [array removeObject:object];
//            }
//        }else {
//            if (CMTimeGetSeconds(object.insertTime.start) +  CMTimeGetSeconds(object.insertTime.duration) > CMTimeGetSeconds(assetStartTime)) {
//                [array removeObject:object];
//            }
//        }
    }
    
    return array;
}

// 分割
- (void)componentsSeparatedWithIndex:(NSInteger)index byTime:(NSTimeInterval)time {
    CanEditAsset *oneAsset = self.materialVideoArray[index];
    CMTimeRange originalTimeRange = oneAsset.playTimeRange;
    CanEditAsset *twoAsset = [self copyMaterialWithIndex:index];
    oneAsset.playTimeRange = CMTimeRangeMake(originalTimeRange.start, CMTimeMakeWithSeconds(time - CMTimeGetSeconds(originalTimeRange.start), 600));
    twoAsset.playTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(time, 600), CMTimeMakeWithSeconds(CMTimeGetSeconds(originalTimeRange.duration) - time, 600));
}
// 复制
- (CanEditAsset *)copyMaterialWithIndex:(NSInteger)index {
    CanEditAsset *editAsset = self.materialVideoArray[index];
    CanEditAsset *copyEditAsset = [CanEditAsset assetWithURL:editAsset.URL];
    copyEditAsset.playTimeRange = CMTimeRangeMake(editAsset.playTimeRange.start, editAsset.playTimeRange.duration);
    [self insertMaterialObject:copyEditAsset atIndex:index + 1];
    return copyEditAsset;
}
// 删除
- (void)deleteMaterialWithIndex:(NSInteger)index {
    CanEditAsset *deleteAsset = _materialVideoArray[index];
    
    // 计算被删除的素材所在时间段
    CMTime deleteFromSeconds = kCMTimeZero;
    for (int i  = 0 ; i < index; i++) {
        CanEditAsset *editAsset = _materialVideoArray[i];
        deleteFromSeconds = CMTimeAdd(deleteFromSeconds, editAsset.playTimeRange.duration);
    }
    CMTimeRange deleteRange = CMTimeRangeMake(deleteFromSeconds, deleteAsset.playTimeRange.duration);
    
    
    // 以下的遍历其实用个方法写更好，，传参数组和addElement这个父类参数
    // 遍历文字，在被删除的素材所在时间段之后的全部缩减
    for (NSInteger i = self.subtitleArray.count - 1; i >= 0; i--) {
        SubtitleElementObject *subtitleElement = _subtitleArray[i];
        
        if (CMTimeGetSeconds(subtitleElement.insertTime.start) < CMTimeGetSeconds(deleteFromSeconds)) { // 字幕起始时间在被删除的素材之前，然后判断是否在被删除的素材所在的时间区域内,在区域内，重设insertTime的时长
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(subtitleElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                subtitleElement.insertTime = CMTimeRangeMake(subtitleElement.insertTime.start, CMTimeSubtract(subtitleElement.insertTime.duration, intersectionRange.duration));
            }
        }else { // 字幕起始时间在被删除的素材之间,直接删除。在之后，时间前移
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(subtitleElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                [self.subtitleArray removeObject:subtitleElement];
            }else {
                subtitleElement.insertTime = CMTimeRangeMake(CMTimeSubtract(subtitleElement.insertTime.start, deleteRange.duration), subtitleElement.insertTime.duration);
            }
        }
    }
    
    // 遍历音乐，在被删除的素材所在时间段之后的全部缩减
    for (NSInteger i = self.musicArray.count - 1; i >= 0; i--) {
        MusicElementObject *musicElement = self.musicArray[i];
        
        if (CMTimeGetSeconds(musicElement.insertTime.start) < CMTimeGetSeconds(deleteFromSeconds)) { // 字幕起始时间在被删除的素材之前，然后判断是否在被删除的素材所在的时间区域内,在区域内，重设insertTime的时长
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(musicElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                musicElement.insertTime = CMTimeRangeMake(musicElement.insertTime.start, CMTimeSubtract(musicElement.insertTime.duration, intersectionRange.duration));
            }
        }else { // 字幕起始时间在被删除的素材之间,直接删除。在之后，时间前移
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(musicElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                [self.musicArray removeObject:musicElement];
            }else {
                musicElement.insertTime = CMTimeRangeMake(CMTimeSubtract(musicElement.insertTime.start, deleteRange.duration), musicElement.insertTime.duration);
            }
        }
    }
    
    // 遍历配音，在被删除的素材所在时间段之后的全部缩减
    for (NSInteger i = self.dubbingArray.count - 1; i >= 0; i--) {
        DubbingElementObject *dubbingElement = self.dubbingArray[i];
        
        if (CMTimeGetSeconds(dubbingElement.insertTime.start) < CMTimeGetSeconds(deleteFromSeconds)) { // 字幕起始时间在被删除的素材之前，然后判断是否在被删除的素材所在的时间区域内,在区域内，重设insertTime的时长
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(dubbingElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                dubbingElement.insertTime = CMTimeRangeMake(dubbingElement.insertTime.start, CMTimeSubtract(dubbingElement.insertTime.duration, intersectionRange.duration));
            }
        }else { // 字幕起始时间在被删除的素材之间,直接删除。在之后，时间前移
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(dubbingElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                [self.dubbingArray removeObject:dubbingElement];
            }else {
                dubbingElement.insertTime = CMTimeRangeMake(CMTimeSubtract(dubbingElement.insertTime.start, deleteRange.duration), dubbingElement.insertTime.duration);
            }
        }
    }
    
    
    // 遍历贴纸，
    for (NSInteger i = self.stickerArray.count - 1; i >= 0; i--) {
        StickerElementObject *stickerElement = self.stickerArray[i];
        
        if (CMTimeGetSeconds(stickerElement.insertTime.start) < CMTimeGetSeconds(deleteFromSeconds)) { // 字幕起始时间在被删除的素材之前，然后判断是否在被删除的素材所在的时间区域内,在区域内，重设insertTime的时长
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(stickerElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                stickerElement.insertTime = CMTimeRangeMake(stickerElement.insertTime.start, CMTimeSubtract(stickerElement.insertTime.duration, intersectionRange.duration));
            }
        }else { // 字幕起始时间在被删除的素材之间,直接删除。在之后，时间前移
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(stickerElement.insertTime, deleteRange);
            if (CMTimeGetSeconds(intersectionRange.duration) != 0) {
                [self.stickerArray removeObject:stickerElement];
            }else {
                stickerElement.insertTime = CMTimeRangeMake(CMTimeSubtract(stickerElement.insertTime.start, deleteRange.duration), stickerElement.insertTime.duration);
            }
        }
    }
    
    _totalTime = CMTimeSubtract(_totalTime, deleteAsset.playTimeRange.duration);

    [self.materialVideoArray removeObject:deleteAsset];
}


#pragma mark pro
- (NSMutableArray<CanEditAsset *> *)materialVideoArray {
    if (!_materialVideoArray) {
        _materialVideoArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _materialVideoArray;
}

- (NSMutableArray<CanEditAsset *> *)themeMaterialArray {
    if (!_themeMaterialArray) {
        _themeMaterialArray = [NSMutableArray arrayWithArray:self.materialVideoArray];
    }
    return _themeMaterialArray;
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
