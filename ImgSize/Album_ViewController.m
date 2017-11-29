//
//  Album_ViewController.m
//  ImgSize
//
//  Created by xy on 2016/12/13.
//  Copyright © 2016年 caidan. All rights reserved.
//

#import "Album_ViewController.h"
#import "PhotoPreView.h"
#import "MBProgressHUD.h"
#import "Toast/Toast+UIView.h"
#import "UIImage+Tint.h"
#import "CTB.h"

@interface Album_ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSIndexPath *theIndexPath;
    NSMutableArray *listItems;
    CGSize imgViewSize;
    
    MBProgressHUD *hudView;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation Album_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [@"~/Library/images" stringByExpandingTildeInPath];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    
    listItems = [NSMutableArray array];
    
    hudView = [MBProgressHUD showRuningView:self.view];
    hudView.labelText = @"正在加载图片……";
    [hudView duration:0.1 action:@selector(show:) with:@(YES)];
    [CTB async:^{
        NSArray *listImgName = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString *imgName in listImgName) {
            UIImage *image = [UIImage imageFromLibrary:imgName];
            if (image) {
                image = [image imageCompressForSize:imgViewSize];
                [listItems addObject:@{@"name":imgName,@"img":image}];
            }
        }
    } complete:^{
        [_collectionView reloadData];
        [hudView hide:YES];
    }];
    
    NSArray *listName = @[@"LaunchImage-568h_en@2x.png",@"LaunchImage-568h_zh@2x.png",@"LaunchImage-800-667h_en@2x.png",@"LaunchImage-800-667h_zh@2x.png",@"LaunchImage-800-Portrait-736h_en@3x.png",@"LaunchImage-800-Portrait-736h_zh@3x.png",@"LaunchImage_en@2x.png",@"LaunchImage_zh@2x.png"];
    for (int i=0; i<listName.count; i++) {
        if (i >= 0) {
            continue;
        }
        NSString *imgName = listName[i];
        UIImage *image = [UIImage imageNamed:imgName];
        UIColor *color = [CTB colorWithHexString:@"00A0E9"];
        image = [image imageWithReplaceColor:color];
        path = [@"~/Library" stringByExpandingTildeInPath];
        path = [path stringByAppendingPathComponent:imgName];
        NSData *data = UIImagePNGRepresentation(image);
        if (data) {
            if (![data writeToFile:path atomically:YES]) {
                NSLog(@"写入失败,%ld,%@",(long)data.length,path);
            }
        }else{
            NSLog(@"操作失败");
        }
    }
}

- (void)setupSubViews
{
    self.title = @"相册";
    self.edgesForExtendedLayout = UIRectEdgeNone;//原点移动到导航栏下方
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"拍照" target:self tag:1];;
    
    if (iPhone >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = MasterColor;
    }else{
        self.navigationController.navigationBar.tintColor = MasterColor;
    }
    
    CGFloat space = 10.0f;
    CGFloat w = (Screen_Width-space*4)/3;
    imgViewSize = CGSizeMake(w, w*Screen_Height/Screen_Width);
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.minimumLineSpacing = 0;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _flowLayout.itemSize = CGSizeMake(w, imgViewSize.height+10);
    
    CGRect frame = CGRectMake(space, 0, Screen_Width-space*2, viewH);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.delaysContentTouches = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Webcam_Cell"];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger itemsCount = listItems.count;
    return itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Webcam_Cell" forIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithClass:[UIImageView class]];
    if (!imgView) {
        
        CGRect frame = CGRectMake(0, 5, 0, 0);
        frame.size = imgViewSize;
        imgView = [[UIImageView alloc] initWithFrame:frame];
        imgView.backgroundColor = [[UIColor grayColor] colorWithAlpha:0.5];
        int mode = UIViewContentModeScaleAspectFit;
        imgView.contentMode = mode;
        [cell.contentView addSubview:imgView];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableCellLongPress:)];
        longPressGR.minimumPressDuration = 1;
        [cell.contentView addGestureRecognizer:longPressGR];
    }
    
    NSDictionary *dicData = listItems[indexPath.item];
    imgView.image = [dicData objectForKey:@"img"];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dicData = listItems[indexPath.item];
    NSString *imgName = [dicData objectForKey:@"name"];
    __block UIImage *image = nil;
    
    hudView = [MBProgressHUD showRuningView:self.view];
    [hudView show:YES];
    hudView.labelText = @"正在处理图片……";
    
    [CTB async:^{
        image = [UIImage imageFromLibrary:imgName];//原始图片
    } complete:^{
        CGFloat h = Screen_Width*image.size.height/image.size.width;
        PhotoPreView *photoPreView = [[PhotoPreView alloc] init:image cropSize:GetSize(Screen_Width, h) isOnlyRead:YES delegate:self];
        photoPreView.Tag = self;
        [self presentViewController:photoPreView animated:YES completion:^{
            [hudView hide:YES];
        }];
    }];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - ========ButtonEvents========================
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            [CTB showMsg:@"设备不支持拍照功能"];
            return;
        }
        
        UIImagePickerController *imagePicker = [CTB imagePickerType:UIImagePickerControllerSourceTypeCamera delegate:self];
        imagePicker.showsCameraControls = YES;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }
}

