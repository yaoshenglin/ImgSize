//
//  CTB.m
//  baiduMap
//
//  Created by yinhaibo on 14-1-3.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "CTB.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <netdb.h>
#import <objc/runtime.h>//对象转Dic用
#include <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/CaptiveNetwork.h>//获取WiFi信息

@interface CTB () <UIAlertViewDelegate,UITableViewDelegate>

@end

@implementation CTB

//+ (CTB *)getInstance
//{
//    static dispatch_once_t once;
//    static CTB *sharedInstance;
//    dispatch_once(&once, ^ {
//        sharedInstance = [[CTB alloc] init];
//    });
//    return sharedInstance;
//}

+ (id)getControllerWithIdentity:(NSString *)identifier storyboard:(NSString *)title
{
    UIStoryboard *storyBoard = nil;
    if (title==NULL) {
        //应用程序的名称和版本号等信息都保存在mainBundle的一个字典中，用下面代码可以取出来。
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        
        title = [infoDict objectForKey:@"UIMainStoryboardFile"];
        storyBoard = [UIStoryboard storyboardWithName:title bundle:nil];
    }else{
        storyBoard = [UIStoryboard storyboardWithName:title bundle:nil];
    }
    if (storyBoard == NULL) {
        return NULL;
    }
    
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

id getController(NSString *identifier,NSString *title)
{
    UIStoryboard *storyBoard = nil;
    if (!title || title.length <= 0) {
        //应用程序的名称和版本号等信息都保存在mainBundle的一个字典中，用下面代码可以取出来。
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        title = [infoDict objectForKey:@"UIMainStoryboardFile"];
    }
    
    storyBoard = [UIStoryboard storyboardWithName:title bundle:nil];
    
    if (storyBoard == NULL) {
        return NULL;
    }
    
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

+ (UIViewController *)getControllerFrom:(UINavigationController *)Nav className:(NSString *)className
{
    if (![Nav isKindOfClass:[UINavigationController class]]) {
        return NULL;
    }
    
    NSArray *listNav = Nav.viewControllers;
    for (UIViewController *V in listNav) {
        if ([NSStringFromClass(V.class) isEqualToString:className]) {
            return V;
        }
    }
    
    return NULL;
}

UIViewController *getControllerFrom(UINavigationController *Nav,NSString *className)
{
    if (![Nav isKindOfClass:[UINavigationController class]]) {
        return NULL;
    }
    
    NSArray *listNav = Nav.viewControllers;
    for (UIViewController *V in listNav) {
        if ([NSStringFromClass(V.class) isEqualToString:className]) {
            return V;
        }
    }
    
    return NULL;
}

UIViewController *getControllerFor(UIViewController *VC,NSString *className)
{
    UINavigationController *Nav = VC.navigationController;
    if (![Nav isKindOfClass:[UINavigationController class]]) {
        return NULL;
    }
    
    NSArray *listNav = Nav.viewControllers;
    for (UIViewController *V in listNav) {
        if ([NSStringFromClass(V.class) hasPrefix:className]) {
            //类名相同
            if (V != VC) {
                //排除自己
                return V;
            }
        }
    }
    
    return NULL;
}

UIViewController *getParentController(UIViewController *VC,NSString *className)
{
    if (![VC isKindOfClass:[UIViewController class]]) {
        return NULL;
    }
    
    UIViewController *result = nil;
    for (UIViewController *V = VC.parentViewController; V; V = V.parentViewController) {
        if ([NSStringFromClass(V.class) isEqualToString:className]) {
            result = V;
            break;
        }
    }
    
    return result;
}

+ (void)removeClassWithName:(NSString *)className fromNav:(UINavigationController *)Nav
{
    if (![Nav isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    NSArray *listNav = Nav.viewControllers;
    NSMutableArray *listResult = [NSMutableArray arrayWithArray:listNav];
    for (UIViewController *V in listNav) {
        if ([NSStringFromClass(V.class) isEqualToString:className]) {
            [V.view removeFromSuperview];
            [listResult removeObject:V];
        }
    }
    
    [Nav setViewControllers:listResult animated:YES];
}

+ (void)removeController:(UIViewController *)viewController fromNav:(UINavigationController *)Nav
{
    if (![Nav isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    NSArray *listNav = Nav.viewControllers;
    NSMutableArray *listResult = [NSMutableArray arrayWithArray:listNav];
    for (UIViewController *V in listNav) {
        if (V == viewController) {
            [V.view removeFromSuperview];
            [listResult removeObject:V];
        }
    }
    
    [Nav setViewControllers:listResult animated:YES];
}

void forbiddenNavPan(UIViewController *VC,BOOL isForbid)
{
    if (iPhone >= 7) {
        VC.navigationController.interactivePopGestureRecognizer.enabled = !isForbid;
    }
}

+ (UIWindow *)getWindow
{
    //活跃的window
    NSArray *listWindow = [[UIApplication sharedApplication] windows];
    return [listWindow firstObject];
}

+ (void)ButtonEvents:(UIButton *)button
{
//    NSLog(@"请注意此方法");
}

- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        [CTB alertWithMessage:@"你确定要退出吗" Delegate:self tag:1];
    }
}

#pragma mark - --------按钮UIButton------------------------
+ (UIButton *)buttonType:(UIButtonType)type delegate:(id)delegate to:(UIView *)View tag:(NSInteger)tag title:(NSString *)title img:(NSString *)imgName
{
    type = type ?: UIButtonTypeCustom;
    UIButton *button = [UIButton buttonWithType:type];
    button.tag = tag;
    button.clipsToBounds = YES;
    
    button.backgroundColor = [UIColor whiteColor];
    
    if (type==UIButtonTypeCustom) {
        button.backgroundColor = [UIColor clearColor];//透明背景色
    }
    
    [button setTitle:title forState:UIControlStateNormal];//按钮上的文字
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//黑色字体
    button.titleLabel.textAlignment = NSTextAlignmentCenter;//居中
    
    if (imgName.length>0) {
        NSArray *listSort = [imgName componentsSeparatedByString:@"/"];
        UIControlState controlType = UIControlStateNormal;
        if (listSort.count > 1) {
            controlType = [listSort[1] intValue];
            [button setTitleColor:[UIColor whiteColor] forState:controlType];
        }
        
        UIImage *img = [UIImage imageNamed:listSort.firstObject];
        [button setBackgroundImage:img forState:controlType];
    }else{
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    if ([delegate respondsToSelector:select(ButtonEvents:)]) {
        [button addTarget:delegate action:select(ButtonEvents:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self ButtonEvents:button];
    }
    [View addSubview:button];
    
    return button;
}

+ (UIButton *)buttonType:(UIButtonType)type delegate:(id)delegate to:(UIView *)View tag:(NSInteger)tag title:(NSString *)title img:(NSString *)imgName action:(SEL)action
{
    UIButton *button = [[self class] buttonType:type delegate:nil to:View tag:tag title:title img:imgName];
    if ([delegate respondsToSelector:action]) {
        [button addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    return button;
}

+ (UISearchBar *)searchBarStyle:(UISearchBarStyle)style tintColor:(UIColor *)tintColor toV:(UIView *)View delegate:(id)delegate
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.delegate = delegate;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.clipsToBounds = YES;
    //searchBar.barStyle = UIBarStyleBlackTranslucent;
    
    if (iPhone >= 7) {
        searchBar.searchBarStyle = style;
        searchBar.barTintColor = tintColor;
    }
    
    [View addSubview:searchBar];
    
    return searchBar;
}

+ (void)addTarget:(id)delegate action:(SEL)action button:(UIButton *)button, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, button);
    
    // get rest of the objects until nil is found
    for (UIButton *btn = button; btn != nil; btn = va_arg(args,UIButton *)) {
        [btn addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    va_end(args);
}

+ (void)addDownTarget:(id)delegate action:(SEL)action button:(UIButton *)button, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, button);
    
    // get rest of the objects until nil is found
    for (UIButton *btn = button; btn != nil; btn = va_arg(args,UIButton *)) {
        [btn addTarget:delegate action:action forControlEvents:UIControlEventTouchDown];
    }
    
    va_end(args);
}

+ (void)setTextColor:(UIColor *)color View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *v = View; v != nil; v = va_arg(args,UIView *)) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            [btn setTitleColor:color forState:UIControlStateNormal];
        }
        else if ([v isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)v;
            lbl.textColor = color;
        }
    }
    
    va_end(args);
}

#pragma mark 设置圆角
+ (void)setRadius:(CGFloat)radius View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *v = View; v != nil; v = va_arg(args,UIView *)) {
        v.clipsToBounds ? (void)v : (void)(v.clipsToBounds = YES);
        v.layer.cornerRadius = radius;
    }
    
    va_end(args);
}

+ (void)setBorderWidth:(CGFloat)width View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *v = View; v != nil; v = va_arg(args,UIView *)) {
        v.layer.borderWidth = width;
        v.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    }
    
    va_end(args);
}

+ (void)setBorderWidth:(CGFloat)width Color:(UIColor *)color View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *v = View; v != nil; v = va_arg(args,UIView *)) {
        v.layer.borderWidth = width;
        v.layer.borderColor = color.CGColor;
    }
    
    va_end(args);
}

//按钮底部添加线条
+ (void)setBottomLineToBtn:(id)button, ...
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, button);
    
    // get rest of the objects until nil is found
    for (UIButton *btn = button; btn != nil; btn = va_arg(args,UIButton *)) {
        if ([btn isKindOfClass:[UIButton class]]) {
            UIView *lineView = [btn viewWITHTag:99];
            if (!lineView) {
                lineView = [[UIView alloc] initWithFrame:GetRect(0, GetVHeight(btn)-1, GetVWidth(btn), 1)];
                lineView.tag = 99;
                lineView.backgroundColor = [UIColor grayColor];
                [btn addSubview:lineView];
            }
            
            lineView.hidden = NO;
        }
    }
    
    va_end(args);
}

+ (void)setBottomLineHigh:(CGFloat)high Color:(UIColor *)color toV:(id)button, ...
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, button);
    
    // get rest of the objects until nil is found
    for (UIButton *btn = button; btn != nil; btn = va_arg(args,UIButton *)) {
        if ([btn isKindOfClass:[UIButton class]]) {
            UIView *lineView = [btn viewWithTag:99];
            if (!lineView) {
                lineView = [[UIView alloc] initWithFrame:GetRect(0, GetVHeight(btn)-high, GetVWidth(btn), high)];
                lineView.tag = 99;
                lineView.backgroundColor = color;
                [btn addSubview:lineView];
            }
            
            lineView.hidden = NO;
        }
    }
    
    va_end(args);
}

//设置左边text间距
+ (void)setLeftViewWithWidth:(CGFloat)w textField:(UITextField *)textField, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, textField);
    
    // get rest of the objects until nil is found
    for (UITextField *v = textField; v != nil; v = va_arg(args,UITextField *)) {
        v.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        v.leftViewMode = UITextFieldViewModeAlways;
    }
    
    va_end(args);
}

#pragma mark 添加圆角,设置边框和边框颜色
+ (void)drawBorder:(UIView *)view radius:(float)radius borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor
{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    [layer setBorderWidth:borderWidth];
    [layer setBorderColor:[borderColor CGColor]];
}

+ (void)setHidden:(BOOL)hidden View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *v = View; v != nil; v = va_arg(args,UIView *)) {
        v.hidden = hidden;
    }
    
    va_end(args);
}

#pragma mark - ==========UIBarButtonItem===================
+ (UIBarButtonItem *)BarButtonWithTitle:(NSString *)title target:(id)target tag:(NSUInteger)tag
{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:select(ButtonEvents:)];
    BtnItem.tag = tag;
    return BtnItem;
}

+ (UIBarButtonItem *)BackBarButtonWithTitle:(NSString *)title
{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithStyle:(UIBarButtonSystemItem)style target:(id)target tag:(NSUInteger)tag
{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:select(ButtonEvents:)];
    BtnItem.tag = tag;
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithImg:(UIImage *)image target:(id)target tag:(NSUInteger)tag
{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:select(ButtonEvents:)];
    BtnItem.tag = tag;
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag
{
    UIImage *image = [UIImage imageNamed:imgName];
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:select(ButtonEvents:)];
    BtnItem.tag = tag;
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithBtnImg:(UIImage *)image target:(id)target tag:(NSUInteger)tag
{
    UIButton *btnBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBar setImage:image forState:UIControlStateNormal];
    btnBar.tag = tag;
    btnBar.frame = CGRectMake(12, 12, 20, 20);
    [btnBar addTarget:target action:@selector(ButtonEvents:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnBar];
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithBtnImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag
{
    UIImage *image = [UIImage imageNamed:imgName];
    UIButton *btnBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBar setImage:image forState:UIControlStateNormal];
    btnBar.tag = tag;
    btnBar.frame = CGRectMake(12, 12, 20, 20);
    [btnBar addTarget:target action:@selector(ButtonEvents:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnBar];
    return BtnItem;
}

+ (UIBarButtonItem *)BarWithBtnImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag rect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:imgName];
    UIButton *btnBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBar setImage:image forState:UIControlStateNormal];
    btnBar.tag = tag;
    btnBar.frame = rect;
    [btnBar addTarget:target action:@selector(ButtonEvents:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnBar];
    return BtnItem;
}

