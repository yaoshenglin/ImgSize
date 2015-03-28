//
//  test.m
//  AppCaidan
//
//  Created by zzx on 13-10-23.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import "PhotoPreView.h"
#import "CTB.h"


#pragma ***********************************************************************************************
#pragma mark PhotoMaskView
#pragma ***********************************************************************************************

#define kMaskViewBorderWidth 2.0f

@interface PhotoMaskView : UIView {
@private
    CGRect  _cropRect;
}
- (void)setCropSize:(CGSize)size;
- (CGSize)cropSize;
@end

@implementation PhotoMaskView

- (void)setCropSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)cropSize {
    return _cropRect.size;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 1, 1, 1, .4);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, kMaskViewBorderWidth);
    
    CGContextClearRect(ctx, _cropRect);
}
@end

#pragma ***********************************************************************************************
#pragma mark PhotoPreview
#pragma ***********************************************************************************************
@interface PhotoPreView ()

@end

@implementation PhotoPreView

@synthesize Tag;

- (id)init:(UIImage *)image cropSize:(CGSize)size isOnlyRead:(BOOL)onlyRead delegate:(id<PhotoPreViewDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        myImage = image;
        cropSize = size;
        myDelegate = delegate;
        isOnlyRead = onlyRead;
    }
    return self;
}


- (void)viewDidLoad {
    
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
    [myScrollView setBounces:NO];
    [myScrollView setShowsHorizontalScrollIndicator:NO];
    [myScrollView setShowsVerticalScrollIndicator:NO];
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
                         [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPressed:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"移动和缩放" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPressed:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(btnOKPressed:)], nil];
        [self.view addSubview:toolbar];
    }
    
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    [activity setCenter:myScrollView.center];
    [self.view addSubview:activity];
    [self.view bringSubviewToFront:activity];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [self performSelector:@selector(resetImageAndSize) withObject:nil afterDelay:0.05];
}

- (void)btnImagePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetImageAndSize {
    
    myImageView.image = myImage;
    if (!isCroped) {
        
        myMaskView.hidden = YES;
        
        CGFloat width = myImage.size.width;
        CGFloat height = myImage.size.height;
        cropSize = CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.width * height/width);
    }
    [self setCropSize];
    [self updateZoomScale];
    [activity stopAnimating];
    activity.hidden = YES;
}

#pragma mark - ========确定=====================
- (void)btnOKPressed:(id)sender {
    
    if (isCroped) {
        
        UIImage *newImage = [self cropImage];
        [myDelegate photoPreView:self didSelectImage:newImage];
    }
    else {
        [myDelegate photoPreView:self didSelectImage:[CTB fixRotaion:myImage]];
    }
}

#pragma mark - ========取消=====================
- (void)btnCancelPressed:(id)sender {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [myDelegate imagePickerControllerDidCancel:Tag];
}

- (void)updateZoomScale {
    
    CGFloat width = myImage.size.width;
    CGFloat height = myImage.size.height;
        
    CGFloat xScale = cropSize.width / width;
    CGFloat yScale = cropSize.height / height;
    
    CGFloat min = MAX(xScale, yScale);
    CGFloat max = 1.0;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        max = 1.0 / [[UIScreen mainScreen] scale];
    }
    
    if (min > max) {
        min = max;
    }
    
    [myScrollView setMinimumZoomScale:min];
    [myScrollView setMaximumZoomScale:max + 5.0f];
    
    [myScrollView setZoomScale:min animated:NO];
    
    if (myImage.size.height > myImage.size.width) {
        
        [myScrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)setCropSize {
    
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

- (UIImage *)cropImage {
    
    CGFloat zoomScale = myScrollView.zoomScale;
    
    CGFloat offsetX = myScrollView.contentOffset.x;
    CGFloat offsetY = myScrollView.contentOffset.y;
    CGFloat aX = offsetX>=0 ? offsetX+myImageInset.left : (myImageInset.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY+myImageInset.top : (myImageInset.top - ABS(offsetY));
    
    aX = aX / zoomScale;
    aY = aY / zoomScale;
    
    CGFloat aWidth =  MAX(cropSize.width / zoomScale, cropSize.width);
    CGFloat aHeight = MAX(cropSize.height / zoomScale, cropSize.height);
    
    
    UIImage *image = [CTB fixRotaion:myImage];
    image = [CTB getSubImage:image rect:CGRectMake(aX, aY, aWidth, aHeight)];
    image = [CTB resizeImage:image size:cropSize];
    return image;
}
//2013-10-23 11:42:35.856 AppCaidan[21718:707] UIImageOrientationRight
//2013-10-23 11:42:47.264 AppCaidan[21718:707] UIImageOrientationUp
//2013-10-23 11:42:58.359 AppCaidan[21718:707] UIImageOrientationLeft
//2013-10-23 11:43:12.767 AppCaidan[21718:707] UIImageOrientationDown

#pragma UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    //返回的视图尺寸作为scrollView的尺寸
    return myImageView;
}

@end
