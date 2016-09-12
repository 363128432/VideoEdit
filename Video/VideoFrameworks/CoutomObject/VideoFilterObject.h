//
//  VideoFilterObject.h
//  Video
//
//  Created by 付州  on 16/8/31.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface VideoFilterObject : NSObject

+ (NSArray<NSDictionary *> *)filterArray;

+ (GPUImageOutput<GPUImageInput> *)getNoneFilter;   // 无滤镜，返回gpuimage

+ (GPUImageOutput<GPUImageInput> *)getLookupFilter;

+ (GPUImageOutput<GPUImageInput> *)getAmatorkaFilter;

+ (GPUImageOutput<GPUImageInput> *)getMissEtikateFilter;

+ (GPUImageOutput<GPUImageInput> *)getSoftEleganceFilter;

//+ (GPUImageOutput<GPUImageInput> *)getLookupFilter;
//
//+ (GPUImageOutput<GPUImageInput> *)getLookupFilter;
//
//+ (GPUImageOutput<GPUImageInput> *)getLookupFilter;
//
//+ (GPUImageOutput<GPUImageInput> *)getLookupFilter;


@end