+ (UIBarButtonItem *)BarButtonWithCustomView:(UIView *)View
{
    UIBarButtonItem *BtnItem = [[UIBarButtonItem alloc] initWithCustomView:View];
    return BtnItem;
}

+ (UIBarButtonItem *)BarWithWidth:(CGFloat)w title:(NSString *)title
{
    UILabel *lblNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    lblNavTitle.text = title;
    lblNavTitle.textAlignment = NSTextAlignmentLeft;
    lblNavTitle.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:lblNavTitle];
    return barItem;
}

+ (UIBarButtonItem *)BarWithTitle:(NSString *)title delegate:(id)delegate action:(SEL)action
{
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *imgBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"顶部左上角返回按钮"]];
    imgBack.center = CGPointMake(6, 22);
    [btnBack addSubview:imgBack];
    
    UIImageView *imgLeaf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"叶子大"]];
    imgLeaf.center = CGPointMake(33, 22);
    [btnBack addSubview:imgLeaf];
    
    UILabel *lblTitle = [CTB labelTag:1 toView:btnBack text:title wordSize:15];
    lblTitle.frame = CGRectMake(50, 0, 60, 44);
    lblTitle.textAlignment = NSTextAlignmentLeft;
    CGSize size = [CTB getSizeWith:title wordSize:15 size:CGSizeMake(200, 44)];
    [lblTitle setSizeToW:size.width];
    btnBack.frame = CGRectMake(0, 0, 66+size.width, 44);
    
    [btnBack addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    return barItem;
}

+ (NSArray *)BarButtonWithTitles:(NSArray *)array delegate:(id)delegate
{
    NSMutableArray *result = [NSMutableArray array];
    if (array.count>1) {
        for (int i=0; i<array.count-1; i++) {
            NSArray *arrData = [array[i] componentsSeparatedByString:@"/"];
            NSString *title = arrData.count>0 ? arrData[i] : @"";
            NSInteger tag = arrData.count>1 ? [arrData[1] intValue] : 1;
            UIBarButtonItem *ItemRight = [CTB BarButtonWithTitle:title target:delegate tag:tag];
            [result addObject:ItemRight];
        }
    }
    
    if (array.count>0) {
        NSArray *arrData = [[array lastObject] componentsSeparatedByString:@"/"];
        NSString *title = arrData.count>0 ? arrData[0] : @"";
        CGFloat w = Screen_Width - (70+32*(array.count-1));
        UIBarButtonItem *ItemTitle = [CTB BarWithWidth:w title:title];
        [result addObject:ItemTitle];
    }
    
    return result;
}

+ (NSArray *)BarButtonWithImgs:(NSArray *)array delegate:(id)delegate
{
    NSMutableArray *result = [@[] mutableCopy];
    if (array.count>1) {
        for (int i=0; i<array.count-1; i++) {
            NSArray *arrData = [array[i] componentsSeparatedByString:@"/"];
            NSString *imgName = arrData.count>0 ? arrData[i] : @"";
            NSInteger tag = arrData.count>1 ? [arrData[1] intValue] : 1;
            UIBarButtonItem *ItemRight = [CTB BarButtonWithBtnImgName:imgName target:delegate tag:tag];
            [result addObject:ItemRight];
        }
    }
    
    if (array.count>0) {
        NSArray *arrData = [[array lastObject] componentsSeparatedByString:@"/"];
        NSString *title = arrData.count>0 ? arrData[0] : @"";
        CGFloat w = Screen_Width - (70+32*(array.count-1));
        UIBarButtonItem *ItemTitle = [CTB BarWithWidth:w title:title];
        [result addObject:ItemTitle];
    }
    
    return result;
}

+ (void)tabBarTextColor:(UIColor *)aColor selected:(UIColor *)bColor
{
    //UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:13.0f];
    //NSValue *TextShadowOffset = [NSValue valueWithUIOffset:UIOffsetMake(0.0f,1.0f)];
    NSDictionary *dic = @{UITextAttributeTextColor:aColor};
    //设置tabbar字体颜色(未选中)
    [[UITabBarItem appearance] setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    dic = @{UITextAttributeTextColor:bColor};
    //设置tabbar字体颜色(选中)
    [[UITabBarItem appearance] setTitleTextAttributes:dic forState:UIControlStateSelected];
}

#pragma mark - ========实用TextField==============================
+ (UITextField *)createTextField:(int)tag hintTxt:(NSString *)placeholder V:(UIView *)View
{
    CGFloat h=tag*80-20;
    CGRect rect=CGRectMake(10, h, 300, 40);
    
    UIView *FieldView = [[UIView alloc] initWithFrame:rect];
    FieldView.backgroundColor = [UIColor whiteColor];
    FieldView.layer.cornerRadius = 5;
    [View addSubview:FieldView];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor clearColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [FieldView addSubview:textField];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 40)];
    label.text = [NSString stringWithFormat:@"%@:",placeholder];
    label.textAlignment = NSTextAlignmentRight;
    [FieldView addSubview:label];
    
    return textField;
}

#pragma mark - =========Label=============================
+ (UILabel *)labelTag:(int)tag toView:(UIView *)View text:(NSString *)text wordSize:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = tag;
    label.text = text;
    label.layer.masksToBounds = YES;//约束边界
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;    //默认为居中显示
    label.backgroundColor = [UIColor clearColor];   //默认为透明背景
    if (size > -1) {
        label.font = [UIFont systemFontOfSize:size];
    }
    [View addSubview:label];
    
    return label;
}

+ (UILabel *)labelTag:(int)tag toView:(UIView *)View text:(NSString *)text wordSize:(CGFloat)size alignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[self class] labelTag:tag toView:View text:text wordSize:size];
    label.textAlignment = textAlignment;
    return label;
}

#pragma mark - ========TextField==============================
+ (UITextField *)textFieldTag:(int)tag holderTxt:(NSString *)placeholder V:(UIView *)View delegate:(id)delegate
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.tag = tag;
    textField.delegate = delegate;
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = placeholder;//暗示
    textField.clipsToBounds = YES;
    textField.font = [UIFont systemFontOfSize:17];
    //textField.adjustsFontSizeToFitWidth = YES;//自适应
    textField.borderStyle = UITextBorderStyleNone;//无圆角(系统默认)
    textField.keyboardType = UIKeyboardTypeDefault;//(系统默认)
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;//清除按钮
    textField.autocorrectionType = UITextAutocorrectionTypeNo;//不自动更正
    //textField.autocapitalizationType = UITextAutocapitalizationTypeWords;//首字母大写
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//在垂直方向上居中
    textField.returnKeyType = UIReturnKeyDone;//Done(完成)
    textField.secureTextEntry = NO;//非密码显示(系统默认)
    [View addSubview:textField];
    return textField;
}

#pragma mark - ========分段控件==============================
+ (UISegmentedControl *)segmentedTag:(int)tag Itmes:(NSArray *)items toView:(UIView *)View
{
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:items];
    //segControl.segmentedControlStyle = UISegmentedControlStyleBar;//UISegmentedControlStyleBar
    segControl.tintColor = [UIColor blueColor];
    segControl.selectedSegmentIndex=1;
    [View addSubview:segControl];
    return segControl;
}

#pragma mark - ========UITableView==============================
+ (UITableView *)tableViewStyle:(UITableViewStyle)style delegate:(id)delegate toV:(UIView *)View
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    tableView.dataSource = delegate;
    tableView.delegate = delegate;
    [View addSubview:tableView];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    
    tableView.separatorColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.sectionIndexColor = colorWithHex(@"0x29BB9C");//索引文字颜色
    if (iPhone >= 7) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];//索引栏背景色
    }
    
    return tableView;
}

+ (id)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = @"参数错误";
    
    return cell;
}

+ (void)showFinishView:(UITableView *)tableView
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIView *finishView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 49)];
    //finishView.backgroundColor = [CTB colorWithHexString:@"#E7E7E7"];
    
    UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, size.width-40, 20)];
    lblStatus.text = @"已加载全部数据";
    lblStatus.font = [UIFont systemFontOfSize:15];
    lblStatus.textColor = [UIColor grayColor];
    lblStatus.textAlignment = NSTextAlignmentCenter;
    [finishView addSubview:lblStatus];
    
    tableView.tableFooterView = finishView;
}

//创建动画视图
+ (UIWebView *)gifViewInitWithFile:(NSString *)Path
{
    NSData *gifData = [NSData dataWithContentsOfFile:Path];
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    webView.scrollView.scrollEnabled = NO;
    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    
    webView.opaque = NO;

    return webView;
}

#pragma mark - ========UIImagePickerController==============================
+ (UIImagePickerController *)imagePickerType:(UIImagePickerControllerSourceType)sourceType delegate:(id)delegate
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.allowsEditing = YES;
    imagePicker.delegate = delegate;
    imagePicker.sourceType = sourceType;
    if (iPhone >= 7) {
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    if ([delegate respondsToSelector:select(presentViewController:animated:completion:)]) {
        [delegate presentViewController:imagePicker animated:YES completion:nil];
    }
    
    return imagePicker;
}

#pragma mark - ========UIAlertView==============================
+ (UIAlertView *)showMsgWithTitle:(NSString *)title msg:(NSString *)msg
{
    title = title.length>0 ? title : @"确定";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.tag=0;
    [alert show];
    return alert;
}

+ (UIAlertView *)showMsg:(NSString *)msg
{
    if (!msg || [msg isKindOfClass:[NSNull class]]) {
        msg = @"";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.tag = 0;
    [alert show];
    return alert;
}

+ (UIAlertView *)showMsg:(NSString *)msg tag:(int)tag delegate:(id)delegate
{
    if (!msg || [msg isKindOfClass:[NSNull class]]) {
        msg = @"";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    [alert show];
    return alert;
}

+ (UIAlertView *)alertWithTitle:(NSString *)title Delegate:(id)delegate tag:(int)tag
{
    NSString *cancelTitle = delegate ? @"取消" : nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:@"确定", nil];
    alert.delegate = delegate;
    alert.tag = tag;
    [alert show];
    return alert;
}

+ (UIAlertView *)alertWithMessage:(NSString *)message Delegate:(id)delegate tag:(int)tag
{
    NSString *cancelTitle = delegate ? @"取消" : nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:@"确定", nil];
    alert.delegate = delegate;
    alert.tag = tag;
    [alert show];
    return alert;
}

+ (UIAlertView *)alertWithTitle:(NSString *)title msg:(NSString *)message Delegate:(id)delegate tag:(int)tag
{
    NSString *cancelTitle = delegate ? @"取消" : nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:@"确定", nil];
    alert.delegate = delegate;
    alert.tag = tag;
    [alert show];
    return alert;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        exit(0);
    }
}

#pragma mark 设置TextFiled背景框
+ (void)setTextFieldsBackground:(UITextField *)textField, ...
{
    UITextField* eachTextField;
    va_list argumentList;
    
    if (textField) {
        
        UIImage *bubble = [UIImage imageNamed:@"输入框.png"];
        UIImage *textBackground = [bubble stretchableImageWithLeftCapWidth:21 topCapHeight:30];
        
        [CTB setTextFieldLeftLabel:textField text:@"" width:6 font:nil alignment:NSTextAlignmentLeft textColor:nil];
        textField.background = textBackground;
        textField.backgroundColor = [UIColor clearColor];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        va_start(argumentList, textField);
        while ((eachTextField = va_arg(argumentList, UITextField *))) {
            
            [CTB setTextFieldLeftLabel:eachTextField text:@"" width:6 font:nil alignment:NSTextAlignmentLeft textColor:nil];
            eachTextField.background = textBackground;
            eachTextField.backgroundColor = [UIColor clearColor];
            eachTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        }
        va_end(argumentList);
    }
}

