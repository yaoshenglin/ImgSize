//
//  test.m
//  AppCaidan
//
//  Created by zzx on 13-10-23.
//  Copyright © 2013年 zzx. All rights reserved.
//

#import "PhotoPreView.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h> 

#pragma mark ****************PhotoMaskView********************************
#pragma ***********************************************************************

#define kMaskViewBorderWidth 2.0f

@interface PhotoMaskView : UIView
{
@private
    CGRect  _cropRect;
}
- (void)setCropSize:(CGSize)size;
- (CGSize)cropSize;
@end

@implementation PhotoMaskView

- (void)setCropSize:(CGSize)size
{
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)cropSize
{
    return _cropRect.size;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 1, 1, 1, .4);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, kMaskViewBorderWidth);
    
    CGContextClearRect(ctx, _cropRect);
}

@end

#pragma mark - ****************PhotoPreview********************************
#pragma mark *******************************************************************
@interface PhotoPreView ()
{
    BOOL isFirstShow;
}

@end

@implementation PhotoPreView

@synthesize Tag;

//创建新相簿(如果不存在)
+ (void)createGroupAlbumWithName:(NSString *)groupName
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [groups addObject:group];
        }
        else
        {
            BOOL haveHDRGroup = NO;
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:groupName])
                {
                    haveHDRGroup = YES;
                }
            }
            if (!haveHDRGroup)
            {
                //do add a group
                [assetsLibrary addAssetsGroupAlbumWithName:groupName
                                               resultBlock:^(ALAssetsGroup *group) {
                     [groups addObject:group];
                 }
                                              failureBlock:nil];
                haveHDRGroup = YES;
            }
        }
    };
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
}

//获取对应相簿下最后一张照片的信息(创建日期)
+ (NSDate *)getCreateDateLastPhoto
{
    //首先获取相册的集合
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = assetsFetchResults.firstObject;
    NSDate *date = asset.creationDate;
    NSLog(@"date = %@",date);
    
    return date;
}

+ (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                      albumName:(NSString *)groupName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __weak ALAssetsLibrary *weakSelf = assetsLibrary;
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:groupName]) {
                    [group addAsset:asset];//创建相册
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (groupName) {
            [assetsLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(weakSelf, assetURL);//不存在组时先创建相册
                }
            } failureBlock:^(NSError *error) {
                AddAsset(weakSelf, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (id)init:(UIImage *)image cropSize:(CGSize)size isOnlyRead:(BOOL)onlyRead delegate:(id)delegate
{
    self = [super init];
    if (self) {
        
        myImage = image;
        cropSize = size;
        myDelegate = delegate;
        isOnlyRead = onlyRead;
        isFirstShow = YES;
        
        CGFloat minScale = 1.0f;
        CGSize imgSize = image.size;
        if (imgSize.width < size.width || imgSize.height < size.height) {
            
            CGFloat xScale = size.width / imgSize.width;
            CGFloat yScale = size.height / imgSize.height;
            
            minScale = MAX(xScale, yScale);
            if (minScale > 10) {
                NSString *msg = NSLocalizedString(@"View_Image_Size_Min",nil);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GentleHint",nil) message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alert show];
                //[self performSelector:select(backLastPage) withObject:nil afterDelay:0.5];
            }
            
            NSString *msg = [self getStringByX:xScale Y:yScale];
            if (msg) {
                NSLog(@"%@",msg);
            }
        }
    }
    return self;
}

- (NSString *)getStringByX:(CGFloat)xScale Y:(CGFloat)yScale
{
    if (xScale <=1 && yScale <= 1) {
        return nil;
    }
    
    NSString *result = nil;
    if (yScale <= 1) {
        NSLog(@"宽度不够");
    }
    else if (xScale <= 1) {
        NSLog(@"高度不够");
    }
    else{
        NSLog(@"宽高均不够");
        if (yScale > xScale) {
        }
    }
    
    return result;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    isCroped = !CGSizeEqualToSize(cropSize, CGSizeZero);
    if (isOnlyRead) {
        
        isCroped = NO;
        myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    else {
        myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
    }
    [myScrollView setDelegate:self];
    //[myScrollView setBounces:NO];
    [myScrollView setShowsHorizontalScrollIndicator:NO];
    [myScrollView setShowsVerticalScrollIndicator:NO];
    myScrollView.alwaysBounceVertical = YES;
    myScrollView.alwaysBounceHorizontal = YES;
    myScrollView.multipleTouchEnabled = YES;
    [self.view addSubview:myScrollView];
    
    myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myImage.size.width, myImage.size.height)];
    [myScrollView addSubview:myImageView];
    
    myMaskView = [[PhotoMaskView alloc] initWithFrame:myScrollView.frame];
    [myMaskView setBackgroundColor:[UIColor clearColor]];
    [myMaskView setUserInteractionEnabled:NO];
    [self.view addSubview:myMaskView];
    [self.view bringSubviewToFront:myMaskView];
    
    if (isOnlyRead) {
        
        [myImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnImagePressed:)];
        [myImageView addGestureRecognizer:singleTap];
    }
    
    if (!isOnlyRead) {
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
        toolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPressed:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MoveAndZoom",@"") style:UIBarButtonItemStylePlain target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Confirm", nil) style:UIBarButtonItemStylePlain target:self action:@selector(btnOKPressed:)], nil];
        UIBarButtonItem *item = [[toolbar items] objectAtIndex:2];
        item.enabled = NO;
        //item.tintColor = [CTB colorWithHexString:@"#2989F2"];
        [self.view addSubview:toolbar];
    }
    
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    [activity setCenter:myScrollView.center];
    [self.view addSubview:activity];
    [self.view bringSubviewToFront:activity];
}

