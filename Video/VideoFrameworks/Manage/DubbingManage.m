//
//  DubbingManage.m
//  Video
//
//  Created by 付州  on 16/9/27.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "DubbingManage.h"

@interface DubbingManage ()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic, strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@property (nonatomic, strong) DubbingElementObject *elementObject;
@property (nonatomic, assign) CMTime startTime;



@end

@implementation DubbingManage

- (void)startRecordingWithStartTime:(NSTimeInterval)time {
    self.elementObject = [[DubbingElementObject alloc]init];
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf",(NSInteger)[[NSDate date]timeIntervalSince1970]]];
    self.elementObject.pathUrl = [NSURL fileURLWithPath:urlStr];
    
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    _audioRecorder=[[AVAudioRecorder alloc]initWithURL:self.elementObject.pathUrl settings:setting error:&error];
    _audioRecorder.delegate=self;
    _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
        self.startTime = CMTimeMakeWithSeconds(time, 600);
    }
    
}

- (DubbingElementObject *)stopRecord {
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    
    return self.elementObject;
}

- (void)audioPowerChange {
    
    CMTime duration = CMTimeMakeWithSeconds(self.audioRecorder.currentTime, 600);
    self.elementObject.insertTime = CMTimeRangeMake(self.startTime, duration);
    
    if (_delegate && [_delegate respondsToSelector:@selector(dubbingElementWithTimeChange:)]) {
        [_delegate dubbingElementWithTimeChange:self.elementObject];
    }
}

#pragma mark get

-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

//- (NSURL *)pathUrl {
//    if (!_pathUrl) {
//        NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf",(NSInteger)[[NSDate date]timeIntervalSince1970]]];
//        NSLog(@"file path:%@",urlStr);
//        _pathUrl=[NSURL fileURLWithPath:urlStr];
//    }
//    return _pathUrl;
//}

//-(AVAudioRecorder *)audioRecorder{
//    if (!_audioRecorder) {
//        //创建录音格式设置
//        NSDictionary *setting=[self getAudioSetting];
//        //创建录音机
//        NSError *error=nil;
//        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:self.elementObject.pathUrl settings:setting error:&error];
//        _audioRecorder.delegate=self;
//        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
//        if (error) {
//            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
//            return nil;
//        }
//    }
//    return _audioRecorder;
//}

//-(AVAudioPlayer *)audioPlayer{
//    if (!_audioPlayer) {
//        NSError *error=nil;
//        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:self.elementObject.pathUrl error:&error];
//        _audioPlayer.numberOfLoops=0;
//        [_audioPlayer prepareToPlay];
//        if (error) {
//            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
//            return nil;
//        }
//    }
//    return _audioPlayer;
//}

-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

#pragma mark AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{    
    NSLog(@"录音完成!");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error	 {
    
}

@end