+ (void)setTextFieldLeftLabel:(UITextField *)textField text:(NSString *)text width:(float)width font:(UIFont *)font alignment:(NSTextAlignment)alignment textColor:(UIColor *)textColor
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, textField.bounds.size.height)];
    lbl.text = text;
    lbl.backgroundColor = [UIColor clearColor];
    if (font) {
        lbl.font = font;
    }
    else {
        lbl.font = textField.font;
    }
    if (textColor) {
        lbl.textColor = textColor;
    }
    else {
        lbl.textColor = [UIColor darkGrayColor];
    }
    lbl.textAlignment = alignment;
    textField.leftView = lbl;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString *)trimTextField:(UITextField *)textField
{
    if (!textField || !textField.text) {
        return @"";
    }
    
    return [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark 将a视图添加到b视图上
+ (void)addView:(UIView *)aView toView:(UIView *)bView
{
    bView.layer.masksToBounds = YES;
    aView.frame = CGRectMake(0, 0, bView.frame.size.width, bView.frame.size.height);
}

#pragma mark - =============从指定的视图上获取想要的视图类============================
id getSuperView(Class aClass,UIView *View)
{
    id obj = nil;
    for (UIResponder* next = View.nextResponder; next; next = next.nextResponder) {
        
        if ([next isKindOfClass:aClass]) {
            obj = next;
            break;
        }
    }
    
    return obj;
}

id getSuperViewBy(Class aClass,UIView *View,NSInteger tag)
{
    id obj = nil;
    for (UIView* next = [View superview]; next; next = next.superview) {
        
        if ([next isKindOfClass:aClass]) {
            obj = next;
            break;
        }
        
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:aClass] && [(UIView *)nextResponder tag] == tag) {
            obj = (UITableViewCell *)nextResponder;
            //NSLog(@"%@",cell);
            break;
        }
    }
    
    return obj;
}

#pragma mark - ============活动指示器============================
+ (void)showActivityInView:(UIView *)View
{
    [self showActivityInView:View style:UIActivityIndicatorViewStyleWhite];
}

+ (void)showActivityInView:(UIView *)View style:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView *activity = nil;
    for (UIActivityIndicatorView *act in View.subviews) {
        if ([act isKindOfClass:[UIActivityIndicatorView class]]) {
            activity = act;
        }
    }
    
    if (!activity) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        activity.center = CGPointMake(GetVWidth(View)/2, GetVHeight(View)/2);
        activity.hidesWhenStopped = YES;
        [View addSubview:activity];
    }
    
    if (!activity.isAnimating) {
        [activity startAnimating];
    }
}

+ (void)hiddenActivityInView:(UIView *)View
{
    for (UIActivityIndicatorView *activity in View.subviews) {
        if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
            [activity stopAnimating];
        }
    }
}

//普通
+ (void)showSignView:(UIView *)View
{
    UIActivityIndicatorView *Design = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    Design.center = CGPointMake(GetVWidth(View)/2, GetVHeight(View)/2);
    Design.hidesWhenStopped = YES;
    [View addSubview:Design];
    [Design startAnimating];
}
//大
+ (void)showBigSignView:(UIView *)View
{
    UIActivityIndicatorView *Design = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    Design.frame = CGRectMake(0, 0, 20, 20);
    Design.center = CGPointMake(GetVWidth(View)/2, GetVHeight(View)/2);;
    Design.hidesWhenStopped = YES;
    [View addSubview:Design];
    [Design startAnimating];
}
+ (void)hiddenSignView:(UIView *)View
{
    if (View==nil) {
        return;
    }
    for (UIActivityIndicatorView *Design in View.subviews) {
        if ([Design isKindOfClass:[UIActivityIndicatorView class]]) {
            [Design stopAnimating];
        }
    }
}

+ (void)printfView:(UIView *)View
{
    if (View.subviews.count>0) {
        for (UIView *v in View.subviews) {
            [self printfView:v];
        }
    }else{
        NSLog(@"tag=%ld,View=%@",(long)View.tag, View);
    }
}





#pragma mark - ===========隐藏键盘============================
+ (void)HiddenKeyboard:(id)txtField, ...
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, txtField);
    
    // get rest of the objects until nil is found
    if ([txtField isKindOfClass:[UITextField class]]) {
        for (UITextField *Field = txtField; Field != nil; Field = va_arg(args,UITextField *)) {
            [Field resignFirstResponder];
        }
    }
    if ([txtField isKindOfClass:[UITextView class]]) {
        for (UITextView *Field = txtField; Field != nil; Field = va_arg(args,UITextView *)) {
            [Field resignFirstResponder];
        }
    }
    
    va_end(args);
}

+ (void)PrintString:(id)obj headName:(NSString *)name
{
    if (!obj && !name) {
        return;
    }
    if (!obj) {
        NSLog(@"%@",name);
        return;
    }
    if (!name) {
        NSLog(@"%@",obj);
        return;
    }
    NSLog(@"%@%@",name,obj);
}

+ (void)printNum:(CGFloat)result headName:(NSString *)name
{
    if (!name) {
        NSLog(@"%f",result);
        return;
    }
    NSLog(@"%@%f",name,result);
}

+ (NSString *)printDic:(NSDictionary *)dic
{
    if (dic) {
        NSMutableString *value = [NSMutableString string];
        NSArray *listKey = [dic allKeys];
        listKey = [listKey sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult result = [obj1 compare:obj2];
            return result;//NSOrderedDescending
        }];
        for (NSString *key in listKey) {
            if ([key isEqual:[listKey firstObject]]) {
                [value appendFormat:@"%@ = %@",key,[dic objectForKey:key]];
            }else{
                [value appendFormat:@", %@ = %@",key,[dic objectForKey:key]];
            }
        }
        
        return value;
    }
    
    return NULL;
}

+ (void)setViewBounds:(UIViewController *)viewController
{
    BOOL navigationHidden = viewController.navigationController.navigationBarHidden;
    if (viewController.navigationController==NULL) {
        navigationHidden = YES;
    }
    if (iPhone>=7 && !navigationHidden) {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    else if (iPhone >= 7 && navigationHidden) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        if (viewController.view.bounds.size.height==Screen_Height) {
            viewController.view.bounds =  CGRectMake(0, -20, size.width, Screen_Height);
        }
        [viewController.view setTintColor:[UIColor blackColor]];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        [self addStatusBarToView:viewController.view];
    }
}

+ (void)addStatusBarToView:(UIView *)view
{
    if (iPhone>=7) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, -20, Screen_Width, 20)];
        v.backgroundColor = [UIColor whiteColor];
        [view insertSubview:v atIndex:0];
    }
}

+ (void)HiddenView:(BOOL)hidden with:(UIView *)View, ...
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, View);
    
    // get rest of the objects until nil is found
    for (UIView *Field = View; Field != nil; Field = va_arg(args,UIView *)) {
        Field.hidden = hidden;
    }
    
    va_end(args);
}

#pragma mark - ============设置Navigation Bar背景图片==========================
+ (void)setNavigationBarBackground:(NSString *)imgName to:(UIViewController *)viewController
{
    UIImage *title_bg = [UIImage imageNamed:imgName];  //获取图片
    CGSize titleSize = viewController.navigationController.navigationBar.bounds.size;  //获取Navigation Bar的位置和大小
    
    title_bg = [self scaleImg:title_bg size:titleSize];//设置图片的大小与Navigation Bar相同
    UIColor *color = [CTB colorWith:@"logo" atPixel:GetPoint(1, 1)];
    [viewController.navigationController.navigationBar setTintColor:color];
    [viewController.navigationController.navigationBar setBackgroundImage:title_bg forBarMetrics:UIBarMetricsDefault];
}

+ (void)setNavBackImg:(NSString *)imgName to:(UIViewController *)viewController
{
    //[viewController.navigationController setNavigationBarHidden:NO animated:YES];
    UIImage *title_bg = [UIImage imageNamed:imgName];  //获取图片
    CGRect navRect = viewController.navigationController.navigationBar.frame;
    CGSize size = GetSize(navRect.size.width, navRect.size.height);
    
    if (iPhone >= 7) {
        navRect.origin.y = 20.0f;
        size = GetSize(navRect.size.width, navRect.origin.y+navRect.size.height);
    }
    
    title_bg = [[self class] scaleImg:title_bg size:size];
    
    [viewController.navigationController.navigationBar setBackgroundImage:title_bg forBarMetrics:UIBarMetricsDefault];
}

//颜色转换成图片
+ (void)imgColor:(UIColor *)color to:(UIViewController *)viewController
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    CGRect navRect = viewController.navigationController.navigationBar.frame;
    CGSize size = GetSize(navRect.size.width, navRect.size.height);
    
    if (iPhone >= 7) {
        navRect.origin.y = 20.0f;
        size = GetSize(navRect.size.width, navRect.origin.y+navRect.size.height);
    }
    
    theImage = [[self class] scaleImg:theImage size:size];
    
    [viewController.navigationController.navigationBar setBackgroundImage:theImage forBarMetrics:UIBarMetricsDefault];
    
}

//调整图片大小
+ (UIImage *)scaleImg:(UIImage *)img size:(CGSize)size
{
    CGFloat x = 0;
    if (size.width > img.size.width) {
        x = (size.width - img.size.width) / 2;
    }
    
    CGFloat y = size.height - img.size.height;
    y = MAX(y, 0);
    
    if (x == 0 && y == 0) {
        return img;
    }
    
    UIGraphicsBeginImageContext(size);
    CGSize imgSize = img.size;
    
    if (y > 0) {
        y = y+1;
    }
    
    [img drawAtPoint:GetPoint(x, y)];//顶部
    
    if (x > 0) {
        //左右两侧
        UIImage *imgSide = [[self class] getSubImage:img rect:GetRect(0, 0, x, imgSize.height)];
        [imgSide drawAtPoint:GetPoint(0, y)];
        [imgSide drawAtPoint:GetPoint(size.width-x, y)];
    }
    
    if (y > 0) {
        UIImage *imgTop = [[self class] getSubImage:img rect:GetRect(0, 0, img.size.width, 1)];
        [imgTop drawInRect:GetRect(0, 0, size.width, y)];
    }
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - ---------------设置动画---------------------------------
+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         View.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                     }];
}

+ (void)animateWithDur:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.3
                     animations:animations
                     completion:completion];
}

+ (NSArray *)getAnimationData:(BOOL)isBig
{
    NSMutableArray *values = [NSMutableArray array];
    
    GetPoint(1, 0);
    
    NSArray *list = @[valueWithTran3DScale(0.1, 0.1, 1.0),
                      [NSValue valueWithCATransform3D:Trans3DScale(0.5, 0.5, 1.0)],
                      [NSValue valueWithCATransform3D:Trans3DScale(0.9, 0.9, 0.9)],
                      [NSValue valueWithCATransform3D:Trans3DScale(1.0, 1.0, 1.0)]];
    
    if (isBig) {
        for (NSValue *value in list) {
            [values addObject:value];
        }
    }else{
        for (NSInteger i=list.count; i>0; i--) {
            NSValue *value = list[i-1];
            [values addObject:value];
        }
    }
    
    return values;
}

// 特殊动画效果
+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur
{
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    [[self class] exChangeOut:changeOutView dur:dur values:values];
}

+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur values:(NSArray *)listValue
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = dur;
    
    //animation.delegate = self;
    
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSArray *values = [[self class] getAnimationData:true];//变大
    
    if (listValue.count > 0) {
        animation.values = listValue;
    }else{
        animation.values = values;
    }
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [changeOutView.layer addAnimation:animation forKey:nil];
}

+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect complete:(SEL)action delegate:(id)delegate
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:0.3];
    View.frame = rect;
    [UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect complete:(SEL)action delegate:(id)delegate duration:(NSTimeInterval)duration
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:duration];
    View.frame = rect;
    [UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View point:(CGPoint)point duration:(NSTimeInterval)duration
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:duration];
    View.frame = CGRectMake(point.x, point.y, View.frame.size.width, View.frame.size.height);
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View toX:(CGFloat)x duration:(NSTimeInterval)duration
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:duration];
    View.frame = CGRectMake(x, View.frame.origin.y, View.frame.size.width, View.frame.size.height);
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View toY:(CGFloat)y duration:(NSTimeInterval)duration
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:duration];
    View.frame = CGRectMake(View.frame.origin.x, y, View.frame.size.width, View.frame.size.height);
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View point:(CGPoint)point complete:(SEL)action delegate:(id)delegate
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:0.3];
    View.frame = CGRectMake(point.x, point.y, View.frame.size.width, View.frame.size.height);
    [UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View size:(CGSize)size
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.3];
    View.frame = CGRectMake(View.frame.origin.x, View.frame.origin.y, size.width, size.height);
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIView *)View size:(CGSize)size complete:(SEL)action delegate:(id)delegate
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:0.3];
    View.frame = CGRectMake(View.frame.origin.x, View.frame.origin.y, size.width, size.height);
    [UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIScrollView *)tableView Offset:(CGPoint)point
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    //[UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:0.3f];
    tableView.contentOffset = point;
    //[UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(UIScrollView *)tableView Offset:(CGPoint)point duration:(NSTimeInterval)duration
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    //[UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:duration];
    tableView.contentOffset = point;
    //[UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
}

+ (void)setAnimationWith:(NSTimeInterval)duration delegate:(id)delegate complete:(SEL)action
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:action];
}

+ (void)commitAnimations
{
    [UIView commitAnimations];
}