- (UIImage *)fixRotaion:(UIImage *)image
{
    if(image.imageOrientation != UIImageOrientationUp) {
        
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    return image;
}

#pragma mark - --------获取图片实例------------------------
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    __block UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];//原始图片
    //UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"]; //编辑过的图片
    image = [self fixRotaion:image];
    
    NSString *dateStr = [NSDate stringWithFormat:@"yyyyMMdd_HHmmss"];
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *imgName = [NSString format:@"img%@@%.fx.png",dateStr,scale];
    hudView = [MBProgressHUD showRuningView:self.view];
    [hudView show:YES];
    hudView.labelText = @"正在处理图片……";
    [CTB async:^{
        NSString *path = [imgName getFilePath];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        image = [image imageCompressForSize:imgViewSize];
    } complete:^{
        [hudView hide:YES];
        [listItems addObject:@{@"name":imgName,@"img":image}];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:listItems.count-1 inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        //[_collectionView setContentOffset:CGPointMake(0, _collectionView.contentSize.height - _collectionView.frame.size.height) animated:YES];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//取消选择相处时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 长按事件
- (void)tableCellLongPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //长按触发菜单
        UIMenuItem *menuItem0 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteImage)];
        UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(saveToPhotosAlbum)];
        
        NSArray *listArray = [NSArray arrayWithObjects:menuItem0,menuItem1, nil];
        
        [self.inputView setFrame:CGRectZero];
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = listArray;
        UIView *contentView = gesture.view;
        CGRect rect = [contentView convertRect:contentView.frame toView:_collectionView];
        [menu setTargetRect:rect inView:_collectionView];
        [menu setMenuVisible:YES animated:YES];
        
        UICollectionViewCell *cell = (UICollectionViewCell *)contentView.superview;
        theIndexPath = [_collectionView indexPathForCell:cell];
    }
}

- (void)deleteImage
{
    NSDictionary *dicData = listItems[theIndexPath.item];
    NSString *imgName = [dicData objectForKey:@"name"];
    [listItems removeObjectAtIndex:theIndexPath.item];
    
    [_collectionView deleteItemsAtIndexPaths:@[theIndexPath]];
    
    NSString *filePath = [imgName getFilePath];
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (result) {
        [self.view makeToast:@"删除成功"];
    }else{
        [self.view makeToast:error.localizedDescription];
    }
}

- (void)saveToPhotosAlbum
{
    NSDictionary *dicData = listItems[theIndexPath.item];
    NSString *imgName = [dicData objectForKey:@"name"];
    UIImage *image = [UIImage imageFromLibrary:imgName];
    if (!image) {
        [self.view makeToast:@"保存失败"];
        return;
    }
    /**
     *  将图片保存到iPhone本地相册
     *  UIImage *image            图片对象
     *  id completionTarget       响应方法对象
     *  SEL completionSelector    方法
     *  void *contextInfo
     */
    hudView = [MBProgressHUD showRuningView:self.view];
    [hudView show:YES];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - 保存图片
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [hudView hide:YES];
    if (error == nil) {
        
        [self.view makeToast:@"已存入手机相册"];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        [self.view makeToast:@"保存失败"];
    }
    
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
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

@end
