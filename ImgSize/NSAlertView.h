//
//  NSAlertView.h
//  AppCaidan
//
//  Created by Yin on 14-9-27.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAlertView : UIControl

- (nullable id)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles;

@property (nullable,nonatomic,weak) id /*<UIAlertViewDelegate>*/ delegate;
@property (nullable,nonatomic,copy) NSString *title;
@property (nullable,nonatomic,copy) NSString *message;   // secondary explanation text


// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// cancel button which will be positioned based on HI requirements. buttons cannot be customized.
//- (NSInteger)addButtonWithTitle:(nullable NSString *)title;// returns index of button. 0 based.
- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic) NSInteger cancelButtonIndex;      // if the delegate does not implement -alertViewCancel:, we pretend this button was clicked on. default is -1

@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;	// -1 if no otherButtonTitles or initWithTitle:... not used
@property(nonatomic,readonly,getter=isVisible) BOOL visible;

// shows popup alert animated.
- (void)show;

// hides alert sheet or popup. use this method when you need to explicitly dismiss the alert.
// it does not need to be called if the user presses on a button
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

// Alert view style - defaults to UIAlertViewStyleDefault
@property(nonatomic,assign) UIAlertViewStyle alertViewStyle;

// Retrieve a text field at an index
// The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field. */
- (nullable UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end

@protocol AlertViewDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(nullable NSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(nullable NSAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);

- (void)willPresentAlertView:(nullable NSAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // before animation and showing view
- (void)didPresentAlertView:(nullable NSAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // after animation

- (void)alertView:(nullable NSAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0); // before animation and hiding view
- (void)alertView:(nullable NSAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(nullable NSAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);

@end