#pragma mark 高级动画
- (void)showAnimationType:(NSString *)type
              withSubType:(NSString *)subType
                 duration:(CFTimeInterval)duration
           timingFunction:(NSString *)timingFunction
                     view:(UIView *)theView
                 delegate:(id)delegate
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];//kCAMediaTimingFunctionLinear
    CATransition *animation = [CATransition animation];
    animation.delegate = delegate;
    animation.duration = duration;//持续时间
    timingFunction = timingFunction ?: kCAMediaTimingFunctionEaseInEaseOut;//先慢后快再慢
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    animation.fillMode = kCAFillModeForwards;
    type = type ?: kCATransitionPush;//kCATransitionPush:新视图把旧视图推出去
    animation.type = type;
    animation.subtype = subType;
    [theView.layer addAnimation:animation forKey:nil];
}

#pragma mark - ===========重新设置视图的位置和尺寸=========================
+ (CGRect)setRectByX:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h scale:(CGFloat)scale
{
    CGRect rect = CGRectMake(x*scale, y*scale, w*scale, h*scale);
    return rect;
}

+ (CGRect)setRect:(CGRect)rect scale:(CGFloat)scale
{
    rect = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    return rect;
}

+ (BOOL)containsPoint:(CGPoint)point inRect:(CGRect)rect
{
    BOOL result = CGRectContainsPoint(rect, point);
    return result;
}

+ (UIColor *)colorWith:(NSString *)imgName atPixel:(CGPoint)point
{
    UIImage *image = [UIImage imageNamed:imgName];
    UIColor *color = [[self class] colorBy:image atPixel:point];
    
    return color;
}

+ (UIColor *)colorBy:(UIImage *)image atPixel:(CGPoint)point
{
    // Cancel if point is outside image coordinates
    CGSize size = image.size;
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, size.width, size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    CGImageRelease(cgImage);
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - **********************************************
#pragma mark 绑定图片，保证图片不变形
+ (void)bindImageToFitSize:(UIImageView *)imageView image:(UIImage *)image minY:(float)minY maxY:(float)maxY
{
    CGPoint center = imageView.center;
    if (image.size.height > image.size.width) {
        
        float width = imageView.frame.size.height * image.size.width / image.size.height;
        [imageView setSizeToW:width];
        imageView.center = center;
    }
    else {
        
        float height = imageView.frame.size.width * image.size.height / image.size.width;
        [imageView setSizeToH:height];
        imageView.center = center;
    }
    
    if (minY >= 0 && imageView.frame.origin.y < minY) {
        
        [imageView setOriginY:minY];
    }
    
    if (maxY > 0 && imageView.frame.origin.y + imageView.frame.size.height > maxY) {
        
        float height = minY >= 0 ? maxY - minY : maxY;
        float width = imageView.frame.size.width * height / imageView.frame.size.height;
        
        [imageView setSizeToW:width height:height];
        
        if (minY >= 0) {
            imageView.center = CGPointMake(center.x, minY + height/2);
        }
        else {
            imageView.center = CGPointMake(center.x, height/2);
        }
    }
    
    imageView.image = image;
}

//设置图片并调整尺寸到图片大小
+ (void)setSizeWithView:(UIImageView *)imgView withImg:(UIImage *)img
{
    CGSize size = CGSizeMake(img.size.width, img.size.height);
    [imgView setSizeToW:size.width height:size.height];
    imgView.image = img;
    //imgView.contentMode = UIViewContentModeScaleAspectFit;
}

// 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
// 以下为调整图片角度的部分
+ (UIImage *)fixRotaion:(UIImage *)image
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
+ (UIImage *)getSubImage:(UIImage *)image rect:(CGRect)rect
{
    if (!image) return nil;
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return newImage;
}

// 从view上截图
- (UIImage *)getImageBy:(UIView *)View
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(150, 150), NO, 1.0);  //NO，YES 控制是否透明
    [View.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 生成后的image
    
    return image;
}

#pragma mark 将图片分解成图片数组
+ (NSArray *)getImagesWith:(UIImage *)image count:(int)count
{
    if (!image || image.size.width <= 0) {
        return nil;
    }
    
    CGFloat w = image.size.width/count;
    CGFloat h = image.size.height;
    CGFloat scale = image.scale;
    NSArray *listImg = @[];
    for (int i=0; i<count; i++) {
        CGRect rect = GetRect(w*i*scale, 0, w*scale, h*scale);//截取位置尺寸
        UIImage *img = [CTB getSubImage:image rect:rect];//截取图像
        if (img) {
            listImg = [listImg arrayByAddingObject:img];
        }
    }
    
    return listImg;
}

+ (void)getSubImgView:(UIImageView *)imgView
{
    UIImage *image = imgView.image;
    if (!image) {
        return;
    }
    
    CGSize imgSize = image.size;
    CGSize viewSize = imgView.frame.size;
    CGFloat scale = viewSize.width/viewSize.height;
    if (imgSize.width/imgSize.height > scale) {
        CGFloat w = imgSize.height * scale;
        image = [[self class] getSubImage:image rect:GetRect((imgSize.width-w)/2, 0, w, imgSize.height)];
    }
    else if (imgSize.width/imgSize.height < scale) {
        CGFloat h = imgSize.width / scale;
        image = [[self class] getSubImage:image rect:GetRect(0, (imgSize.height-h)/2, imgSize.width, h)];
    }
    
    imgView.image = image;
}

+ (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
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

//设置图片并调整中心位置到原先设定状态
+ (void)setImgView:(UIImageView *)imgView withImgName:(NSString *)imgName
{
    UIImage *image = [UIImage imageNamed:imgName];
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    CGPoint center = imgView.center;
    imgView.frame = CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, size.width, size.height);
    imgView.center = center;
    imgView.image = image;
}

+ (void)setView:(UIView *)View toCentre_X:(CGFloat)x Y:(CGFloat)y
{
    View.center = CGPointMake(x, y);
}

+ (void)setImgView:(UIImageView *)imgView image:(UIImage *)image masksToSize:(CGSize)size
{
    CGSize imgSize = image.size;
    CGFloat scale_W = imgSize.width/size.width;
    CGFloat scale_H = imgSize.height/size.height;
    if (imgSize.width>size.width || imgSize.height>size.height) {
        if (imgSize.width/imgSize.height > size.width/size.height) {
            //过宽
            [imgView setSizeToW:imgSize.width/scale_H height:size.height];
        }else{
            //过高
            [imgView setSizeToW:size.width height:imgSize.height/scale_W];
        }
    }else{
        [imgView setSizeToW:imgSize.width height:imgSize.height];
    }
    
    if (imgView.superview) {
        CGSize superSize = imgView.superview.frame.size;
        imgView.center = CGPointMake(superSize.width/2, superSize.height/2);
    }
    imgView.image = image;
}

+ (UIImage *)setImgWithName:(NSString *)imgName Capinsets:(UIEdgeInsets)capInsets
{
    UIImage *image = [UIImage imageNamed:imgName];
    image = [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
    return image;
}

+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *image = nil;
    if (iPhone >= 8) {
        image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        image = [UIImage imageNamed:name];
    }
    
    return image;
}

#pragma mark 根据颜色、大小生成一张图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - ==============根据字体参数计算label的高度==============================
+ (float)heightOfContent:(NSString *)content width:(CGFloat)width fontSize:(CGFloat)size
{
    UIFont *contentFont = [UIFont systemFontOfSize:size];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:contentFont, NSFontAttributeName,nil];
    CGSize dateSize = CGSizeZero;
    if (iPhone > 7) {
        dateSize = [content boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }else{
        dateSize = [content sizeWithFont:contentFont constrainedToSize:CGSizeMake(width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    }
    float heightOfContent = MAX(25, dateSize.height);
    return heightOfContent;
}

+ (CGSize)getSizeWith:(NSString *)content wordSize:(CGFloat)big size:(CGSize)size
{
    UIFont *font = [UIFont systemFontOfSize:big];
    CGSize labelsize = CGSizeZero;
    if (iPhone > 7) {
        labelsize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
    }
    return labelsize;
}

+ (CGSize)getSizeWith:(NSString *)content font:(UIFont *)font size:(CGSize)size
{
    CGSize labelsize = CGSizeZero;
    if (iPhone > 7) {
        labelsize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
    }
    return labelsize;
}

+ (void)setWidthWith:(UILabel *)label content:(NSString *)content size:(CGSize)size
{
    UIFont *font = [UIFont systemFontOfSize:label.font.pointSize];
    CGSize labelsize = CGSizeZero;
    if (iPhone > 7) {
        labelsize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
    }
    label.text = content;
    [label setSizeToW:labelsize.width];
}

+ (CGFloat)getLabelHighBy:(NSString *)content wordSize:(CGFloat)big width:(CGFloat)width
{
    CGSize size = CGSizeMake(width, 2000);
    UIFont *font = [UIFont systemFontOfSize:big];
    CGSize labelsize = CGSizeZero;
    if (iPhone > 7) {
        labelsize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
    }
    return labelsize.height;
}

+ (CGFloat)getLabelWidthBy:(NSString *)content wordSize:(CGFloat)big high:(CGFloat)high
{
    CGSize size = CGSizeMake(2000, high);
    UIFont *font = [UIFont systemFontOfSize:big];
    CGSize labelsize = CGSizeZero;
    if (iPhone > 7) {
        labelsize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
    }
    return labelsize.width;
}

+ (NSStringEncoding)getGBKEncoding
{
    NSStringEncoding GBK = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return GBK;
}

#pragma mark - ========处理字典中的NSNull类数据=====================
+ (NSString *)stringWith:(NSDictionary *)dic key:(NSString *)key
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NULL;
    }
    
    NSString *result = [dic objectForKey:key];
    if (!result || ![result isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    result = [NSString stringWithFormat:@"%@",result];
    
    return result;
}

#pragma mark 合并字符串
NSString *mergedString(NSString *aString,NSString *bString)
{
    NSString *result = pooledString(aString, bString, nil);
    return result;
}

NSString *pooledString(NSString *aString,NSString *bString,NSString *midString)
{
    if (!aString && !bString) {
        return nil;
    }
    
    aString = aString ?: @"";
    bString = bString ?: @"";
    midString = midString ?: @"";
    
    NSString *result = [NSString stringWithFormat:@"%@%@%@",aString,midString,bString];
    return result;
}

+ (NSString *)getSameString:(NSString *)string length:(NSInteger)length
{
    NSString *result = @"";
    if (length > 0 && string.length > 0) {
        for (int i=0; i<length; i++) {
            result = [result stringByAppendingString:string];
        }
    }
    
    return result;
}

+ (CGSize)getWidthBy:(NSString *)string font:(UIFont *)font
{
    if (string.length <= 0) {
        return CGSizeZero;
    }
    
    NSString *temp = [self getSameString:string length:1000];
    CGFloat h = font.pointSize * 1.2;//1.1930001
    CGSize sizeTest = [CTB getSizeWith:temp font:font size:GetSize(50000, h)];
    return sizeTest;
}

+ (NSAttributedString *)attribute:(NSString *)aString font:(UIFont *)font range:(NSRange)range
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:aString];
    [str addAttribute:NSFontAttributeName value:font range:range];
    return str;
}

#pragma mark - =========颜色转换=============================
+ (UIColor *)colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor redColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor redColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    CGFloat t = 255.0f;
    UIColor *color = colorWithRGB(r/t,g/t,b/t,1.0f);
    return color;
}

UIColor *colorWithHex(NSString *stringToConvert)
{
    UIColor *color = [CTB colorWithHexString:stringToConvert];
    return color;
}

UIColor *colorWithRGB(CGFloat r,CGFloat g,CGFloat b,CGFloat alpha)
{
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return color;
}

+ (UIColor *)colorWithImgName:(NSString *)imgName
{
    UIImage *image = [UIImage imageNamed:imgName];
    UIColor *color = [UIColor colorWithPatternImage:image];
    return color;
}

+ (UIColor *)colorWithImg:(UIImage *)image
{
    UIColor *color = [UIColor colorWithPatternImage:image];
    return color;
}

+ (UIColor *)setColor:(UIColor *)color opacity:(CGFloat)alpha
{
    UIColor *result = nil;
    CGFloat opacity = 1;
    const CGFloat *cs=CGColorGetComponents(color.CGColor);
    size_t index = CGColorGetNumberOfComponents(color.CGColor);
    
    if (index==2) {
        opacity = alpha * cs[1];
        result = [UIColor colorWithRed:cs[0] green:cs[0] blue:cs[0] alpha:opacity];
    }
    if (index==3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重新选择颜色" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    if (index==4) {
        opacity = alpha * cs[3];
        result = [UIColor colorWithRed:cs[0] green:cs[1] blue:cs[2] alpha:opacity];
    }
    
    return result;
}

+ (NSString *)getString:(NSString *)aString Start:(NSString *)a End:(NSString *)b
{
    //char *buf=(char *)malloc(sizeof(char));
    //sscanf("123456abcdedfBCDEF", "%[1-9]", buf);
    NSArray *arrStart = [aString componentsSeparatedByString:a];
    if (arrStart.count<=1) {
        return NULL;
    }
    char *buf=(char *)malloc(sizeof(char));
    char *search=(char *)malloc(sizeof(char));
    sprintf(search, "%s*[^%s]%s%s[^%s]","%",[a UTF8String],[a UTF8String],"%",[b UTF8String]);
    sscanf([aString UTF8String], search, buf);
    NSString *stringL = [NSString stringWithFormat:@"%s",buf];
    return stringL;
}

