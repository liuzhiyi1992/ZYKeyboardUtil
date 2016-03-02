//
//  ViewController.m
//  ZYKeyboardUtil
//
//  Created by lzy on 16/1/7.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "ViewController.h"
#import "ZYKeyboardUtil.h"

#define MARGIN_KEYBOARD 20

@interface ViewController ()

@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;
@property (weak, nonatomic) IBOutlet UITextField *mainTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainTextField.delegate = self;
    
    [self configKeyBoardRespond];
}

- (void)configKeyBoardRespond {
     self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    
    __unsafe_unretained ViewController *weakSelf = self;
    
    //自定义键盘弹出处理
    //--------use animateWhenKeyboardAppearBlockAutomaticAnim, animateWhenKeyboardAppearBlock must be nil.--------
    /*
    [_keyboardUtil setAnimateWhenKeyboardAppearBlock:^(int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement) {
        
        NSLog(@"\n\n键盘弹出来第 %d 次了~  高度比上一次增加了%0.f  当前高度是:%0.f"  , appearPostIndex, keyboardHeightIncrement, keyboardHeight);
        
        //处理
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect convertRect = [weakSelf.mainTextField.superview convertRect:weakSelf.mainTextField.frame toView:window];
        
        if (CGRectGetMinY(keyboardRect) - MARGIN_KEYBOARD < CGRectGetMaxY(convertRect)) {
            CGFloat signedDiff = CGRectGetMinY(keyboardRect) - CGRectGetMaxY(convertRect) - MARGIN_KEYBOARD;
            //updateOriginY
            CGFloat newOriginY = CGRectGetMinY(weakSelf.view.frame) + signedDiff;
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, newOriginY, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }
    }];
     */
    
    //全自动键盘弹出处理（需将inputView和controller.view传入）
    //--------use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearBlockAutomaticAnim will lose effectiveness.--------
    [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^NSDictionary *{
        NSDictionary *adaptiveDict = [NSDictionary dictionaryWithObjectsAndKeys:weakSelf.mainTextField, ADAPTIVE_VIEW, weakSelf.view, CONTROLLER_VIEW, nil];
        return adaptiveDict;
    }];
    
    [_keyboardUtil setAnimateWhenKeyboardDisappearBlock:^(CGFloat keyboardHeight) {
        NSLog(@"\n\n键盘在收起来~  上次高度为:+%f", keyboardHeight);
        
        //uodateOriginY
        CGFloat newOriginY = 0;
        weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, newOriginY, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
    }];
    
    
    [_keyboardUtil setPrintKeyboardInfoBlock:^(ZYKeyboardUtil *keyboardUtil, KeyboardInfo *keyboardInfo) {
        
        NSLog(@"\n\n拿到键盘信息 和 ZYKeyboardUtil对象");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.mainTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   [self.mainTextField resignFirstResponder];
    return YES;
}


@end
