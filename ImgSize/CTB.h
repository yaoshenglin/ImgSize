//
//  CTB.h
//  baiduMap
//  Controller Tool Box
//  Created by yinhaibo on 14-1-3.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//  <#(NSString *)#>
//*****************************
//如果支持arc，release的事情由系统来做。
//如果不支持arc,release则会在申请内存后自动添加上去
#ifndef paixiu_PXISARC_h
#define paixiu_PXISARC_h
#ifndef PX_STRONG
#if __has_feature(objc_arc)
#define PX_STRONG strong
#else
#define PX_STRONG retain
#endif
#endif
#ifndef PX_WEAK
#if __has_feature(objc_arc_weak)
#define PX_WEAK weak
#elif __has_feature(objc_arc)
#define PX_WEAK unsafe_unretained
#else
#define PX_WEAK assign
#endif
#endif

#if __has_feature(objc_arc)
#define PX_AUTORELEASE(expression) expression
#define PX_RELEASE(expression) expression
#define PX_RETAIN(expression) expression
#else
#define PX_AUTORELEASE(expression) [expression autorelease]
#define PX_RELEASE(expression) [expression release]
#define PX_RETAIN(expression) [expression retain]
#endif
#endif
//*****************************

#define select(x) @selector(x)
#define iPhone [[[UIDevice currentDevice] systemVersion] floatValue]

#define isSimulator (BOOL)[[UIDevice currentDevice].name isEqualToString:@"iPhone Simulator"]

#define iPhone7 iPhone>=7.0

#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define barH (CGFloat)[UIApplication sharedApplication].statusBarFrame.size.height
#define currrentNavH (CGFloat)([UINavigationBar appearance].frame.size.height)
#define navH (CGFloat)((currrentNavH > 0) ? currrentNavH : 44.0)
#define topH (CGFloat)((iPhone >= 7) ? barH : 0)
#define viewW Screen_Width
#define viewH Screen_Height-barH-navH

#define iPhone6S_Width 414.0f
#define iPhone6S_Height 736.0f

#define TabBar_Height 48.0f
#define ViewSize 0
#define scaleW Screen_Width/320.0f
#define scaleH Screen_Height/480.0f
#define navBarW1 70.0f
#define navBarW2 102.0f
#define leftWidth 244.0f
#define CellBound (CGFloat)(iPhone<7 ? 10.0f : 0.0f)
#define Unused(x) (void)x
#define String(x) [NSString stringWithFormat:@"%@",x]
#define intToString(x) [NSString stringWithFormat:@"%d",x]
#define floatToString(x) [NSString stringWithFormat:@"%f",x]
#define NotificationCenter [NSNotificationCenter defaultCenter]
#define UserDefaults [NSUserDefaults standardUserDefaults]
#define varStr(x) [NSString stringWithFormat:@"%s",#x]
#define N(x) @(x)
#define NSOK NSLog(@"OK")
#define Linefeed printf("\n")
#define S(x) [NSString stringWithCString:x encoding:NSUTF8StringEncoding]

#ifdef DEBUG
    #define Log(x) NSLog(@"%@",x);
#else
    #define Log(x) Unused(x);
#endif

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIKit.h>

typedef CF_ENUM(NSStringEncoding, CFStringBuilt) {
    GBEncoding = 0x80000632 /* kTextEncodingUnicodeDefault + kUnicodeUTF32LEFormat */
};

NS_INLINE CGFloat GetMinX(CGRect rect) { return rect.origin.x; }
NS_INLINE CGFloat GetMinY(CGRect rect) { return rect.origin.y; }
NS_INLINE CGFloat GetMaxX(CGRect rect) { return rect.origin.x+rect.size.width; }
NS_INLINE CGFloat GetMaxY(CGRect rect) { return rect.origin.y+rect.size.height; }
NS_INLINE CGFloat GetWidth(CGRect rect) { return rect.size.width; }
NS_INLINE CGFloat GetHeight(CGRect rect) { return rect.size.height; }

NS_INLINE CGFloat GetVMinX(UIView *View) { return CGRectGetMinX(View.frame); }
NS_INLINE CGFloat GetVMinY(UIView *View) { return CGRectGetMinY(View.frame); }
NS_INLINE CGFloat GetVMaxX(UIView *View) { return CGRectGetMaxX(View.frame); }
NS_INLINE CGFloat GetVMaxY(UIView *View) { return CGRectGetMaxY(View.frame); }
NS_INLINE CGFloat GetVCenterX(UIView *View) { return CGRectGetMidX(View.frame); }
NS_INLINE CGFloat GetVCenterY(UIView *View) { return CGRectGetMidY(View.frame); }
NS_INLINE CGPoint GetBCenter(UIView *View) { return CGPointMake(View.frame.size.width/2, View.frame.size.height/2); }
NS_INLINE CGFloat GetBCenterX(UIView *View) { return View.frame.size.width/2; }
NS_INLINE CGFloat GetBCenterY(UIView *View) { return View.frame.size.height/2; }
NS_INLINE CGFloat GetVWidth(UIView *View) { return CGRectGetWidth(View.frame); }
NS_INLINE CGFloat GetVHeight(UIView *View) { return CGRectGetHeight(View.frame); }