//添加工具栏
- (void)addToolBarWithTitles:(NSArray *)listTitle selStrings:(NSArray *)listSEL
{
    NSMutableArray *listItems = [NSMutableArray array];
    for (int i = 0; i < listTitle.count; i++) {
        NSString *title = [listTitle objectAtIndex:i];
        SEL action = NSSelectorFromString([listSEL objectAtIndex:i]);
        id target = [self respondsToSelector:action] ? self : nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
        [listItems addObject:item];
        
        if (!target) {
            item.enabled = NO;
        }
    }
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    toolbar.items = listItems;
    //item.tintColor = [CTB colorWithHexString:@"#2989F2"];
    [self.view addSubview:toolbar];
}

- (void)addToolBarWithAttributes:(NSDictionary *)attributes
{
    NSArray *listTitle = [attributes objectForKey:@"titles"];
    NSArray *listSEL = [attributes objectForKey:@"selectors"];
    NSArray *listStyles = [attributes objectForKey:@"styles"];
    
    NSMutableArray *listItems = [NSMutableArray array];
    for (int i = 0; i < listTitle.count; i++) {
        NSString *title = [listTitle objectAtIndex:i];
        UIBarButtonItemStyle style = [[listStyles objectAtIndex:i] integerValue];
        SEL action = NSSelectorFromString([listSEL objectAtIndex:i]);
        id target = [self respondsToSelector:action] ? self : nil;
        action = target ? action : nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action];
        [listItems addObject:item];
        
        if (!target) {
            item.enabled = NO;
        }
    }
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    toolbar.items = listItems;
    //item.tintColor = [CTB colorWithHexString:@"#2989F2"];
    [self.view addSubview:toolbar];
}

- (void)addToolBarWithItems:(NSArray *)items
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    toolbar.items = items;
    UIBarButtonItem *item = [[toolbar items] objectAtIndex:2];
    item.enabled = NO;
    //item.tintColor = [CTB colorWithHexString:@"#2989F2"];
    [self.view addSubview:toolbar];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [self performSelector:@selector(resetImageAndSize) withObject:nil afterDelay:0.05];
}

- (void)btnImagePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetImageAndSize
{
    myImageView.image = myImage;
    if (!isCroped) {
        
        myMaskView.hidden = YES;
        
        CGFloat width = myImage.size.width;
        CGFloat height = myImage.size.height;
        cropSize = CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.width * height/width);
    }
    [self setCropSize];    //设置图片截取区域
    [self updateZoomScale];//设置图片绽放范围
    [activity stopAnimating];
    activity.hidden = YES;
    
    //额外添加,可以视情况屏蔽掉
    //[self setRelativelyCenterBy:myScrollView];
}

