//
//  ZYKeyboardUtil.m
//  ZYKeyboardUtil
//
//  Created by lzy on 15/12/26.
//  Copyright © 2015年 lzy . All rights reserved.
//

#import "ZYKeyboardUtil.h"

#define MARGIN_KEYBOARD_DEFAULT 10

#define textView_no_anim_begin if ([_adaptiveView isKindOfClass:[UITextView class]]) {\
                                [CATransaction begin];\
                                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];\
                                }
#define textView_no_anim_end if ([_adaptiveView isKindOfClass:[UITextView class]]) {\
                                [CATransaction commit];\
                                }

static UIView *FIRST_RESPONDER;

@interface ZYKeyboardUtil() <UITextFieldDelegate, UITextViewDelegate>

@property (assign, nonatomic) BOOL keyboardObserveEnabled;
@property (assign, nonatomic) int appearPostIndex;
@property (strong, nonatomic) KeyboardInfo *keyboardInfo;
@property (assign, nonatomic) BOOL haveRegisterObserver;
@property (weak, nonatomic) UIViewController *adaptiveController;
@property (weak, nonatomic) UIView *adaptiveView;

@property (copy, nonatomic) animateWhenKeyboardAppearBlock animateWhenKeyboardAppearBlock;
@property (copy, nonatomic) animateWhenKeyboardAppearAutomaticAnimBlock animateWhenKeyboardAppearAutomaticAnimBlock;
@property (copy, nonatomic) animateWhenKeyboardDisappearBlock animateWhenKeyboardDisappearBlock;
@property (copy, nonatomic) printKeyboardInfoBlock printKeyboardInfoBlock;

@end


@implementation ZYKeyboardUtil

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - lazy注册观察者
- (void)registerObserver {
    if (_haveRegisterObserver == YES) {
        return;
    }
    
    self.haveRegisterObserver = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)adaptiveViewHandleWithController:(UIViewController *)viewController adaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *adaptiveViewList = [NSMutableArray array];
    [adaptiveViewList addObject:adaptiveView];
    
    va_list var_list;
    va_start(var_list, adaptiveView);
    UIView *view;
    while ((view = va_arg(var_list, UIView *))) {
        [adaptiveViewList addObject:view];
    }
    va_end(var_list);
    
    for (UIView *adaptiveViews in adaptiveViewList) {
        FIRST_RESPONDER = nil;
        UIView *firstResponderView = [self recursionTraverseFindFirstResponderIn:adaptiveViews];
        if (nil != firstResponderView) {
            self.adaptiveView = firstResponderView;
            [self fitKeyboardAutomatically:firstResponderView controllerView:viewController.view keyboardRect:_keyboardInfo.frameEnd];
            self.adaptiveController = viewController;
            break;
        }
    }
}

//递归视图
- (UIView *)recursionTraverseFindFirstResponderIn:(UIView *)view {
    if ([view isFirstResponder]) {
        FIRST_RESPONDER = view;
    } else {
        for (UIView *subView in view.subviews) {
            if ([subView isFirstResponder]) {
                FIRST_RESPONDER = subView;
                return FIRST_RESPONDER;
            }
            [self recursionTraverseFindFirstResponderIn:subView];
        }
    }
    if (nil != FIRST_RESPONDER) {
        if ([FIRST_RESPONDER isKindOfClass:[UITextView class]]) {
            ((UITextView *)FIRST_RESPONDER).delegate = self;
        } else if ([FIRST_RESPONDER isKindOfClass:[UITextField class]]) {
            ((UITextField *)FIRST_RESPONDER).delegate = self;
        }
    }
    return FIRST_RESPONDER;
}

- (void)fitKeyboardAutomatically:(UIView *)adaptiveView controllerView:(UIView *)controllerView keyboardRect:(CGRect)keyboardRect {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect convertRect = [adaptiveView.superview convertRect:adaptiveView.frame toView:window];
    
    if (CGRectGetMinY(keyboardRect) - MARGIN_KEYBOARD_DEFAULT < CGRectGetMaxY(convertRect)) {
        CGFloat signedDiff = CGRectGetMinY(keyboardRect) - CGRectGetMaxY(convertRect) - MARGIN_KEYBOARD_DEFAULT;
        //updateOriginY
        CGFloat newOriginY = CGRectGetMinY(controllerView.frame) + signedDiff;
        controllerView.frame = CGRectMake(controllerView.frame.origin.x, newOriginY, controllerView.frame.size.width, controllerView.frame.size.height);
    }
}

- (void)restoreKeyboardAutomatically {
    [self textViewHandle];
    CGRect tempFrame = self.adaptiveController.view.frame;
    if (self.adaptiveController.navigationController == nil || self.adaptiveController.navigationController.navigationBar.hidden == YES) {
        tempFrame.origin.y = 0.f;
        self.adaptiveController.view.frame = tempFrame;
    } else {
        tempFrame.origin.y = 64.f;
        self.adaptiveController.view.frame = tempFrame;
    }
}

