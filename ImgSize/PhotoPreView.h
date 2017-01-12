//
//  test.h
//  AppCaidan
//
//  Created by zzx on 13-10-23.
//  Copyright © 2013年 zzx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPreViewDelegate;
@class PhotoMaskView;
@interface PhotoPreView : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *myScrollView;
    UIImageView *myImageView;
    PhotoMaskView *myMaskView;
    UIImage *myImage;
    UIEdgeInsets myImageInset;
    CGSize cropSize;
    UIActivityIndicatorView *activity;
    
    BOOL isCroped;
    __weak id<PhotoPreViewDelegate> myDelegate;
    BOOL isOnlyRead;
}

@property (nonatomic, weak) id Tag;
@property (nonatomic, retain) NSDictionary *info;//相册信息

+ (NSDate *)getCreateDateLastPhoto;
+ (void)saveToAlbumWithImage:(UIImage *)image albumName:(NSString *)title completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;

- (id)init:(UIImage *)image cropSize:(CGSize)size isOnlyRead:(BOOL)onlyRead delegate:(id)delegate;
- (void)addToolBarWithTitles:(NSArray *)listTitle selStrings:(NSArray *)listSEL;//添加工具栏
- (void)addToolBarWithAttributes:(NSDictionary *)attributes;
- (void)addToolBarWithItems:(NSArray *)items;

@end


@protocol PhotoPreViewDelegate <NSObject>

@optional
- (void)photoPreView:(PhotoPreView*)photoPreView didSelectImage:(UIImage *)image;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)photoPreView:(PhotoPreView *)photoPreView didDeleteWithInfo:(NSDictionary *)info;

@end
