//
//  AddVideoCollectionViewController.m
//  Video
//
//  Created by 付州  on 16/10/17.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "AddVideoCollectionViewController.h"


@interface AddVideoCollectionViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (nonatomic, copy) void (^ block)(NSURL *assetUrl);

@property (nonatomic, strong) NSMutableArray *gropArray;
@property (nonatomic, strong) NSMutableArray *appVideoArray;
@property (nonatomic, strong) NSMutableArray *phoneVideoArray;

@end

@implementation AddVideoCollectionViewController

static NSString * const reuseIdentifier = @"AddVideoCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testRun];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)segmentAction:(id)sender {
    [self.collectionView reloadData];
}

- (void)testRun
{
    __weak AddVideoCollectionViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.gropArray addObject:group];
            } else {
                [weakSelf.gropArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if ([result thumbnail] != nil) {
                            // 照片
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                
                                NSDate *date= [result valueForProperty:ALAssetPropertyDate];
                                UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                NSString *fileName = [[result defaultRepresentation] filename];
                                NSURL *url = [[result defaultRepresentation] url];
                                int64_t fileSize = [[result defaultRepresentation] size];
                                
                                [self.phoneVideoArray addObject:url];
                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (self.segmented.selectedSegmentIndex == 1) {
                                        [self.collectionView reloadData];
                                    }
                                });
                            }
                            // 视频
                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
                                
                                // 和图片方法类似
                            }
                        }
                    }];
                }];
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            
            NSString *errorMessage = nil;
            
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                    
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            });
        };
        
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}

- (void)selectVideoAssetcompletion:(void (^)(NSURL *))completion  {
    _block = completion;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.segmented.selectedSegmentIndex == 0 ? self.appVideoArray.count : self.phoneVideoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSMutableArray *array = self.segmented.selectedSegmentIndex == 0 ? self.appVideoArray : self.phoneVideoArray;
    AVURLAsset *asset = [AVURLAsset assetWithURL:array[indexPath.row]];
    cell.videoTIme.text = [NSString stringWithFormat:@"%ld:%ld",(NSInteger)CMTimeGetSeconds(asset.duration) / 60, (NSInteger)CMTimeGetSeconds(asset.duration) % 60];
    [cell.videoImage setImage:[asset thumbnailImageAtTime:0]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.segmented.selectedSegmentIndex == 0 ? self.appVideoArray : self.phoneVideoArray;
    _block(array[indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark <UICollectionViewDelegate>


- (NSMutableArray *)appVideoArray {
    if (!_appVideoArray) {
        _appVideoArray = [NSMutableArray arrayWithCapacity:10];
        
        NSString *movieFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
        
        NSFileManager *myFileManager=[NSFileManager defaultManager];
        NSArray *fileList = [myFileManager contentsOfDirectoryAtPath:movieFilePath error:nil];
        
        [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![[obj substringToIndex:1] isEqualToString:@"."] && [[obj substringToIndex:5] isEqualToString:@"Movie"]) {
                NSString *path = [movieFilePath stringByAppendingPathComponent:obj];
                
                [_appVideoArray addObject:[[NSURL alloc]initFileURLWithPath:path]];
            }
        }];
        
    }
    return _appVideoArray;
}

- (NSMutableArray *)gropArray {
    if (!_gropArray) {
        _gropArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _gropArray   ;
}

- (NSMutableArray *)phoneVideoArray {
    if (!_phoneVideoArray) {
        _phoneVideoArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _phoneVideoArray   ;
}

@end