- (void)textViewHandle {
    //还原时 textView可能会出现offset错乱现象
    if ([_adaptiveView isKindOfClass:[UITextView class]]) {
        [(UITextView *)_adaptiveView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - 重写KeyboardInfo set方法，调用animationBlock
- (void)setKeyboardInfo:(KeyboardInfo *)keyboardInfo {
    //home键使应用进入后台也会有某些通知
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    _keyboardInfo = keyboardInfo;
    if(!keyboardInfo.isSameAction || (keyboardInfo.heightIncrement != 0)) {
        
        [UIView animateWithDuration:keyboardInfo.animationDuration animations:^{
            switch (keyboardInfo.action) {
                case KeyboardActionShow:
                    if(self.animateWhenKeyboardAppearBlock != nil) {
                        self.animateWhenKeyboardAppearBlock(++self.appearPostIndex, keyboardInfo.frameEnd, keyboardInfo.frameEnd.size.height, keyboardInfo.heightIncrement);
                    } else if (self.animateWhenKeyboardAppearAutomaticAnimBlock != nil) {
                        self.animateWhenKeyboardAppearAutomaticAnimBlock(self);
                    }
                    break;
                case KeyboardActionHide:
                    if(self.animateWhenKeyboardDisappearBlock != nil) {
                        self.animateWhenKeyboardDisappearBlock(keyboardInfo.frameEnd.size.height);
                        self.appearPostIndex = 0;
                    } else {
                        //auto restore
                        [self restoreKeyboardAutomatically];
                    }
                    break;
                default:
                    break;
            }
            [CATransaction commit];
        }completion:^(BOOL finished) {
            if(self.printKeyboardInfoBlock != nil && self.keyboardInfo != nil) {
                self.printKeyboardInfoBlock(self, keyboardInfo);
            }
        }];
    }
}

#pragma mark - delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self triggerAction];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    [self triggerAction];
}

- (void)triggerAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.keyboardInfo = _keyboardInfo;
    });
}

#pragma mark - 重写Block set方法，懒加载方式注册观察者
/**
 * @brief handle the covering event youself when keyboard Appear, Animation automatically.
 *
 * use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearAutomaticAnimBlock will be invalid.
 */
- (void)setAnimateWhenKeyboardAppearBlock:(animateWhenKeyboardAppearBlock)animateWhenKeyboardAppearBlock {
    _animateWhenKeyboardAppearBlock = animateWhenKeyboardAppearBlock;
    [self registerObserver];
}

/**
 * @brief handle the covering automatically, you must invoke the method adaptiveViewHandleWithController:adaptiveView: by the param keyboardUtil.
 *
 * use animateWhenKeyboardAppearAutomaticAnimBlock, animateWhenKeyboardAppearBlock must be nil.
 */
- (void)setAnimateWhenKeyboardAppearAutomaticAnimBlock:(animateWhenKeyboardAppearAutomaticAnimBlock)animateWhenKeyboardAppearAutomaticAnimBlock {
    _animateWhenKeyboardAppearAutomaticAnimBlock = animateWhenKeyboardAppearAutomaticAnimBlock;
    [self registerObserver];
}

/**
 * @brief restore the UI youself when keyboard disappear.
 *
 * if not configure this Block, automatically itself.
 */
- (void)setAnimateWhenKeyboardDisappearBlock:(animateWhenKeyboardDisappearBlock)animateWhenKeyboardDisappearBlock {
    _animateWhenKeyboardDisappearBlock = animateWhenKeyboardDisappearBlock;
    [self registerObserver];
}

- (void)setPrintKeyboardInfoBlock:(printKeyboardInfoBlock)printKeyboardInfoBlock {
    _printKeyboardInfoBlock = printKeyboardInfoBlock;
    [self registerObserver];
}

#pragma mark 响应selector
- (void)keyboardWillShow:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionShow];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if(self.keyboardInfo.action == KeyboardActionShow){
        //[self handleKeyboard:notification keyboardAction:KeyboardActionShow];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionHide];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    //置空
    self.keyboardInfo = nil;
}

#pragma mark 处理键盘事件
- (void)handleKeyboard:(NSNotification *)notification keyboardAction:(KeyboardAction)keyboardAction {
    //进入后台触发某些通知,不响应
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    //解析通知
    NSDictionary *infoDict = [notification userInfo];
    CGRect frameBegin = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat previousHeight;
    if(self.keyboardInfo.frameEnd.size.height > 0) {
        previousHeight = self.keyboardInfo.frameEnd.size.height;
    }else {
        previousHeight = 0;
    }
    
    CGFloat heightIncrement = frameEnd.size.height - previousHeight;
    
    BOOL isSameAction;
    if(self.keyboardInfo.action == keyboardAction) {
        isSameAction = YES;
    }else {
        isSameAction = NO;
    }
    
    KeyboardInfo *info = [[KeyboardInfo alloc] init];
    [info fillKeyboardInfoWithDuration:DURATION_ANIMATION frameBegin:frameBegin frameEnd:frameEnd heightIncrement:heightIncrement action:keyboardAction isSameAction:isSameAction];
    
    self.keyboardInfo = info;
}

- (void)fillKeyboardInfoWithKeyboardInfo:(KeyboardInfo *)keyboardInfo duration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction {
    keyboardInfo.animationDuration = duration;
    keyboardInfo.frameBegin = frameBegin;
    keyboardInfo.frameEnd = frameEnd;
    keyboardInfo.heightIncrement = heightIncrement;
    keyboardInfo.action = action;
    keyboardInfo.isSameAction = isSameAction;
}

@end




#pragma mark - KeyboardInfo(model)
@interface KeyboardInfo()
- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction;
@end

@implementation KeyboardInfo

- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction {
    self.animationDuration = duration;
    self.frameBegin = frameBegin;
    self.frameEnd = frameEnd;
    self.heightIncrement = heightIncrement;
    self.action = action;
    self.isSameAction = isSameAction;
}

@end






//ZYKeyboardUtil is available under the MIT license.
//Please visit https://github.com/liuzhiyi1992/ZYKeyboardUtil for details.