NS_INLINE CGRect GetRect(CGFloat x,CGFloat y,CGFloat w,CGFloat h) { return CGRectMake(x, y, w, h); };
NS_INLINE CGPoint GetPoint(CGFloat x,CGFloat y) { return CGPointMake(x, y); }
NS_INLINE CGSize  GetSize(CGFloat w,CGFloat h) { return CGSizeMake(w, h); }
NS_INLINE CATransform3D Trans3DScale(CGFloat sx, CGFloat sy, CGFloat sz) { return CATransform3DMakeScale(sx, sy, sz); };
NS_INLINE NSString* StringWithRect(CGFloat x,CGFloat y,CGFloat w,CGFloat h) {
    CGRect rect = CGRectMake(x, y, w, h);
    return NSStringFromCGRect(rect);
}
NS_INLINE NSString* StringWithPoint(CGFloat x,CGFloat y) {
    CGPoint point = CGPointMake(x, y);
    return NSStringFromCGPoint(point);
}
NS_INLINE NSValue *valueWithTran3DScale(CGFloat sx, CGFloat sy, CGFloat sz) {
    return [NSValue valueWithCATransform3D:Trans3DScale(sx, sy, sz)];
}

typedef struct { double latitude; double longitude;} LatLng;

NS_INLINE LatLng LatLngMake(double lat,double lng) {
    LatLng lan;
    lan.latitude = lat;
    lan.longitude = lng;
    return lan;
}

//@protocol CTBDelegate <NSObject>
//@optional
//- (void)ButtonEvents:(UIButton *)button;
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
//
//@end

/** @file */

// <#(NSString *)#>
@interface CTB : NSObject<UIActionSheetDelegate,UIAlertViewDelegate>
//获取MainStoryboard中的UIViewController
+ (id)getControllerWithIdentity:(NSString *)identifier storyboard:(NSString *)title;
id getController(NSString *identifier,NSString *title);
+ (id)NSClassFromString:(NSString *)className;
//获取App窗口
+ (UIWindow *)getWindow;
//创建按钮
+ (UIButton *)buttonType:(UIButtonType)type delegate:(id)delegate to:(UIView *)View tag:(NSInteger)tag title:(NSString *)title img:(NSString *)imgName;
+ (UIButton *)buttonType:(UIButtonType)type delegate:(id)delegate to:(UIView *)View tag:(NSInteger)tag title:(NSString *)title img:(NSString *)imgName action:(SEL)action;
+ (UISearchBar *)searchBarStyle:(UISearchBarStyle)style tintColor:(UIColor *)tintColor toV:(UIView *)View delegate:(id)delegate;
+ (void)addTarget:(id)delegate action:(SEL)action button:(UIButton *)button, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setTextColor:(UIColor *)color View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setRadius:(CGFloat)radius View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)addDownTarget:(id)delegate action:(SEL)action button:(UIButton *)button, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setBorderWidth:(CGFloat)width View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setBorderWidth:(CGFloat)width Color:(UIColor *)color View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setBottomLineToBtn:(id)button, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setBottomLineHigh:(CGFloat)high Color:(UIColor *)color toV:(id)button, ...NS_REQUIRES_NIL_TERMINATION;
+ (void)setLeftViewWithWidth:(CGFloat)w textField:(UITextField *)textField, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setRightViewWithWidth:(CGFloat)w textField:(UITextField *)textField, ... NS_REQUIRES_NIL_TERMINATION;