#pragma mark - ========设置背景色===================
+ (UIColor *)setBackgroundColor:(UIColor *)color opacity:(CGFloat)alpha
{
    CGFloat opacity = 0;
    UIColor *result = nil;
    const CGFloat *cs=CGColorGetComponents(color.CGColor);
    size_t index = CGColorGetNumberOfComponents(color.CGColor);
    
    if (index==2) {
        opacity = alpha * cs[1];
        result = [UIColor colorWithRed:cs[0] green:cs[0] blue:cs[0] alpha:opacity];
    }
    if (index==3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重新选择颜色" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    if (index==4) {
        opacity = alpha * cs[3];
        result = [UIColor colorWithRed:cs[0] green:cs[1] blue:cs[2] alpha:opacity];
    }
    
    return result;
}

#pragma mark - =============颜色转图片=========================
+ (UIImage *)imgColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - =============保存图片到文件=========================
+ (void)saveImgToFile:(NSString *)FilePath withImg:(UIImage *)image
{
    NSData *data=nil;
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
        
    }
    [data writeToFile:FilePath atomically:YES];
}

//调整图片到指定尺寸(可能改变图片的宽高比)
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    if (!image) {
        return NULL;
    }
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

//按照图片比例压缩图片
+ (UIImage *)imageWithImg:(UIImage *)img scaledToSize:(CGSize)newSize
{
    if (!img) {
        return NULL;
    }
    CGFloat w = img.size.width;
    CGFloat h = img.size.height;
    if (w<=newSize.width && h<=newSize.width) {
        return img;
    }else{
        CGFloat scale = 0;
        scale = MAX(w/newSize.width, scale);
        scale = MAX(h/newSize.height, scale);
        
        //new image size
        newSize = CGSizeMake(w/scale, h/scale);
        // Create a graphics image context
        UIGraphicsBeginImageContext(newSize);
        // Tell the old image to draw in this new context, with the desired
        // new size
        [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        // Get the new image from the context
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        // End the context
        UIGraphicsEndImageContext();
        // Return the new image.
        return newImage;
    }
}

#pragma mark 压缩ImageData, 指定最大的kb数
+ (NSData *)scaleImageToDataByMaxKB:(long)maxKB image:(UIImage *)image
{
    float maxB = 1024.0 * maxKB;
    
    CGFloat scale = 0.9;
    
    if (image.size.width<=640 && image.size.height<=960) {
        return UIImageJPEGRepresentation(image, scale);
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, scale);//压缩比例
    
    if (imageData.length <= maxB) {
        return imageData;
    }
    
    image = [CTB imageWithImg:image scaledToSize:CGSizeMake(640, 960)];
    imageData = UIImageJPEGRepresentation(image, scale);//压缩比例
    return imageData;
    
//    float compressRadio = maxB / [imageData length];
//    NSData *result = UIImageJPEGRepresentation(image, compressRadio);
//    
//    if ([result length] > maxB) {
//        
//        UIImage *newImage = [CTB scaleImageByResize:image radio:maxB / [result length]];
//        result = UIImageJPEGRepresentation(newImage, compressRadio);
//        //        NSLog(@"再次压缩:%d", [result length] / 1024);
//    }
//    return result;
}

#pragma mark 根据图片width 和 height 压缩图片
+ (UIImage *)scaleImageByResize:(UIImage *)image radio:(float)radio
{
    float newWidth = image.size.width *radio;
    float newHeight = image.size.height * radio;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSData *)getImgDataBy:(UIImage *)image
{
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    } else {
        data = UIImagePNGRepresentation(image);
    }
    
    return data;
}

+ (void)deleteFileFor:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSError *error = nil;
        [manager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"remove File : %@",error.localizedDescription);
        }
    }
}

#pragma mark - ==========文件,路径======================
//判断路径或者文件是否存在
+ (BOOL)isExistWithPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSString *)getSandboxPath
{
    NSString *Path = @"~";
    Path = [Path stringByExpandingTildeInPath];
    
    return Path;
}

+ (NSString *)getPath:(NSString *)path name:(NSString *)name
{
    path = [path stringByExpandingTildeInPath];//扩展成路径
    NSString *FilePath = [path stringByAppendingPathComponent:name];
    return FilePath;
}

+ (void)saveFileWithPath:(NSString *)path FileName:(NSString *)name content:(id)content
{
    NSString *FilePath = nil;
    NSString *file = [path lastPathComponent];
    NSRange range = [file rangeOfString:@"."];
    if (range.location != NSNotFound) {
        FilePath = path;
    }else{
        path = [path stringByExpandingTildeInPath];//扩展成路径
        FilePath = [path stringByAppendingPathComponent:name];
    }
    
    NSError *error = nil;
    if (content==NULL) {
        [CTB alertWithMessage:@"数据为空,写入失败" Delegate:nil tag:0];
        return;
    }
    if ([content isKindOfClass:[NSString class]]) {
        NSString *data = content;
        [data writeToFile:FilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    if ([content isKindOfClass:[NSArray class]]) {
        NSArray *data = content;
        [data writeToFile:FilePath atomically:YES];
    }
    if ([content isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = content;
        [data writeToFile:FilePath atomically:YES];
    }
    if ([content isKindOfClass:[NSData class]]) {
        NSData *data = content;
        [data writeToFile:FilePath atomically:YES];
    }
    
    if (error) {
        [CTB PrintString:error.description headName:@"错误:"];
    }
}

+ (NSData *)readFileWithPath:(NSString *)path FileName:(NSString *)name
{
    if (!path || path.length <= 0) {
        return nil;
    }
    NSString *lastPart = [path lastPathComponent];
    if (![lastPart hasSuffix:@".xml"]) {
        path = [path stringByExpandingTildeInPath];//扩展成路径
        path = [path stringByAppendingPathComponent:name];
        if (![path hasSuffix:@".xml"]) {
            path = [path stringByAppendingString:@".xml"];
        }
    }
    NSString *FilePath = path;
    if (![CTB isExistWithPath:FilePath]) {
        return NULL;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
    return data;
}

+ (id)readWithPath:(NSString *)path FileName:(NSString *)name
{
    NSError *error = nil;
    name = [name stringByAppendingString:@".xml"];
    NSData *data = [CTB readFileWithPath:path FileName:name];
    if (data==NULL) {
        return NULL;
    }
    id josonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [CTB PrintString:error.localizedDescription headName:@"错误:"];
        return NULL;
    }
    return josonDic;
}

NSString* getPartString(NSString *string,NSString *aString,NSString *bString)
{
    if (![string isKindOfClass:[NSString class]] || !string || string.length == 0) {
        return NULL;
    }
    
    NSString *result = nil;
    NSArray *list = [string componentsSeparatedByString:aString];
    
    if (list.count > 1) {
        for (int i=1; i<list.count; i++) {
            result = [list objectAtIndex:i];
            
            list = [result componentsSeparatedByString:bString];
            if (list.count > 0) {
                result = [list firstObject];
                
                break;
            }
        }
        
        return result;
    }
    
    return NULL;
}

#pragma mark 获取AppCaidan.db的路径
NSArray *getDBPath()
{
    NSMutableArray *result = [NSMutableArray array];
    
    //获取当前应用程序所在目录
    NSString *dir = [NSHomeDirectory() stringByDeletingLastPathComponent];
    //获取当前目录下的所有文件
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dir error:nil];
    
    for (NSString *file in directoryContents) {
        NSString *appPath = [dir stringByAppendingPathComponent:file];
        NSString *filePath = [appPath stringByAppendingPathComponent:@"Library/AppCaian.db"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [result addObject:filePath];
        }
    }
    
    return result;
}

+ (NSArray *)getDBPath
{
    return getDBPath();
}

#pragma mark 获取-info.plist中的数据
+ (NSDictionary *)infoDictionary
{
    //获取APP相关的各项参数信息
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    return infoDict;
}

#pragma mark - =============字符串的编码和解码===================
NSString *getUTF8String(NSString *string)
{
    NSString *result = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

NSString *outUTF8String(NSString *string)
{
    NSString *result = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

NSString *replaceString(NSString *string,NSString *oldString,NSString *newString)
{
    NSString *result = [string stringByReplacingOccurrencesOfString:oldString withString:newString];
    return result;
}

NSString *StringFromCGRect(UIView *View)
{
    NSString *result = NSStringFromCGRect(View.frame);
    return result;
}

#pragma mark - =============从字符串中获取指定某字符到某字符之间的字符串======================
+ (NSString *)scanString:(NSString *)aString Start:(NSString *)a End:(NSString *)b
{
    NSString *result = nil;
    NSArray *arrStart = [aString componentsSeparatedByString:a];
    if (arrStart.count>1) {
        result = arrStart[1];
        result = [[result componentsSeparatedByString:b] lastObject];
        return result;
    }
    return NULL;
}

#pragma mark - =============判断是否包含======================
+ (BOOL)contain:(NSString *)bString inString:(NSString *)aString
{
    NSRange range = [aString rangeOfString:bString];
    if (range.location==NSNotFound) {
        return NO;
    }
    return YES;
}

BOOL containString(NSString *string,NSString *aString)
{
    NSRange range = [string rangeOfString:aString];
    if (range.location==NSNotFound) {
        return NO;
    }
    return YES;
}

+ (CLLocation *)getLocationWith:(NSString *)locationStr
{
    NSAssert([locationStr isKindOfClass:[NSString class]], @"locationStr不是字符串");
    
    CLLocationDegrees lat,lng;
    NSArray *list = [locationStr componentsSeparatedByString:@","];
    if (list.count<2) {
        return nil;
    }
    
    lat = [list[0] doubleValue];
    lng = [list[1] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    return location;
}

#pragma mark - ==============判断是否为手机号========================
+ (BOOL)isMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^0{0,1}1[3|4|5|6|7|8|9][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL isValid = [phoneTest evaluateWithObject:mobile];
    return isValid;
}

+ (BOOL)isEmail:(NSString *)email
{
    //x@y.z,x∈[A-Z0-9a-z._%+-],y∈[A-Za-z0-9.-],z∈[A-Za-z]且长度限制为{2,4}
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:email];
    return isValid;
}

#pragma mark - ===========设置状态栏字体颜色=========================
+ (void)setStatusBarStyleWith:(UIApplication *)application
{
    //[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - ----------tableView添加底部线条(分隔线)------------------
+ (UIView *)setBottomLineAt:(UITableView *)tableView cell:(UITableViewCell *)cell cellH:(CGFloat)cellH
{
    CGFloat w = tableView.frame.size.width;
    UIView *View = [cell.contentView viewWithTag:200];
    if (!View) {
        View = [[UIView alloc] initWithFrame:CGRectMake(10, cellH-0.6, w-20, 0.6)];
        [cell.contentView addSubview:View];
    }
    View.tag = 200;
    View.backgroundColor = [UIColor clearColor];
    View.layer.masksToBounds = YES;
    View.layer.borderWidth = 0.3;
    View.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    
    return View;
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell delegate:(id)delegate
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    NSDictionary *dic = nil;
    if (indexPath)
        dic = @{@"indexPath":indexPath,@"cell":cell};
    else
        dic = @{@"cell":cell};
    return [[self class] setBottomLineAtTable:tableView dicData:dic];
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath delegate:(id)delegate
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = nil;
    if (cell)
        dic = @{@"indexPath":indexPath,@"cell":cell};
    else
        dic = @{@"indexPath":indexPath};
    return [[self class] setBottomLineAtTable:tableView dicData:dic];
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    NSDictionary *dic = nil;
    if (indexPath)
        dic = @{@"indexPath":indexPath,@"cell":cell};
    else
        dic = @{@"cell":cell};
    return [[self class] setBottomLineAtTable:tableView dicData:dic];
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = nil;
    if (cell)
        dic = @{@"indexPath":indexPath,@"cell":cell};
    else
        dic = @{@"indexPath":indexPath};
    return [[self class] setBottomLineAtTable:tableView dicData:dic];
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    return [[self class] setBottomLineAtTable:tableView dicData:@{@"indexPath":indexPath,@"cell":cell}];
}

+ (UIView *)setBottomLineAtTable:(UITableView *)tableView dicData:(NSDictionary *)dicData
{
    NSIndexPath *indexPath = dicData[@"indexPath"];
    UITableViewCell *cell = dicData[@"cell"];
    //CGFloat w = [tableView rectForRowAtIndexPath:indexPath].size.width;
    CGFloat w = tableView.frame.size.width;
    CGFloat h = cell.contentView.frame.size.height;
    id delegate = dicData[@"delegate"];
    if ([delegate respondsToSelector:select(tableView:heightForRowAtIndexPath:)]) {
        h = [delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        if (indexPath) {
            h = [tableView rectForRowAtIndexPath:indexPath].size.height;
        }
    }
    UIView *View = [cell.contentView viewWithTag:200];;
    if (!View) {
        View = [[UIView alloc] initWithFrame:CGRectMake(10, h-0.6, w-20, 0.6)];
        [cell.contentView addSubview:View];
    }
    View.tag = 200;
    View.backgroundColor = [UIColor clearColor];
    View.layer.masksToBounds = YES;
    View.layer.borderWidth = 0.3;
    View.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    
    return View;
}


+ (UIView *)setBottomLineAtTables:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    return [[self class] setBottomLineAtTables:tableView dicData:@{@"indexPath":indexPath,@"cell":cell}];
}

+ (UIView *)setBottomLineAtTables:(UITableView *)tableView dicData:(NSDictionary *)dicData
{
    NSIndexPath *indexPath = dicData[@"indexPath"];
    UITableViewCell *cell = dicData[@"cell"];
    //CGFloat w = [tableView rectForRowAtIndexPath:indexPath].size.width;
    CGFloat w = tableView.frame.size.width;
    CGFloat h = cell.contentView.frame.size.height;
    id delegate = dicData[@"delegate"];
    if ([delegate respondsToSelector:select(tableView:heightForRowAtIndexPath:)]) {
        h = [delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        if (indexPath) {
            h = [tableView rectForRowAtIndexPath:indexPath].size.height;
        }
    }
    UIView *View = [cell.contentView viewWithTag:200];;
    if (!View) {
        View = [[UIView alloc] initWithFrame:CGRectMake(0, h-0.6, w, 0.6)];
        [cell.contentView addSubview:View];
    }
    View.tag = 200;
    View.backgroundColor = [UIColor clearColor];
    View.layer.masksToBounds = YES;
    View.layer.borderWidth = 0.3;
    View.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    
    return View;
}


+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell h:(CGFloat)h
{
    CGFloat w = tableView.frame.size.width;
    UIView *View = [cell.contentView viewWithTag:200];;
    if (!View) {
        View = [[UIView alloc] initWithFrame:CGRectMake(10, h-0.6, w-20, 0.6)];
        [cell.contentView addSubview:View];
    }
    View.tag = 200;
    View.backgroundColor = [UIColor clearColor];
    View.layer.masksToBounds = YES;
    View.layer.borderWidth = 0.3;
    View.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    
    return View;
}

void hiddenNavBar(UIViewController *VC,BOOL hidden,BOOL animaion)
{
    hiddenNavBarBy(VC.navigationController, hidden, animaion);
}

void hiddenNavBarBy(UINavigationController *nav,BOOL hidden,BOOL animaion)
{
    [nav setNavigationBarHidden:hidden animated:animaion];
}

#pragma mark - ============隐藏tabBar========================
+ (void)hiddenTabbar:(BOOL)hidden delegate:(id)delegate
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
	CGFloat h = [UIScreen mainScreen].bounds.size.height;//568或者480
    if ([delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *VC=(UIViewController *)delegate;
        for (UIView *view in VC.tabBarController.view.subviews) {
            //将tabBar部分放到视图下方,将非tabBar部分,即视图区域的高度增加tabBar的高度
            if([view isKindOfClass:[UITabBar class]])
            {
                if (hidden) {
                    view.hidden = YES;
                    //根据屏幕实际高度来处理位置,推到了屏幕下方
                    [view setFrame:CGRectMake(view.frame.origin.x, h, view.frame.size.width, view.frame.size.height)];
                } else {
                    view.hidden = NO;
                    [view setFrame:CGRectMake(view.frame.origin.x, h-TabBar_Height, view.frame.size.width, view.frame.size.height)];
                }
            }
            else
            {
                if (hidden) {
                    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, h)];
                } else {
                    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, h-TabBar_Height)];
                }
            }
        }
    }
    
    [UIView commitAnimations];
}

#pragma mark 获取系统时间
+ (NSString *)getDateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:[NSDate date]];
}

