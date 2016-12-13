//
//  Album_ViewController.m
//  ImgSize
//
//  Created by xy on 2016/12/13.
//  Copyright © 2016年 caidan. All rights reserved.
//

#import "Album_ViewController.h"
#import "PhotoPreView.h"
#import "CTB.h"

@interface Album_ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray *listItems;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation Album_ViewController

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout)
    {
        CGFloat w = (Screen_Width-40)/3;
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.itemSize = CGSizeMake(w, w*Screen_Height/Screen_Width+10);
    }
    return _flowLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    [self setupSubViews];
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
    listItems.array = [fileManager contentsOfDirectoryAtPath:path error:nil];
}

- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"拍照" target:self tag:1];;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    collectionView.bounces = NO;
    collectionView.scrollEnabled = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.delaysContentTouches = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
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
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithClass:[UIImageView class]];
    if (!cell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Webcam_Cell" forIndexPath:indexPath];
        
        CGRect frame = CGRectMake(5, 5, 0, 0);
        frame.size = self.flowLayout.itemSize;
        frame.size.height = frame.size.height - 10;
        imgView = [[UIImageView alloc] initWithFrame:frame];
        imgView.backgroundColor = [[UIColor grayColor] colorWithAlpha:0.5];
        int mode = UIViewContentModeScaleAspectFit;
        imgView.contentMode = mode;
        [cell.contentView addSubview:imgView];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableCellLongPress:)];
        longPressGR.minimumPressDuration = 1;
        [imgView addGestureRecognizer:longPressGR];
    }
    
    UIImage *image = [UIImage imageFromLibrary:listItems[indexPath.item]];
    if (image) {
        imgView.image = image;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithClass:[UIImageView class]];
    UIImage* image = imgView.image;//原始图片
    //UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"]; //编辑过的图片
    
    PhotoPreView *photoPreView = [[PhotoPreView alloc] init:image cropSize:GetSize(150, 150) isOnlyRead:YES delegate:self];
    photoPreView.Tag = self;
    // 显示状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self presentViewController:photoPreView animated:YES completion:nil];
}

#pragma mark - ========ButtonEvents========================
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            [CTB showMsg:@"设备不支持拍照功能"];
            return;
        }
        
        [CTB imagePickerType:UIImagePickerControllerSourceTypeCamera delegate:self];
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
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];//原始图片
    //UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"]; //编辑过的图片
    image = [self fixRotaion:image];
    
    NSString *dateStr = [NSDate stringWithFormat:@"yyyyMMdd_HHmmss"];
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *imgName = [NSString format:@"img%@@%.fx.png",dateStr,scale];
    NSString *path = [imgName getFilePath];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
    
    path = [@"~/Library/images" stringByExpandingTildeInPath];
    listItems.array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    [_collectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 显示状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    //***********获取图片名字*******************
}

//取消选择相处时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)photoPreView:(PhotoPreView *)photoPreView didSelectImage:(UIImage *)image
//{
//    NSString *dateStr = [NSDate stringWithFormat:@"yyyyMMdd_HHmmss"];
//    CGFloat scale = [UIScreen mainScreen].scale;
//    NSString *imgName = [NSString format:@"img%@@%.fx.png",dateStr,scale];
//    NSString *path = [imgName getFilePath];
//    NSData *data = UIImagePNGRepresentation(image);
//    [data writeToFile:path atomically:YES];
//    
//    path = [@"~/Library/images" stringByExpandingTildeInPath];
//    listItems.array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
//    [_collectionView reloadData];
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - 长按事件
- (void)tableCellLongPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //长按触发菜单
        UIMenuItem *menuItem0 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteImage)];
        
        NSArray *listArray = [NSArray arrayWithObjects:menuItem0, nil];
        
        [self.inputView setFrame:CGRectZero];
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = listArray;
        UIImageView *imgView = (UIImageView *)gesture.view;
        CGRect rect = [imgView.superview convertRect:imgView.frame toView:_collectionView];
        [menu setTargetRect:rect inView:_collectionView];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)deleteImage
{
    
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