#pragma mark 添加圆角
+ (void)drawBorder:(UIView *)view radius:(float)radius borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor;
+ (void)setHidden:(BOOL)hidden View:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark 导航栏按钮
+ (UIBarButtonItem *)BackBarButtonWithTitle:(NSString *)title;
+ (UIBarButtonItem *)BarButtonWithTitle:(NSString *)title target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarButtonWithStyle:(UIBarButtonSystemItem)style target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarButtonWithImg:(UIImage *)image target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarButtonWithImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarButtonWithBtnImg:(UIImage *)image target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarButtonWithBtnImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag;
+ (UIBarButtonItem *)BarWithBtnImgName:(NSString *)imgName target:(id)target tag:(NSUInteger)tag rect:(CGRect)rect;
+ (UIBarButtonItem *)BarButtonWithCustomView:(UIView *)View;
+ (UIBarButtonItem *)BarWithWidth:(CGFloat)w title:(NSString *)title;
+ (UIBarButtonItem *)BarWithTitle:(NSString *)title delegate:(id)delegate action:(SEL)action;
+ (NSArray *)BarButtonWithTitles:(NSArray *)array delegate:(id)delegate;
+ (NSArray *)BarButtonWithImgs:(NSArray *)array delegate:(id)delegate;
+ (void)tabBarTextColor:(UIColor *)aColor selected:(UIColor *)bColor;
//创建个性化文本输入框
+ (UITextField *)createTextField:(int)tag hintTxt:(NSString *)placeholder V:(UIView *)View;
//创建标签
+ (UILabel *)labelTag:(int)tag toView:(UIView *)View text:(NSString *)text wordSize:(CGFloat)size;
+ (UILabel *)labelTag:(int)tag toView:(UIView *)View text:(NSString *)text wordSize:(CGFloat)size alignment:(NSTextAlignment)textAlignment;
//创建文本输入框
+ (UITextField *)textFieldTag:(int)tag holderTxt:(NSString *)placeholder V:(UIView *)View delegate:(id)delegate;
//创建分段控件
+ (UISegmentedControl *)segmentedTag:(int)tag Itmes:(NSArray *)items toView:(UIView *)View;
//表格视图
+ (UITableView *)tableViewStyle:(UITableViewStyle)style delegate:(id)delegate toV:(UIView *)View;
+ (id)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (void)showFinishView:(UITableView *)tableView;
//添加GIF图片
+ (UIWebView *)gifViewInitWithFile:(NSString *)Path;
#pragma mark UIImagePickerController
+ (UIImagePickerController *)imagePickerType:(UIImagePickerControllerSourceType)sourceType delegate:(id)delegate;
//创建弹出提示框
+ (UIAlertView *)showMsgWithTitle:(NSString *)title msg:(NSString *)msg;
+ (UIAlertView *)showMsg:(NSString *)msg;
+ (UIAlertView *)showMsg:(NSString *)msg tag:(int)tag delegate:(id)delegate;
+ (UIAlertView *)alertWithTitle:(NSString *)title Delegate:(id)delegate tag:(int)tag;
+ (UIAlertView *)alertWithMessage:(NSString *)message Delegate:(id)delegate tag:(int)tag;
+ (UIAlertView *)alertWithTitle:(NSString *)title msg:(NSString *)message Delegate:(id)delegate tag:(int)tag;

#pragma mark 设置TextFiled背景框
+ (void)setTextFieldsBackground:(UITextField *)textField, ...;
+ (NSString *)trimTextField:(UITextField *)textField;

//将a视图添加到b视图上并约束b视图的边界
+ (void)addView:(UIView *)aView toView:(UIView *)bView;

#pragma mark 从指定的视图上获取想要的视图类
id getSuperView(Class aClass,UIView *View);
id getSuperViewBy(Class aClass,UIView *View,NSInteger tag);
//根据类名从导航中获取指定视图
+ (UIViewController *)getControllerFrom:(UINavigationController *)Nav className:(NSString *)className;
id getControllerFrom(UINavigationController *Nav,NSString *className);
id getControllerFor(UIViewController *VC,NSString *className);
id getParentController(UIViewController *VC,NSString *className);
+ (void)hiddenBottomBarWhenPushedFor:(UIViewController *)viewController;
+ (void)removeClassWithName:(NSString *)className fromNav:(UINavigationController *)Nav;
+ (void)removeController:(UIViewController *)viewController;
+ (void)removeControllers:(NSArray *)viewControllers fromVC:(UIViewController *)VC;
+ (void)removeControllers:(NSArray *)viewControllers fromNav:(UINavigationController *)Nav;
+ (void)removeController:(UIViewController *)viewController fromNav:(UINavigationController *)Nav;
void forbiddenNavPan(UIViewController *VC,BOOL isForbid);
//显示活动指示器
+ (void)showActivityInView:(UIView *)View;
+ (void)showActivityInView:(UIView *)View style:(UIActivityIndicatorViewStyle)style;
+ (void)showBigSignView:(UIView *)View;
+ (void)showSignView:(UIView *)View;
+ (void)hiddenSignView:(UIView *)View;
//设置状态栏字体颜色
//+ (UIStatusBarStyle)setStatusBarStyle;
//
//+ (void)setFrame:(UIViewController *)viewController;
//隐藏键盘
+ (void)HiddenKeyboard:(id)txtField, ... NS_REQUIRES_NIL_TERMINATION;

//判断路径或者文件是否存在
+ (BOOL)isExistWithPath:(NSString *)path;
//获取沙盒路径
+ (NSString *)getSandboxPath;
//扩展成路径
+ (NSString *)getPath:(NSString *)path name:(NSString *)name;
//保存文件到本地
+ (void)saveFileWithPath:(NSString *)path FileName:(NSString *)name content:(id)content;
//读
+ (NSData *)readFileWithPath:(NSString *)path FileName:(NSString *)name;
//读取字典数据
+ (id)readWithPath:(NSString *)path FileName:(NSString *)name;