+ (NSString *)getSystemTime:(NSDate *)date format:(NSString *)format
{
    if (date==NULL) {
        date = [NSDate date];
    }
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:date];
}

+ (void)reSetPoint:(UIView *)View withHigh:(CGFloat)high
{
    View.frame = CGRectMake(View.frame.origin.x, View.frame.origin.y+high, View.frame.size.width, View.frame.size.height);
}

+ (BOOL)isExistSelf:(UIViewController *)VC
{
    NSArray *listNav = VC.navigationController.childViewControllers;
    if (!listNav || listNav.count<=0) {
        if (VC.presentedViewController) {
            //前进
            return YES;
        }
    }
    if ([listNav containsObject:VC]) {
        //前进
        return YES;
    }
    
    //返回
    return NO;
}

+ (NSDictionary *)getLocalIPAddress
{
    NSMutableDictionary *localIP = [NSMutableDictionary dictionary];
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if (IP.length > 0) {
                    [localIP setObject:IP forKey:name];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

+ (void)getLocalIPAddress:(void (^)(NSDictionary *dicIP))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
        struct ifaddrs *addrs;
        if (getifaddrs(&addrs)==0) {
            const struct ifaddrs *cursor = addrs;
            while (cursor != NULL) {
                if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
                {
                    NSString *IP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    
                    NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                    NSLog(@"%@ : %@",name,IP);
                    
                    name = name ? name : @"en";
                    if (IP.length > 0) {
                        [dicData setObject:IP forKey:name];
                    }
                }
                cursor = cursor->ifa_next;
            }
            freeifaddrs(addrs);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(dicData);
        });
    });
}

+ (void)getWANIPAddressWithCompletion:(void(^)(NSString *IPAddress))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *IP = @"0.0.0.0";
        //@"http://ifconfig.me/ip",@"http://yrip.co",@"https://cgi1.apnic.net/cgi-bin/my-ip.php"
        NSURL *url = [NSURL URLWithString:@"http://yrip.co"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Failed to get WAN IP Address!(%@)", error.localizedDescription);
        } else {
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            responseStr = [responseStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            responseStr = [responseStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSString *result = getPartString(responseStr, @"<code>", @"</code>");
            
            IP = result.length>0 ? result : responseStr;
            
            NSLog(@"外网IP ：%@", IP);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(IP);
        });
    });
}

#pragma mark - =========UIViewController======================
+ (void)UIControllerEdgeNone:(UIViewController *)VC
{
    if (iPhone >= 7) {
        VC.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark 打印调试信息
+ (void)printDebugMsg:(NSString *)msg
{
#if DEBUG
    NSLog(@"%@",msg);
#endif
}

#pragma mark - ======其它=======================
+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dur * NSEC_PER_SEC)), queue, block);
}

//异步
+ (void)asyncWithBlock:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,block);
}

//同步
+ (void)syncWithBlock:(dispatch_block_t)block
{
    dispatch_sync(dispatch_get_main_queue(), block);
}

+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        block();
        dispatch_async(dispatch_get_main_queue(), nextBlock);
    });
}

+ (NSUserDefaults *)getUserDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

NSUserDefaults *getUserDefaults()
{
    return [NSUserDefaults standardUserDefaults];
}

void setUserData(id obj,NSString *key)
{
    if (!key) return;
    if (obj) {
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

void removeObjectForKey(NSString *key)
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

id getUserData(NSString *key)
{
    if (!key) return nil;
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj;
}

+ (void)postNoticeName:(NSString *)aName object:(id)anObject
{
    [NotificationCenter postNotificationName:aName object:anObject];
}

+ (void)postNoticeName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [NotificationCenter postNotificationName:aName object:anObject userInfo:aUserInfo];
}

+ (void)Request:(NSString *)urlString body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler
{
    if ([NSJSONSerialization isValidJSONObject:body])//判断是否有效
    {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        NSURL* url = [NSURL URLWithString:urlString];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
        [request setHTTPBody:jsonData];//把刚才封装的 JSON 数据塞进去
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:handler];
    }
}

//解析域名
+ (char *)parseDomain:(NSString *)domain
{
    if (!domain || ![domain isKindOfClass:[NSString class]]) return nil;
    NSString *domainLow = [domain lowercaseString];
    if ([domainLow hasPrefix:@"http://"]) {
        domain = [domain substringFromIndex:7];
    }
    else if ([domainLow hasPrefix:@"https://"]) {
        domain = [domain substringFromIndex:8];
    }
    struct in_addr addr;
    char *IP = (char *)[domain UTF8String];
    if (inet_addr(IP) != INADDR_NONE) {
        //如果是IP地址
        return IP;
    }
    struct hostent *pHost = gethostbyname(IP);
    if (pHost) {
        memcpy(&addr, pHost->h_addr_list[0], pHost->h_length);
        IP = inet_ntoa(addr);
    }else{
        int result = h_errno;
        NSString *errMsg = @"域名解析失败";
        if (result == HOST_NOT_FOUND) {
            errMsg = @"找不到指定的主机";
        }
        else if (result == NO_ADDRESS) {
            errMsg = @"该主机有名称却无IP地址";
        }
        else if (result == NO_RECOVERY) {
            errMsg = @"域名服务器有错误发生";
        }
        else if (result == TRY_AGAIN) {
            errMsg = @"请再调用一次";
        }
        
        NSLog(@"%@",errMsg);
    }
    
    return IP;
}

+ (NSString *)parserDomain:(NSString *)domain
{
    char *IP = [self parseDomain:domain];
    if (!IP) return nil;
    
    NSString *result = [NSString stringWithUTF8String:IP];
    return result;
}

//发送本地通知
+ (void)sendLocalNotice
{
    //chuagjian一个本地推送
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        //设置推送时间
        noti.fireDate = [NSDate date];
        //设置时区
        noti.timeZone = [NSTimeZone defaultTimeZone];
        //设置重复间隔
        noti.repeatInterval = 0;//循环次数，kCFCalendarUnitWeekday一周一次
        //推送声音
        noti.soundName = UILocalNotificationDefaultSoundName;
        //内容
        NSString *content = [NSString stringWithFormat:@"时间:%@",[CTB getSystemTime:nil format:@"yyyy-MM-dd HH:mm"]];
        noti.alertBody = content;
        noti.hasAction = YES;
        noti.alertAction = @"测试你的通知能力";
        if (iPhone >= 8) noti.category = @"ACTIONABLE";
        //显示在icon上的红色圈中的数子
        noti.applicationIconBadgeNumber = 1;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *userInfo = @{@"Code":@"816",
                                   @"aps":@{@"alert" : content,
                                            @"badge" : @"1",
                                            @"content-available":@(1),//可后台执行
                                            @"category" : @"ACTIONABLE",
                                            @"sound" : @"ping.caf"}};
        noti.userInfo = userInfo;
        //添加推送到uiapplication
        UIApplication *app = [UIApplication sharedApplication];
        BOOL isRegisteredNotification = NO;
        if (iPhone < 8) {
            UIRemoteNotificationType type = [app enabledRemoteNotificationTypes];
            isRegisteredNotification = type != UIRemoteNotificationTypeNone;
        }else{
            isRegisteredNotification = [app isRegisteredForRemoteNotifications];
        }
        if (isRegisteredNotification) {
            //只有注册了通知才能使用通知
            [app scheduleLocalNotification:noti];
        }
    }
}

#pragma mark ==========APP核对==========================
+ (NSArray *)checkHasOwnApp
{
    NSArray *mapSchemeArr = @[@"comgooglemaps://",@"iosamap://navi",@"baidumap://map/",@"sosomap://map/"];
    
    NSDictionary *dicData = @{mapSchemeArr[0]:@"google地图",
                              mapSchemeArr[1]:@"高德地图",
                              mapSchemeArr[2]:@"百度地图",
                              mapSchemeArr[3]:@"腾讯地图",};
    
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图", nil];
    
    for (int i = 0; i < [mapSchemeArr count]; i++) {
        NSString *urlString = [mapSchemeArr objectAtIndex:i];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            
            [appListArr addObject:dicData[urlString]];
        }
    }
    
    //[appListArr addObject:@"显示路线"];
    
    return appListArr;
}

//获取该目录路径下全部文件名
+ (NSArray *)getAllItemsInDirectory:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:path];
    NSArray *listAllItems = [direnum allObjects];
    return listAllItems;
}

//删除该目录路径下全部文件
+ (BOOL)deleteAllItemsInDirectory:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *listAllItems = [self.class getAllItemsInDirectory:path];
    for (NSString *items in listAllItems) {
        path = [path stringByAppendingPathComponent:items];
        NSError *error = nil;
        if (![manager removeItemAtPath:path error:&error]) {
            if (error) {
                NSLog(@"删除文件, %@",error.localizedDescription);
            }else{
                NSLog(@"删除文件失败");
            }
        }else{
            return YES;
        }
    }
    return NO;
}

