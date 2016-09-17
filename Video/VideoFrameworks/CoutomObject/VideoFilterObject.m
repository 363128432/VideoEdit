//
//  VideoFilterObject.m
//  Video
//
//  Created by 付州  on 16/8/31.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "VideoFilterObject.h"

@implementation VideoFilterObject

+ (NSArray *)filterArray {
    return @[@{ @"filterTitle":@"无",
                @"filter":[self getNoneFilter]
                },
             @{ @"filterTitle":@"滤镜1",
                @"filter":[self getLookupFilter]
                },
             @{ @"filterTitle":@"滤镜2",
                @"filter":[self getAmatorkaFilter]
                },
             @{ @"filterTitle":@"滤镜3",
                @"filter":[self getMissEtikateFilter]
                },
             @{ @"filterTitle":@"滤镜4",
                @"filter":[self getSoftEleganceFilter]
                }];
}

+ (GPUImageOutput<GPUImageInput> *)getNoneFilter {
    return [[GPUImageFilter alloc]init];
}

+ (GPUImageOutput<GPUImageInput> *)getLookupFilter {
    return [[GPUImageSketchFilter alloc]init];
}

+ (GPUImageOutput<GPUImageInput> *)getAmatorkaFilter {
    return [[GPUImageAmatorkaFilter alloc]init];
}

+ (GPUImageOutput<GPUImageInput> *)getMissEtikateFilter {
    return [[GPUImageMissEtikateFilter alloc]init];
}

+ (GPUImageOutput<GPUImageInput> *)getSoftEleganceFilter {
    return [[GPUImageSoftEleganceFilter alloc]init];
}

@end