//打印文字,name可为空
+ (void)PrintString:(id)obj headName:(NSString *)name;
+ (void)printNum:(CGFloat)result headName:(NSString *)name;
+ (NSString *)printDic:(NSDictionary *)dic;

+ (void)setViewBounds:(UIViewController *)viewController;
//增加黑色背景状态栏
+ (void)addStatusBarToView:(UIView *)view;

+ (void)HiddenView:(BOOL)hidden with:(UIView *)View, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark 设置Navigation Bar背景图片
+ (void)setNavigationBarBackground:(NSString *)imgName to:(UIViewController *)viewController;
+ (void)setNavBackImg:(NSString *)imgName to:(UIViewController *)viewController;
+ (void)imgColor:(UIColor *)color to:(UIViewController *)viewController; 

#pragma mark - ---------------设置动画---------------------------------
+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect;
+ (void)animateWithDur:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (NSArray *)getAnimationData:(BOOL)isBig;
+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur;// 特殊动画效果
+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur values:(NSArray *)listValue;
+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect complete:(SEL)action delegate:(id)delegate;
+ (void)setAnimationWith:(UIView *)View rect:(CGRect)rect complete:(SEL)action delegate:(id)delegate duration:(NSTimeInterval)duration;
+ (void)setAnimationWith:(UIView *)View point:(CGPoint)point duration:(NSTimeInterval)duration;
+ (void)setAnimationWith:(UIView *)View toX:(CGFloat)x duration:(NSTimeInterval)duration;
+ (void)setAnimationWith:(UIView *)View toY:(CGFloat)y duration:(NSTimeInterval)duration;
+ (void)setAnimationWith:(UIView *)View point:(CGPoint)point complete:(SEL)action delegate:(id)delegate;
+ (void)setAnimationWith:(UIView *)View size:(CGSize)size;
+ (void)setAnimationWith:(UIView *)View size:(CGSize)size complete:(SEL)action delegate:(id)delegate;
+ (void)setAnimationWith:(UIScrollView *)tableView Offset:(CGPoint)point;
+ (void)setAnimationWith:(UIScrollView *)tableView Offset:(CGPoint)point duration:(NSTimeInterval)duration;

//***************
//2个配套使用,Two supporting the use
+ (void)setAnimationWith:(NSTimeInterval)duration delegate:(id)delegate complete:(SEL)action;
+ (void)commitAnimations;
//***************

//重新设置视图的位置和尺寸
+ (CGRect)setRect:(CGRect)rect scale:(CGFloat)scale;

+ (BOOL)containsPoint:(CGPoint)point inRect:(CGRect)rect;//rect中包含点point

+ (UIColor *)colorWith:(NSString *)imgName atPixel:(CGPoint)point;
+ (UIColor *)colorBy:(UIImage *)image atPixel:(CGPoint)point;

#pragma mark 绑定图片，保证图片不变形
+ (void)bindImageToFitSize:(UIImageView *)imageView image:(UIImage *)image minY:(float)minY maxY:(float)maxY;