+ (NSString *)removeHTML:(NSString *)html
{
    
    NSString *regEx_style=@"<style[^>]*?>[\\s\\S]*?<\\/style>"; //定义style的正则表达式
    NSString *regEx_html=@"<[^>]+>"; //定义HTML标签的正则表达式
    NSRegularExpression *regular_style = [NSRegularExpression regularExpressionWithPattern:regEx_style options:0 error:nil];
    
    NSRegularExpression *regular_html = [NSRegularExpression regularExpressionWithPattern:regEx_html options:0 error:nil];
    
    html  = [regular_style stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
    html  = [regular_html stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
    html = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    return html;
    
}

+ (void)Try:(dispatch_block_t)try Catch:(dispatch_block_t)catch Finally:(dispatch_block_t)finally
{
    @try {
        try();
    }
    @catch (NSException *exception) {
        catch();
    }
    @finally {
        finally();
    }
}

#pragma mark - ---------Objective-C---------------------
#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByString:(NSString *)string Length:(int)length
{
    if (![string isKindOfClass:[NSString class]] || string.length <= 0) {
        //'A' ~ "Z",'a' ~ "z",'0' ~ "9"
        string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    }
    NSString *result = @"";
    NSString *mStr = string;
    for (int i = 0; i <length; i ++) {
        int ran = arc4random() % mStr.length;
        NSString *charStr = [mStr substringWithRange:NSMakeRange(ran, 1)];
        result = [result stringByAppendingString:charStr];
    }
    return result;
}

#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByLength:(int)length
{
    return [self getRandomByString:nil Length:length];
}

#pragma mark 获取当前WIFI SSID信息
+ (NSDictionary *)currentWiFiSSID
{
    NSDictionary *result = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    //NSLog(@"Supported interfaces: %@", ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"dici：%@",[info  allKeys]);
        if (info && [info count]) {
            result = info;//BSSID,SSID
            break;
        }
    }
    return result;
}

@end

#pragma mark - ===========类扩展======================
#pragma mark - --------NSString------------------------
@implementation NSString (NSObject)

+ (NSString *)stringWith:(NSString *)string
{
    if (string == nil) {
        return @"";
    }
    
    return string;
}

+ (NSString *)stringSplicing:(NSArray *)array
{
    if (array == nil || ![array isKindOfClass:[NSArray class]]) {
        return @"";
    }
    
    NSString *result = @"";
    for (NSString *str in array) {
        NSAssert([str isKindOfClass:[NSString class]], @"Splicing the string must user NSString class");
        result = [result AppendString:str];
    }
    
    return result;
}

+ (NSString *)jsonStringWithString:(NSString *) string
{
    NSString *result = [NSString stringWithFormat:@"\"%@\"",
                        [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
                        ];
    return result;
}

+ (NSString *)jsonStringWithArray:(NSArray *)array
{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [[self class] jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [[self class] jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

+ (NSString *)jsonStringWithObject:(id) object
{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [[self class] jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [[self class] jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [[self class] jsonStringWithArray:object];
    }
    return value;
}

+ (NSString *)format:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    if (!format)
        return nil;
    
    va_list arglist;
    va_start(arglist, format);
    NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    return outStr;
}

+ (NSString *)readFile:(NSString *)path encoding:(NSStringEncoding)enc
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:enc error:&error];
    if (error) {
        NSLog(@"读取文件出错,%@",error.localizedDescription);
    }
    
    return content;
}

- (BOOL)writeToFile:(NSString *)path encoding:(NSStringEncoding)enc
{
    NSError *error = nil;
    BOOL result = [self writeToFile:path atomically:YES encoding:enc error:&error];
    if (error) {
        NSLog(@"写入文件异常,%@",error.localizedDescription);
    }
    
    return result;
}

- (NSString *)AppendString:(NSString *)aString
{
    if (!aString) return self;
    return [self stringByAppendingString:aString];
}

- (NSString *)AppendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list arglist;
    va_start(arglist, format);
    NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    outStr = [self stringByAppendingString:outStr];
    
    return outStr;
}

#pragma mark 十六进制字符转data
- (NSData *)dataByHexString
{
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    char const *myBuffer = str.UTF8String;
    NSInteger charCount = strlen(myBuffer);
    if (charCount %2 != 0) {
        return nil;
    }
    NSInteger byteCount = charCount/2;
    uint8_t *bytes = malloc(byteCount);
    for (int i=0; i<byteCount; i++) {
        unsigned int value;
        sscanf(myBuffer + i*2, "%2x",&value);
        bytes[i] = value;
    }
    NSData *data = [NSData dataWithBytes:bytes length:byteCount];
    return data;
}

//字符串转化成字典
- (NSDictionary *)convertToDic
{
    NSError *error = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"字符串转换成字典失败,error : %@",error.localizedDescription);
    }
    
    return jsonDic;
}

//判断是否包含字符串
- (BOOL)containString:(NSString *)aString
{
    if (!self) return false;
    if (iPhone < 8) {
        BOOL isExist = false;
        NSRange range = [self rangeOfString:aString];
        if (range.location != NSNotFound) {
            isExist = true;
        }
        
        return isExist;
    }
    
    return [self containsString:aString];
}

//获取中文字符的拼音
- (NSString *) phonetic
{
    NSMutableString *source = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

- (NSString *)getPhonetic
{
    NSString *result = [self phonetic];
    
    NSArray *list = [result componentsSeparatedByString:@" "];
    if (list.count > 1) {
        result = @"";
        for (NSString *str in list) {
            if (str.length > 0) {
                result = [result AppendString:[str substringToIndex:1]];
            }
        }
    }
    
    return result;
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    if (!format) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    NSString *strDate = [self stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(format ? format : @"yyyy-MM-dd HH:mm:ss")];
    NSDate *date = [dateFormatter dateFromString:strDate];
    return date;
}

//获取第一个字符
- (NSString *)firstString
{
    if (self.length > 1) {
        NSString *result = [self substringToIndex:1];
        return result;
    }
    
    return self;
}

- (NSData *)dataUsingUTF8
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark 使用MD5加密
- (NSString *)encryptUsingMD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    NSString *value = [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
    return value;
}

#pragma mark 拿取文件路径
- (NSString *)getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    if ([self hasSuffix:@".txt"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"documents"];
    }
    else if ([self hasSuffix:@".png"]||[self hasSuffix:@".jpg"]||[self hasSuffix:@".gif"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"images"];
    }
    else if ([self hasSuffix:@".amr"]||[self hasSuffix:@".wav"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    }
    if (![NSFileManager fileExistsAtPath:documentsDirectory]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:Nil error:&error];
        if (error) {
            NSLog(@"路径创建失败:%@",error.localizedDescription);
        }
    }
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self];
    return filePath;
}

#pragma mark 根据随机数生成文件名
+ (NSString *)getFileNameWith:(NSString *)type
{
    NSString *timeString = [CTB getDateWithFormat:@"yyyyMMddHHmmss"];
    NSString *randomCode = [CTB getRandomByLength:6];
    timeString = [timeString AppendString:randomCode];
    
    if (type.length <= 0) {
        return timeString;
    }
    
    return [timeString AppendFormat:@"%@.%@",timeString,type];
}

- (NSArray *)componentSeparatedByString:(NSString *)key
{
    NSString *string = self;
    if (key.length <= 0) {
        return [string componentsSeparatedByString:key];
    }
    
    if ([string hasPrefix:key]) {
        NSInteger len = key.length;
        string = [string substringFromIndex:len];
    }
    
    if ([string hasSuffix:key]) {
        NSInteger len = key.length;
        string = [string substringToIndex:string.length-len];
    }
    
    return [string componentsSeparatedByString:key];
}

- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement
{
    NSString *result = [self stringByReplacingOccurrencesOfString:target withString:replacement];
    return result;
}

//移除前缀
- (NSString *)removePrefix:(NSString *)aString
{
    if ([self hasPrefix:aString]) {
        return [self substringFromIndex:aString.length];
    }
    
    return self;
}

//移除后缀
- (NSString *)removeSuffix:(NSString *)aString
{
    if ([self hasSuffix:aString]) {
        return [self substringToIndex:self.length-aString.length];
    }
    
    return self;
}

- (BOOL)isNull
{
    if ([self isKindOfClass:[NSNull class]] || self.length <= 0) {
        return YES;
    }
    
    return NO;
}

- (long)parseInt:(int)type
{
    long value = strtoul([self UTF8String],nil,type);
    return value;
}

#pragma mark 根据格式(regex)匹配
- (BOOL)evaluateWithFormat:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:self];
    return isValid;
}

#pragma mark 解析字符串中的网址
- (NSArray *)getURL
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error = nil;
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSMatchingOptions options = NSMatchingReportProgress;
        NSArray *arrayOfAllMatches = [regex matchesInString:self
                                                    options:options
                                                      range:NSMakeRange(0, [self length])];
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [self substringWithRange:match.range];
            
            [array addObject:substringForMatch];
        }
    }
    
    return array;
}

@end

#pragma mark - --------NSData------------------------
@implementation NSData (NSObject)
#pragma mark NSData bytes转换成十六进制字符串
- (NSString *)hexString
{
    if (!self) {
        return nil;
    }
    //Byte *bytes = (Byte*)[self bytes];
    //NSString *hexStr = @"";
    //for(int i=0;i<[self length];i++)
    //{
    //    NSString *newHexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xff];///16进制数
    //    if([newHexStr length] == 1)
    //        hexStr=[NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
    //    else
    //        hexStr=[NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    //}
    
    NSString *dataStr = self.description;
    dataStr = [dataStr substringFromIndex:1];//去掉'<'
    dataStr = [dataStr substringToIndex:dataStr.length-1];//去掉'>'
    dataStr = [dataStr replaceString:@" " withString:@""];//去掉空格
    dataStr = [dataStr uppercaseString];//转为大写
    
    return dataStr;
}

- (NSData *)contactData:(NSData *)data
{
    NSMutableData *result = [NSMutableData dataWithData:self];
    [result appendData:data];
    
    return result;
}

- (NSString *)stringWithRange:(NSRange)range
{
    NSData *data = [self subdataWithRange:range];
    
    NSString *result = [data hexString];
    
    return result;
}

#pragma mark 数据分割
- (NSData *)dataWithStart:(NSInteger)start end:(NSInteger)end
{
    if (!self) {
        return nil;
    }
    NSInteger count = self.length - start - end;
    NSData *data = [self subdataWithRange:NSMakeRange(start, count)];
    
    return data;
}

- (id)unarchiveData
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return obj;
}

- (NSString *)stringUsingUTF8
{
    NSString *result = [self stringUsingEncode: NSUTF8StringEncoding];
    return result;
}

- (NSString *)stringUsingEncode:(NSStringEncoding)encode
{
    NSString *result = [[NSString alloc] initWithData:self encoding: encode];
    return result;
}

- (NSStringEncoding)getEncode
{
    BOOL isUser = true;
    NSStringEncoding GBK = [NSString stringEncodingForData:self encodingOptions:nil convertedString:nil usedLossyConversion:&isUser];
    
    return GBK;
}

- (NSData *)subdataWithRanges:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        return [self subdataWithRange:range];
    }
    
    NSInteger length = self.length - range.location;
    range.length = length;
    return [self subdataWithRange:range];
}

- (long)parseInt:(int)type
{
    long value = strtoul([[self hexString] UTF8String],nil,type);
    return value;
}


@end

#pragma mark - --------NSArray------------------------
@implementation NSArray (NSObject)

- (id)objAtIndex:(NSUInteger)index
{
    if (self.count > index) {
        return [self objectAtIndex:index];
    }
    
    return nil;
}

- (void)perExecute:(SEL)aSelector
{
    [self makeObjectsPerformSelector:aSelector];
}

- (void)perExecute:(SEL)aSelector withObject:(id)argument
{
    [self makeObjectsPerformSelector:aSelector withObject:argument];
}

- (NSArray *)getListKey:(id)key
{
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *dic in self) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        [list addObject:[dic objectForKey:key]];
    }
    
    return list;
}

//根据对象中的键值和值找到对象
- (id)getObjByKey:(NSString *)key value:(id)value
{
    for (id obj in self) {
        
        id result = [obj valueForKey:key];
        if([value isEqual:result])
        {
            return obj;
        }
    }
    
    return nil;
}

//根据对象中的键值和值找到对象所在下标
- (int)getIndexByKey:(NSString *)key value:(id)value
{
    int index = -1;
    for (int i=0; i<self.count; i++) {
        id obj = self[i];
        id result = [obj valueForKey:key];
        if([value isEqual:result])
        {
            index = i;
            break;
        }
    }
    
    return index;
}

//删除重复的对象
- (NSArray *)removeRepeatFor:(NSString *)key
{
    NSArray *result = [NSArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (id obj in self) {
        id value = [obj valueForKey:key];
        [dic setObject:obj forKey:value];
    }
    for (id obj in self) {
        id value = [obj valueForKey:key];
        id theObj = dic[value];
        if (theObj && ![result containsObject:theObj]) {
            result = [result arrayByAddingObject:theObj];
        }
    }
    
    return result;
}

//替换对象
- (NSArray *)replaceObject:(NSUInteger)index with:(id)anObject
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self];
    if (self.count > index) {
        [list replaceObjectAtIndex:index withObject:anObject];
    }
    return list;
}

