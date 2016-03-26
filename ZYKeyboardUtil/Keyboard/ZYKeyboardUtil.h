//
//  ZYKeyboardUtil.h
//  ZYKeyboardUtil
//
//  Created by lzy on 15/12/26.
//  Copyright © 2015年 lzy . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static CGFloat const DURATION_ANIMATION = 0.5f;

typedef enum {
    KeyboardActionDefault,
    KeyboardActionShow,
    KeyboardActionHide
}KeyboardAction;

@protocol KeyboardUtilProtocol <NSObject>
- (void)adaptiveViewHandleWithController:(UIViewController *)viewController adaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION;
@end


#pragma mark - KeyboardInfo(model)
@interface KeyboardInfo : NSObject

@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) CGRect frameBegin;
@property (assign, nonatomic) CGRect frameEnd;
@property (assign, nonatomic) CGFloat heightIncrement;
@property (assign, nonatomic) KeyboardAction action;
@property (assign, nonatomic) BOOL isSameAction;

- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction;
@end


#pragma mark - ZYKeyboardUtil
@interface ZYKeyboardUtil : NSObject<KeyboardUtilProtocol>

//Block
typedef void (^animateWhenKeyboardAppearBlock)(int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement);
typedef void (^animateWhenKeyboardDisappearBlock)(CGFloat keyboardHeight);
typedef void (^printKeyboardInfoBlock)(ZYKeyboardUtil *keyboardUtil, KeyboardInfo *keyboardInfo);
typedef void (^animateWhenKeyboardAppearAutomaticAnimBlock)(ZYKeyboardUtil *keyboardUtil);

- (void)setAnimateWhenKeyboardAppearBlock:(animateWhenKeyboardAppearBlock)animateWhenKeyboardAppearBlock;
- (void)setAnimateWhenKeyboardAppearAutomaticAnimBlock:(animateWhenKeyboardAppearAutomaticAnimBlock)animateWhenKeyboardAppearAutomaticAnimBlock;
- (void)setAnimateWhenKeyboardDisappearBlock:(animateWhenKeyboardDisappearBlock)animateWhenKeyboardDisappearBlock;
- (void)setPrintKeyboardInfoBlock:(printKeyboardInfoBlock)printKeyboardInfoBlock;
@end