+ (void)setSizeWithView:(UIImageView *)imgView withImg:(UIImage *)img;//设置图片，保证不变形
+ (UIImage *)fixRotaion:(UIImage *)image;
#pragma mark 截取部分图像
+ (UIImage*)getSubImage:(UIImage *)image rect:(CGRect)rect;
+ (void)getSubImgView:(UIImageView *)imgView;
#pragma mark 将图片分解成图片数组
+ (NSArray *)getImagesWith:(UIImage *)image count:(int)count;
+ (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size;
+ (void)setImgView:(UIImageView *)imgView withImgName:(NSString *)imgName;//根据图片名字设置图片，保证不变形
+ (void)setView:(UIView *)View toCentre_X:(CGFloat)x Y:(CGFloat)y;//设置视图的中心坐标
+ (void)setImgView:(UIImageView *)imgView image:(UIImage *)image masksToSize:(CGSize)size;//约束到指定尺寸内
+ (UIImage *)setImgWithName:(NSString *)imgName Capinsets:(UIEdgeInsets)capInsets;//根据参数进行图片处理
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

#pragma mark 根据字体参数计算label的高度
+ (float)heightOfContent:(NSString *)content width:(CGFloat)width fontSize:(CGFloat)size;
+ (CGSize)getSizeWith:(NSString *)content wordSize:(CGFloat)big size:(CGSize)size;
+ (CGSize)getSizeWith:(NSString *)content font:(UIFont *)font size:(CGSize)size;
+ (CGFloat)getLabelHighBy:(NSString *)content wordSize:(CGFloat)big width:(CGFloat)width;
+ (CGFloat)getLabelWidthBy:(NSString *)content wordSize:(CGFloat)big high:(CGFloat)high;

+ (void)setWidthWith:(UILabel *)label content:(NSString *)content size:(CGSize)size;

#pragma mark 获得GBK编码
+ (NSStringEncoding)getGBKEncoding;

#pragma mark - ========处理字典中的NSNull类数据=====================
+ (NSString *)stringWith:(NSDictionary *)dic key:(NSString *)key;
#pragma mark 合并字符串
NSString *mergedString(NSString *aString,NSString *bString);
NSString *pooledString(NSString *aString,NSString *bString,NSString *midString);

+ (CGSize)getWidthBy:(NSString *)string font:(UIFont *)font;
+ (NSAttributedString *)attribute:(NSString *)aString font:(UIFont *)font range:(NSRange)range;

#pragma mark 颜色转换
+ (UIColor *)colorWithHexString: (NSString *) stringToConvert;
UIColor *colorWithHex(NSString *stringToConvert);
UIColor *colorWithRGB(CGFloat r,CGFloat g,CGFloat b,CGFloat alpha);
+ (UIColor *)colorWithImgName:(NSString *)imgName;
+ (UIColor *)colorWithImg:(UIImage *)image;
+ (UIColor *)setColor:(UIColor *)color opacity:(CGFloat)alpha;

#pragma mark 设置背景色
+ (UIColor *)setBackgroundColor:(UIColor *)color opacity:(CGFloat)alpha;

#pragma mark - =============颜色转图片=========================
+ (UIImage *)imgColor:(UIColor *)color;

#pragma mark 保存图片到文件
+ (void)saveImgToFile:(NSString *)FilePath withImg:(UIImage *)image;
//压缩图片
+ (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImg:(UIImage *)img scaledToSize:(CGSize)newSize;
#pragma mark 压缩ImageData, 指定最大的kb数
+ (NSData *)scaleImageToDataByMaxKB:(long)maxKB image:(UIImage *)image;
+ (NSData *)getImgDataBy:(UIImage *)image;

+ (void)deleteFileFor:(NSString *)path;

#pragma mark 获取AppCaidan.db的路径
NSArray *getDBPath();
+ (NSArray *)getDBPath;

+ (void)getContentsAtPath:(NSString *)path inArray:(NSMutableArray *)array;

#pragma mark 获取-info.plist中的数据
/**
 获取-info.plist中的数据
 @param message CFBundleVersion -> Build, CFBundleShortVersionString -> Version
 
 @return App信息详情
 */
+ (NSDictionary *)infoDictionary;
#pragma mark 获取App版本号
+ (NSString *)getAppVersion;
#pragma mark 获取AppBuidl
+ (NSInteger)getAppBuild;

NSString *getPartString(NSString *string,NSString *aString,NSString *bString);
NSString *getUTF8String(NSString *string);//使用UTF8编码
NSString *outUTF8String(NSString *string);//使用UTF8解码
NSString *replaceString(NSString *string,NSString *oldString,NSString *newString);//用b字符替换a字符
UIKIT_EXTERN NSString *StringFromCGRect(UIView *View);


#pragma mark 从字符串中获取指定某字符到某字符之间的字符串
+ (NSString *)scanString:(NSString *)aString Start:(NSString *)a End:(NSString *)b;
#pragma mark 判断是否包含
+ (BOOL)contain:(NSString *)bString inString:(NSString *)aString;
BOOL containString(NSString *string,NSString *aString);

//获取字符串中的
+ (CLLocation *)getLocationWith:(NSString *)locationStr;

#pragma mark 判断是否为手机号
+ (BOOL)isMobile:(NSString *)mobile;
+ (BOOL)isEmail:(NSString *)email;//判断是否为邮箱

#pragma mark tableView添加底部线条(分隔线)
+ (UIView *)setBottomLineAt:(UITableView *)tableView cell:(UITableViewCell *)cell cellH:(CGFloat)cellH;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell delegate:(id)delegate;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath delegate:(id)delegate;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView dicData:(NSDictionary *)dicData;

+ (UIView *)setBottomLineAtTables:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell;
+ (UIView *)setBottomLineAtTables:(UITableView *)tableView dicData:(NSDictionary *)dicData;
+ (UIView *)setBottomLineAtTable:(UITableView *)tableView cell:(UITableViewCell *)cell h:(CGFloat)h;

void hiddenNavBar(UIViewController *VC,BOOL hidden,BOOL animaion);

#pragma mark 设置状态栏字体颜色
+ (void)setStatusBarStyleWith:(UIApplication *)application;
#pragma mark 隐藏tabbar
+ (void)hiddenTabbar:(BOOL)hidden delegate:(id)delegate;

#pragma mark 状态栏显示信息
//+ (UIButton *)showMsgToStatusBarWith:(NSString *)message time:(NSTimeInterval)time;
//+ (void)HiddenStatusBarMsg;

//获取系统时间
+ (NSString *)getDateWithFormat:(NSString *)format;
+ (NSString *)getSystemTime:(NSDate *)date format:(NSString *)format;

+ (void)reSetPoint:(UIView *)View withHigh:(CGFloat)high;

//判断该视图在导航中是否存在
+ (BOOL)isExistSelf:(UIViewController *)VC;

//获取本机IP地址
+ (NSDictionary *)getLocalIPAddress;
+ (void)getLocalIPAddress:(void (^)(NSDictionary *dicIP))completion;
//获取外网IP
+ (void)getWANIPAddressWithCompletion:(void(^)(NSString *IPAddress))completion;

#pragma mark - ----------UIViewController-----------------
+ (void)UIControllerEdgeNone:(UIViewController *)VC;
#pragma mark 打印调试信息
+ (void)printDebugMsg:(NSString *)msg;
void CTBNSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

#pragma mark - ----------其它------------------------
+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block;
+ (void)asyncWithBlock:(dispatch_block_t)block; //异步
+ (void)syncWithBlock:(dispatch_block_t)block;  //同步
+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock;//先异步
+ (NSUserDefaults *)getUserDefaults;
NSUserDefaults *getUserDefaults();
void setUserData(id obj,NSString *key);
void removeObjectForKey(NSString *key);
id getUserData(NSString *key);

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName;
+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName  object:(id)anObject;
+ (void)postNoticeName:(NSString *)aName object:(id)anObject;
+ (void)postNoticeName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

+ (void)Request:(NSString *)urlString body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);
//解析域名
+ (char *)parseDomain:(NSString *)domain;
+ (NSString *)parserDomain:(NSString *)domain;

//发送本地通知
+ (void)sendLocalNotice;

//键盘通知事件
+ (void)KeyboardWillShowAddObserver:(id)observer selector:(SEL)aSelector;
+ (void)KeyboardWillHideAddObserver:(id)observer selector:(SEL)aSelector;

#pragma mark APP核对
+ (NSArray *)checkHasOwnApp;

//获取该目录路径下全部文件名
+ (NSArray *)getAllItemsInDirectory:(NSString *)path;
//删除该目录路径下全部文件
+ (BOOL)deleteAllItemsInDirectory:(NSString *)path;

#pragma mark - ----------过滤HTML------------------------
+ (NSString *)removeHTML:(NSString *)html;

#pragma mark - ----------处理异常操作------------------------
+ (void)Try:(dispatch_block_t)try Catch:(dispatch_block_t)catch Finally:(dispatch_block_t)finally;

#pragma mark - ---------Objective-C---------------------
#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByString:(NSString *)string Length:(int)length;
#pragma mark 生成长度为length的随机字符串
+ (NSString *)getRandomByLength:(int)length;
#pragma mark 获取当前WIFI SSID信息
+ (NSDictionary *)currentWiFiSSID;

@end

@interface NSObject (CTBDelegate)

- (void)ButtonEvents:(UIButton *)button;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

#pragma mark - NSString
@interface NSString (NSObject)

+ (NSString *)stringWith:(NSString *)string;
+ (NSString *)stringSplicing:(NSArray *)array;//拼接字符串
+ (NSString *)jsonStringWithString:(NSString *) string;
+ (NSString *)jsonStringWithArray:(NSArray *)array;
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)jsonStringWithObject:(id) object;
+ (NSString *)format:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (NSString *)readFile:(NSString *)path encoding:(NSStringEncoding)enc;
- (BOOL)writeToFile:(NSString *)path encoding:(NSStringEncoding)enc;
- (NSString *)AppendString:(NSString *)aString;
- (NSString *)AppendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