@end

#pragma mark - --------NSDictionary------------------------
@implementation NSDictionary (NSObject)

- (NSDictionary *)dictionaryWithDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self];
    [dic addEntriesFromDictionary:dict];
    
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:dic];
    
    return result;
}

- (NSDictionary *)AppendDictionary:(NSDictionary *)dict
{
    return [self dictionaryWithDictionary:dict];
}

- (NSString *)convertToString
{
    NSError *error = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"NSDictionary转NSString出错,%@",error.localizedDescription);
    }
    
    if (!jsonData) return nil;
    
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    getUserData(nil);
    
    return result;
}

- (id)checkClass:(Class)aClass key:(id)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"该数据不是NSDictionary类型,%@,%@",self,key);
        return 0;
    }
    
    id result = [self objectForKey:key];
    if (!result || ![result isKindOfClass:aClass]) {
        return nil;
    }
    
    return result;
}

#pragma mark 根据关键字获取对应数据
- (int)intForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    int result = [value intValue];
    return result;
}

- (NSInteger)integerForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    NSInteger result = [value integerValue];
    return result;
}

- (long)longForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    long result = [value longValue];
    return result;
}

- (float)floatForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    float result = [value floatValue];
    return result;
}

- (double)doubleForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    double result = [value doubleValue];
    return result;
}

- (BOOL)boolForKey:(id)key
{
    id value = [self checkClass:[NSNumber class] key:key];
    value = value ?: [self checkClass:[NSString class] key:key];
    BOOL result = [value boolValue];
    return result;
}

- (NSString *)stringForKey:(id)key
{
    id value = [self checkClass:[NSString class] key:key];
    return value;
}

- (NSArray *)arrayForKey:(id)key
{
    id value = [self checkClass:[NSArray class] key:key];
    return value;
}

- (NSDictionary *)dictionaryForKey:(id)key
{
    id value = [self checkClass:[NSDictionary class] key:key];
    return value;
}

- (NSData *)dataForKey:(id)key
{
    id value = [self checkClass:[NSData class] key:key];
    return value;
}

//- (id)objectForKey:(id)key
//{
//    if (![self isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"该数据不是NSDictionary类型");
//        return nil;
//    }
//    
//    id result = [self objectForKey:key];
//    
//    return result;
//}

@end

#pragma mark - --------NSTimer------------------------
@implementation NSTimer (NSObject)
+ (NSTimer *)scheduled:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    return [NSTimer scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

- (void)destroy
{
    if ([self isValid]) {
        [self invalidate];
    }
}

@end

#pragma mark - --------NSDate------------------------
@implementation NSDate (NSObject)
+ (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc] init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:[NSDate date]];
}

- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc] init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:self];
}

@end

#pragma mark - --------UIColor------------------------
@implementation UIColor (NSObject)

- (UIColor *)colorWithAlpha:(CGFloat)alpha
{
    return [self colorWithAlphaComponent:alpha];
}

- (CGFloat *)getValue
{
    const CGFloat *cs=CGColorGetComponents(self.CGColor);
    size_t index = CGColorGetNumberOfComponents(self.CGColor);
    
    CGFloat *result = (CGFloat *)malloc(sizeof(CGFloat)*4);
    
    if (index == 2) {
        result[0] = result[1] = result[2] = cs[0];
        result[3] = cs[1];
    }
    else if (index == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重新选择颜色" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else if (index == 4) {
        result[0] = cs[0];
        result[1] = cs[1];
        result[2] = cs[2];
        
        result[3] = cs[3];
    }
    
    return result;
}

@end

#pragma mark - --------UIFont------------------------
@implementation UIFont (NSObject)

+ (CGFloat)sizeWithString:(NSString *)aString forWidth:(CGFloat)width
{
    return [self sizeWithString:aString forWidth:width lineBreakMode:NSLineBreakByTruncatingTail];
}

+ (CGFloat)sizeWithString:(NSString *)aString forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGFloat fontSize;
    UIFont *font = [UIFont systemFontOfSize:Screen_Width*1.1];
    [aString sizeWithFont:font minFontSize:10.0f actualFontSize:&fontSize forWidth:width lineBreakMode:lineBreakMode];
    
    return fontSize;
}

@end

#pragma mark - --------UIImage------------------------
@implementation UIImage (NSObject)

- (UIImage *)imageWithCapInsets:(UIEdgeInsets)capInsets
{
    return [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)imageFromLibrary:(NSString *)imgName
{
    NSString *filePath = [imgName getFilePath];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

@end

#pragma mark - --------UIView------------------------
@implementation UIView (NSObject)

- (void)setOriginX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setOriginY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (void)setOriginX:(CGFloat)x Y:(CGFloat)y
{
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

- (void)setSizeToW:(CGFloat)w
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, w, self.frame.size.height);
}

- (void)setSizeToH:(CGFloat)h
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
}

- (void)setSizeToW:(CGFloat)w height:(CGFloat)h
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h);
}

- (void)setOriginX:(CGFloat)x width:(CGFloat)w
{
    self.frame = CGRectMake(x, self.frame.origin.y, w, self.frame.size.height);
}

- (void)setOriginY:(CGFloat)y height:(CGFloat)h
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, h);
}

- (void)setOrigin:(CGPoint)origin
{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setSize:(CGSize)size
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setCenterX:(CGFloat)x
{
    self.center = CGPointMake(x, self.center.y);
}

- (void)setCenterY:(CGFloat)y
{
    self.center = CGPointMake(self.center.x, y);
}

- (void)setCenterX:(CGFloat)x Y:(CGFloat)y
{
    self.center = CGPointMake(x, y);
}

- (void)setToParentCenter
{
    UIView *parentView = self.superview;
    if (parentView) {
        self.center = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    }
}

- (void)rotation:(CGFloat)angle
{
    self.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);//旋转angle度
    //self.transform = CGAffineTransformMakeRotation(angle);//旋转angle度
}

- (id)viewWITHTag:(NSInteger)tag
{
    return [self viewWithTag:tag];
}

- (id)viewWithClass:(Class)aClass
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (UIView *v in listView) {
        if ([v isKindOfClass:[aClass class]]) {
            [list addObject:v];
        }
    }
    
    return list.firstObject;
}

- (id)viewWithClass:(Class)aClass tag:(NSInteger)tag
{
    NSArray *listView = self.subviews;
    NSMutableArray *list = [NSMutableArray array];
    for (UIView *v in listView) {
        if ([v isKindOfClass:[aClass class]] && v.tag == tag) {
            [list addObject:v];
        }
    }
    
    return list.firstObject;
}

- (NSArray *)viewsWithClass:(Class)aClass
{
    NSArray *list = @[];
    NSArray *listView = self.subviews;
    for (UIView *v in listView) {
        if ([v isKindOfClass:[aClass class]]) {
            list = [list arrayByAddingObject:v];
        }
    }
    
    return list;
}

@end

#pragma mark - --------UIControl------------------------
@implementation UIControl (NSObject)

- (void)addDownTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchDown];
}

- (void)addUpOutsideTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpOutside];
}

- (void)addUpInsideTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end

#pragma mark - --------UIButton------------------------
@implementation UIButton (NSObject)

- (void)setNormalTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setHighlightedTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

- (void)setTitleColor:(UIColor *)color normal:(BOOL)normal highlighted:(BOOL)highlighted
{
    if (normal) {
        [self setNormalTitleColor:color];
    }
    if (highlighted) {
        [self setHighlightedTitleColor:color];
    }
}

- (void)setNormalImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setHighlightedImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateHighlighted];
}

- (void)setImage:(UIImage *)image normal:(BOOL)normal highlighted:(BOOL)highlighted
{
    if (normal) {
        [self setNormalImage:image];
    }
    if (highlighted) {
        [self setHighlightedImage:image];
    }
}

- (void)setNormalBackgroundImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setHighlightedBackgroundImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)setBackgroundImage:(UIImage *)image normal:(BOOL)normal highlighted:(BOOL)highlighted
{
    if (normal) {
        [self setNormalBackgroundImage:image];
    }
    if (highlighted) {
        [self setHighlightedBackgroundImage:image];
    }
}

@end

#pragma mark - --------UITableView------------------------
@implementation UITableView (NSObject)

- (id)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellForRowAtIndexPath:indexPath];
}

- (id)cellWithRow:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    id cell = [self cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath rowCount:(NSInteger)rowCount
{
    [self deleteAtIndexPath:indexPath rowCount:rowCount withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath rowCount:(NSInteger)rowCount withRowAnimation:(UITableViewRowAnimation)animation
{
    if (rowCount <= 0) {
        //删除区间
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
        [self deleteSections:indexSet withRowAnimation:animation];
    }else{
        //删除某一行
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
}

@end

@implementation UITableViewCell (NSObject)
//cell high
- (UIView *)cellAddBottomLineWithHigh:(CGFloat)h
{
    CGFloat w = self.contentView.frame.size.width;
    
    return [self cellAddBottomLineWithSize:CGSizeMake(w, h)];
}

//cell size
- (UIView *)cellAddBottomLineWithSize:(CGSize)size
{
    CGFloat w = size.width;
    CGFloat h = size.height;
    UIView *View = [self.contentView viewWithTag:200];;
    if (!View) {
        View = [[UIView alloc] initWithFrame:CGRectMake(10, h-0.6, w-20, 0.6)];
        [self.contentView addSubview:View];
    }
    View.tag = 200;
    View.backgroundColor = [UIColor clearColor];
    View.layer.masksToBounds = YES;
    View.layer.borderWidth = 0.3;
    View.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    
    return View;
}

@end

@implementation NSIndexPath (NSObject)

+ (NSIndexPath *)inRow:(NSInteger)row inSection:(NSInteger)section
{
    return [NSIndexPath indexPathForRow:row inSection:section];
}

@end

@implementation NSUserDefaults (NSObject)

+ (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end

#pragma mark - UINavigationController
@implementation UINavigationController (NSObject)

- (UIViewController *)getControllerFromClassName:(NSString *)className
{
    NSArray *listNav = self.viewControllers;
    for (UIViewController *V in listNav) {
        if ([NSStringFromClass(V.class) isEqualToString:className]) {
            return V;
        }
    }
    
    return NULL;
}

@end

#pragma mark - UIApplication
@implementation UIApplication (NSObject)

+ (id)sharedApplicationDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

@end

#pragma mark - NSError
@implementation NSError (NSObject)

+ (NSError *)initWithMsg:(NSString *)errMsg code:(NSInteger)code
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
				
    NSError *errPtr = [NSError errorWithDomain:@"kCFStreamErrorDomainPOSIX" code:code userInfo:info];
    
    return errPtr;
}

@end

#pragma mark - --------NSNotificationCenter------------------------
@implementation NSNotificationCenter (NSObject)

+ (void)postNoticeName:(NSString *)aName object:(id)anObject
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
}

+ (void)postNoticeName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

@end

#pragma mark - --------NSFileManager------------------------
@implementation NSFileManager (NSObject)

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

+ (BOOL)removeItemAtPath:(NSString *)path
{
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"删除文件 : %@",error.localizedDescription);
    }
    return result;
}

+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attr
{
    return [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:attr];
}

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error
{
    return [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:error];
}

@end

#pragma mark - --------NSBundle------------------------
@implementation NSBundle (NSObject)

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext
{
    return [[NSBundle mainBundle] pathForResource:name ofType:ext];
}

@end

#pragma mark - --------NSThread------------------------
@implementation NSThread (NSObject)

+ (void)sleep:(NSTimeInterval)ti
{
    [NSThread sleepForTimeInterval:ti];
}

@end

#pragma mark - --------NSObject------------------------
@implementation NSObject (NSObject)

- (void)duration:(NSTimeInterval)dur action:(SEL)action
{
    [self performSelector:action withObject:nil afterDelay:dur];
}

- (void)duration:(NSTimeInterval)dur action:(SEL)action with:(id)anArgument
{
    [self performSelector:action withObject:anArgument afterDelay:dur];
}

- (NSData *)archivedData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

- (void)isNULLToEqual:(id)obj
{
    if (self == nil) {
    }
}

#pragma mark - 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
- (NSDictionary *)getObjectData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [value getObjectInternal];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

- (id)getObjectInternal
{
    if([self isKindOfClass:[NSString class]]
       || [self isKindOfClass:[NSNumber class]]
       || [self isKindOfClass:[NSNull class]])
    {
        return self;
    }
    
    if([self isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = (NSArray *)self;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[[objarr objectAtIndex:i] getObjectInternal] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([self isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = (NSDictionary *)self;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[[objdic objectForKey:key] getObjectInternal] forKey:key];
        }
        return dic;
    }
    return [self getObjectData];
}

@end
