//
//  myKeyboardType.h
//  T
//
//  Created by Yinhaibo on 14-3-1.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#ifndef Screen_Height
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#endif

#import <Foundation/Foundation.h>

@interface myKeyboardType : NSObject
{
//    UIButton *doneInKeyboardButton;
    
    myKeyboardType *keyboards;
}

@property (nonatomic) BOOL isRegist;
@property (nonatomic) BOOL isShow;
@property (retain,nonatomic) UIButton *doneButton;
@property (retain,nonatomic) id target;
@property (nonatomic) SEL action;

+ (myKeyboardType *)sharedInstance;
+(UIKeyboardType)keyboardTypeTo:(id)delegate action:(SEL)action;
+(void)addObserver;
+(void)hidden;
+(void)remove;

- (void)handleKeyboardWillShow:(NSNotification *)notification;
- (void)handleKeyboardWillHide:(NSNotification *)notification;

@end