#pragma mark 日期字符串转成日期
- (NSDate *)dateWithFormat:(NSString *)format;

//十六进制字符串转换为NSData bytes
- (NSData *)dataByHexString;
- (NSString *)uppercaseByHexString;
//字符串转化成字典
- (NSDictionary *)convertToDic;
//判断是否包含字符串
- (BOOL)containString:(NSString *)aString;
//获取中文字符的拼音
- (NSString *) phonetic;
- (NSString *)getPhonetic;
- (NSString *)firstString;//获取第一个字符
- (NSData *)dataUsingUTF8;
#pragma mark 使用MD5加密
- (NSString *)encryptUsingMD5;//字符md5加密

#pragma mark 拿取文件路径
- (NSString *)getFilePath;
#pragma mark 根据随机数生成文件名
+ (NSString *)getFileNameWith:(NSString *)type;
#pragma mark 使用key分割字符
- (NSArray *)componentSeparatedByString:(NSString *)key;
#pragma mark 替换字符
- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement;

//移除前缀
- (NSString *)removePrefix:(NSString *)aString;
//移除后缀
- (NSString *)removeSuffix:(NSString *)aString;

- (BOOL)isNull;//判断是否为空字符串
- (BOOL)isNonEmpty;

- (long)parseInt:(int)type;//转化为十进制