#pragma mark - --------工具函数------------------------
- (UIImage *)fixRotaion:(UIImage *)image
{
    if(image.imageOrientation!=UIImageOrientationUp) {
        
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    return image;
}

#pragma mark 截取部分图像
- (UIImage *)getSubImage:(UIImage *)image rect:(CGRect)rect
{
    if (!image) return nil;
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return newImage;
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    //UIGraphicsBeginImageContext(size);
    if (&UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    }
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

#pragma mark - --------设置图片绽放范围----------------
- (void)updateZoomScale
{
    CGFloat width = myImage.size.width;
    CGFloat height = myImage.size.height;
        
    CGFloat xScale = cropSize.width / width;
    CGFloat yScale = cropSize.height / height;
    
    CGFloat min = MAX(xScale, yScale);
    CGFloat max = 1.0;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        max = 1.0 / [[UIScreen mainScreen] scale];
    }
    
    max = MAX(max, 5.0f);
    
    if (min > max) {
        min = max;
    }
    
    [myScrollView setMinimumZoomScale:min];
    [myScrollView setMaximumZoomScale:max + 5.0f];
    
    [myScrollView setZoomScale:min animated:NO];
    
    if (myImage.size.height > myImage.size.width) {
        
        //[myScrollView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - --------设置图片截取区域----------------
- (void)setCropSize
{
    CGFloat width = cropSize.width;
    CGFloat height = cropSize.height;
    
    CGFloat x = (CGRectGetWidth(self.view.bounds) - width) / 2;
    CGFloat y = (CGRectGetHeight(self.view.bounds) - height - 44) / 2;
    
    [myMaskView setCropSize:cropSize];
    
    CGFloat top = y;
    CGFloat left = x;
    CGFloat right = CGRectGetWidth(self.view.bounds)- width - x;
    CGFloat bottom = CGRectGetHeight(self.view.bounds)- height - 44 - y;
    myImageInset = UIEdgeInsetsMake(top, left, bottom, right);
    [myScrollView setContentInset:myImageInset];
}

#pragma mark - --------重新绘画图片大小----------------
- (UIImage *)cropImage
{
    CGFloat zoomScale = myScrollView.zoomScale;
    
    CGFloat offsetX = myScrollView.contentOffset.x;
    CGFloat offsetY = myScrollView.contentOffset.y;
    CGFloat aX = offsetX>=0 ? offsetX+myImageInset.left : (myImageInset.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY+myImageInset.top : (myImageInset.top - ABS(offsetY));
    
    aX = aX / zoomScale;
    aY = aY / zoomScale;
    
    CGFloat aWidth =  MAX(cropSize.width / zoomScale, cropSize.width);
    CGFloat aHeight = MAX(cropSize.height / zoomScale, cropSize.height);
    
    
    UIImage *image = [self fixRotaion:myImage];
    image = [self getSubImage:image rect:CGRectMake(aX, aY, aWidth, aHeight)];
    image = [self resizeImage:image size:cropSize];
    return image;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    //返回的视图尺寸作为scrollView的尺寸
    return myImageView;
}

- (void)setRelativelyCenterBy:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    myImageView.center = CGPointMake(scrollView.contentSize.width/2+offsetX,scrollView.contentSize.height/2+offsetY);
}

//当正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (isFirstShow) {
        isFirstShow = NO;
        [self setRelativelyCenterBy:scrollView];
    }else{
        myImageView.center = CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2);
    }
    
    myImageView.center = CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    myImageView.center = CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2);
}

#pragma mark - --------确定------------------------
- (void)btnOKPressed:(id)sender
{
    UIImage *newImage;
    if (isCroped) {
        
        newImage = [self cropImage];
    }
    else {
        newImage = [self fixRotaion:myImage];
    }
    
    if ([myDelegate respondsToSelector:@selector(photoPreView:didSelectImage:)]) {
        [myDelegate photoPreView:self didSelectImage:newImage];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏样式
        }else{
            UIColor *color = [UIColor colorWithRed:0.16 green:2.2/3 blue:0.61 alpha:1.0];
            [UINavigationBar appearance].tintColor = color;//UIColorFromRGB(0x29BB9C)
        }
    }
}

#pragma mark - --------取消------------------------
- (void)btnCancelPressed:(id)sender
{
    if ([myDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [myDelegate imagePickerControllerDidCancel:Tag];
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏样式
        }else{
            [UINavigationBar appearance].tintColor = MasterColor;
        }
    }
}

- (void)btnDeletePressed:(id)sender
{
    [self backLastPage];
    
    NSURL *url = [_info objectForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *asset = [result lastObject];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if (asset) {
            [PHAssetChangeRequest deleteAssets:@[asset]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"删除图片成功,%@",asset.creationDate);
        }else{
            NSLog(@"删除图片失败,Error: %@", error);
        }
        
        NSLog(@"删除图片,%@",url);
        if ([myDelegate respondsToSelector:@selector(photoPreView:didDeleteWithInfo:)]) {
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info.dictionary = _info;
            [info setObject:asset.creationDate forKey:@"createDate"];
            [info setObject:@(success) forKey:@"success"];
            [myDelegate photoPreView:self didDeleteWithInfo:info];
        }
    }];
}

- (void)backLastPage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