#pragma mark 根据格式(regex)匹配
- (BOOL)evaluateWithFormat:(NSString *)regex;

#pragma mark 解析字符串中的网址
- (NSArray *)getURL;
//IP专用
- (NSString *)getHex;

@end

#pragma mark - NSData
@interface NSData (NSObject)
//NSData bytes转换成十六进制字符串
- (NSString *)hexString;
- (NSData *)contactData:(NSData *)data;
- (NSString *)stringWithRange:(NSRange)range;
//数据分割
- (NSData *)dataWithStart:(NSInteger)start end:(NSInteger)end;
//解析存档数据
- (id)unarchiveData;
//转化成字符串
- (NSString *)stringUsingUTF8;
- (NSString *)stringUsingEncode:(NSStringEncoding)encode;
- (NSStringEncoding)getEncode;
- (NSData *)subdataWithRanges:(NSRange)range;
- (long)parseInt:(int)type;

@end

#pragma mark - NSArray
@interface NSArray (NSObject)

- (id)objAtIndex:(NSInteger)index;//根据下标获取数据

- (void)perExecute:(SEL)aSelector;
- (void)perExecute:(SEL)aSelector withObject:(id)argument;
- (void)perExecute:(SEL)aSelector forClass:(Class)class;

- (NSArray *)getListKey:(id)key;

- (id)getObjByKey:(NSString *)key value:(id)value;//根据对象中的键值和值找到对象
//根据对象中的键和值找到对象所在下标
- (int)getIndexByKey:(NSString *)key value:(id)value;
//删除重复的对象
- (NSArray *)removeRepeatFor:(NSString *)key;
//根据对象中的键和值删除对象
- (NSArray *)removeObjByKey:(NSString *)key value:(id)value;
//替换对象
- (NSArray *)replaceObject:(NSUInteger)index with:(id)anObject;

@end

#pragma mark - NSDictionary
@interface NSDictionary (NSObject)

- (NSDictionary *)dictionaryWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)AppendDictionary:(NSDictionary *)dict;
- (NSString *)convertToString;

- (id)checkClass:(Class)aClass key:(id)key;//判断key对应的值的类型
- (id)checkClasses:(NSArray *)listClass key:(id)key;

//根据关键字获取对应数据
- (NSString *)stringForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSData *)dataForKey:(id)key;

- (NSInteger)integerForKey:(id)key;
- (float)floatForKey:(id)key;
- (double)doubleForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (int)intForKey:(id)key;
- (long)longForKey:(id)key;

@end

#pragma mark - --------NSTimer------------------------
@interface NSTimer (NSObject)
+ (NSTimer *)scheduled:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

- (void)destroy;

@end

#pragma mark - --------NSDate
@interface NSDate (NSObject)
+ (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithFormat:(NSString *)format;

@end

#pragma mark - UIColor
@interface UIColor (NSObject)

- (UIColor *)colorWithAlpha:(CGFloat)alpha;

- (CGFloat *)getValue;

@end

#pragma mark - UIFont
@interface UIFont (NSObject)

+ (CGFloat)sizeWithString:(NSString *)aString forWidth:(CGFloat)width;
+ (CGFloat)sizeWithString:(NSString *)aString forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

#pragma mark - UIImage
@interface UIImage (NSObject)

- (UIImage *)imageWithCapInsets:(UIEdgeInsets)capInsets;
+ (UIImage *)imageFromLibrary:(NSString *)imgName;

#pragma mark 截取部分图像
- (UIImage *)imageWithInRect:(CGRect)rect;

@end

#pragma mark - UIView
@interface UIView (NSObject)

- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setOriginX:(CGFloat)x Y:(CGFloat)y;
- (void)setSizeToW:(CGFloat)w;
- (void)setSizeToH:(CGFloat)h;
- (void)setSizeToW:(CGFloat)w height:(CGFloat)h;
- (void)setSizeWithCenterToW:(CGFloat)w height:(CGFloat)h;
- (void)setOriginX:(CGFloat)x width:(CGFloat)w;
- (void)setOriginY:(CGFloat)y height:(CGFloat)h;

- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;
- (void)setOrigin:(CGPoint)origin size:(CGSize)size;

- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;
- (void)setCenterX:(CGFloat)x Y:(CGFloat)y;
- (void)setToParentCenter;
- (void)setOriginScale:(CGFloat)scale;
- (void)setCenterScale:(CGFloat)scale;

- (void)rotation:(CGFloat)angle;//旋转angle度

- (id)viewWITHTag:(NSInteger)tag;
- (id)viewWithClass:(Class)aClass;
- (id)viewWithClass:(Class)aClass tag:(NSInteger)tag;
- (NSArray *)viewsWithClass:(Class)aClass;//该类的合集

//添加视图约束
- (void)addConstraintsWithFormat:(NSString *)format views:(NSDictionary *)views;

//视图切换动画
- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration;
- (void)commitAnimations;
- (void)addAnimationType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval)duration operation:(dispatch_block_t)operation completion:(dispatch_block_t)completion;

- (UIActivityIndicatorView *)addActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)stopActivityIndicator;
- (void)removeActivityIndicator;

//添加虚线边框
- (void)dashLineForBorderWithRadius:(CGFloat)radius;
- (void)dashLineWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth dashPattern:(CGFloat)dashPattern spacePattern:(CGFloat)spacePattern lineColor:(UIColor *)lineColor;

- (void)playGifImgWithPath:(NSString *)imagePath;

@end

#pragma mark - UIControl
@interface UIControl (NSObject)

- (void)addDownTarget:(id)target action:(SEL)action;
- (void)addUpOutsideTarget:(id)target action:(SEL)action;
- (void)addUpInsideTarget:(id)target action:(SEL)action;

@end

#pragma mark - UIButton
@interface UIButton (NSObject)

- (void)setNormalTitleColor:(UIColor *)color;
- (void)setHighlightedTitleColor:(UIColor *)color;
- (void)setTitleColor:(UIColor *)color normal:(BOOL)normal highlighted:(BOOL)highlighted;

- (void)setNormalImage:(UIImage *)image;
- (void)setHighlightedImage:(UIImage *)image;
- (void)setImage:(UIImage *)image normal:(BOOL)normal highlighted:(BOOL)highlighted;

- (void)setNormalBackgroundImage:(UIImage *)image;
- (void)setHighlightedBGImage:(UIImage *)image;
- (void)setBackgroundImage:(UIImage *)image normal:(BOOL)normal highlighted:(BOOL)highlighted;

- (void)setNormalTitle:(NSString *)title;
- (void)setHighlightedTitle:(NSString *)title;

- (void)setContentAlignment:(UIControlContentHorizontalAlignment)alignment;
- (void)setContentAlignment:(UIControlContentHorizontalAlignment)alignment edgeInsets:(UIEdgeInsets)edgeInsets;

@end

#pragma mark - UINavigationController
@interface UINavigationController (NSObject)

- (UIViewController *)getControllerFromClassName:(NSString *)className;

@end

#pragma mark - UIApplication
@interface UIApplication (NSObject)

+ (id)sharedApplicationDelegate;

@end

#pragma mark - NSError
@interface NSError (NSObject)

+ (NSError *)initWithMsg:(NSString *)errMsg code:(NSInteger)code;

@end

#pragma mark - NSNotificationCenter
@interface NSNotificationCenter (NSObject)

+ (void)postNoticeName:(NSString *)aName object:(id)anObject;
+ (void)postNoticeName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end

#pragma mark - NSFileManager
@interface NSFileManager (NSObject)

+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (BOOL)removeItemAtPath:(NSString *)path;
+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;
+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attr;
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

@end

#pragma mark - UILabel
@interface UILabel (NSObject)

- (void)attribute:(NSString *)aString fontSize:(CGFloat)fontSize range:(NSRange)range;
- (void)attribute:(NSString *)aString font:(UIFont *)font range:(NSRange)range;
- (void)attributedText:(NSString *)text name:(NSString *)name value:(id)value range:(NSRange)range;
- (void)attributedText:(NSString *)text dicValue:(NSDictionary *)dicValue range:(NSRange)range;

@end

@interface UITableView (NSObject)

- (id)cellAtIndexPath:(NSIndexPath *)indexPath;
- (id)cellWithRow:(NSInteger)row;
- (void)deleteAtIndexPath:(NSIndexPath *)indexPath rowCount:(NSInteger)rowCount;
- (void)deleteAtIndexPath:(NSIndexPath *)indexPath rowCount:(NSInteger)rowCount withRowAnimation:(UITableViewRowAnimation)animation;

@end

@interface UITableViewCell (NSObject)

- (UIView *)cellAddBottomLineWithHigh:(CGFloat)h;
- (UIView *)cellAddBottomLineWithSize:(CGSize)size;

@end

@interface NSIndexPath (NSObject)

+ (NSIndexPath *)inRow:(NSInteger)row inSection:(NSInteger)section;

@end

@interface NSUserDefaults (NSObject)

+ (NSUserDefaults *)defaults;

@end

#pragma mark - --------NSBundle------------------------
@interface NSBundle (NSObject)

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;

@end

#pragma mark - --------NSThread------------------------
@interface NSThread (NSObject)

+ (void)sleep:(NSTimeInterval)ti;

@end

#pragma mark - NSObject
@interface NSObject (NSObject)

- (void)duration:(NSTimeInterval)dur action:(SEL)action;
- (void)duration:(NSTimeInterval)dur action:(SEL)action with:(id)anArgument;
- (NSData *)archivedData;//存档数据
#pragma mark - 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
- (NSDictionary *)getObjectData;

@end

