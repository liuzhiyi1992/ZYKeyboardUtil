# ZYKeyboardUtil
Util Handed all keyboard events with Block Conveniently  
<br>
![](https://img.shields.io/badge/pod-v0.2.1-blue.svg)
![](https://img.shields.io/badge/supporting-objectiveC-yellow.svg)
![](https://img.shields.io/badge/Advantage-Automation-red.svg)  
<br>
-v0.2.1更新全自动处理键盘遮盖事件（需配置animateWhenKeyboardAppearAutomaticAnimBlock）,具体使用参照Demo

<br>
#**Features：**
ZYKeyboardUtil 通过对每次键盘展开时的增量heightIncrement作处理 应对 第三方键盘 分次弹出的问题

![](https://raw.githubusercontent.com/liuzhiyi1992/ZYKeyboardUtil/master/ZYKeyboardUtil/DisplayFile/demo_1.jpg)


<br>
同时能处理多层嵌套情况下控件的键盘遮盖问题，UITextField嵌套两层UIView例子演示：

![](https://raw.githubusercontent.com/liuzhiyi1992/ZYKeyboardUtil/master/ZYKeyboardUtil/DisplayFile/keyboardUtil.gif)

<br>
#**explain：**
#####写在前面：
ZYKeyboardUtil 通过lazy方式注册键盘通知监听者，核心工作围绕一个model和三个Block，内部类KeyboardInfo作为model存储着每次处理时所需的键盘信息。animateWhenKeyboardAppearBlock作键盘展示时的处理，animateWhenKeyboardDisappearBlock作键盘收起时的处理，而printKeyboardInfoBlock用作在必要时输出键盘信息。AppearBlock和DisappearBlock统一做了UIViewAnimation，使用时只需要编写需要的界面变化即可。
  
<br>
#**CocoaPods：**  
```pod 'ZYKeyboardUtil', '~> 0.2.1'```  

<br>
###Class：
####-KeyboardInfo:
**property：**  
- animationDuration:  响应动画的过程时长  
- frameBegin：触发键盘事件前键盘frame  
- frameEnd：变化后键盘frame  
- heightIncrement：单次键盘变化增量  
- action：键盘事件枚举  
- isSameAction：是否同一种动作    

**func：**  
- fillKeyboardInfoWithDuration:frameBegin:frameEnd:heightIncrement:action:isSameAction:    
为KeyboardInfo各属性赋值。  

####-ZYKeyboardUtil:  
**property：**  
- appearPostIndex：键盘分次弹出情况中 弹出 的次数
- keyboardInfo  
- haveRegisterObserver：是否已经注册监听者  
- animateWhenKeyboardAppearBlock：弹出Block  
- animateWhenKeyboardDisappearBlock：收起Block  
- printKeyboardInfoBlock：输出键盘信息Block    
- animateWhenKeyboardAppearBlockAutomaticAnim：自动处理键盘遮盖事件Block（需提供输入view和controllerView）  
**func：**  
- setAnimateWhenKeyboardAppearBlock:    
- setAnimateWhenKeyboardDisappearBlock:  
- setPrintKeyboardInfoBlock:    
- setAnimateWhenKeyboardAppearBlockAutomaticAnim:  

<br>  
#**Usage：**  
```objc
self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
```  
创建一个ZYKeyboard对象，为了让其生存在整个页面实现功能的时间段内，让你的controller持有他吧。

```objc
[_keyboardUtil setAnimateWhenKeyboardAppearBlock:^(int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement) {
    //do something when keyboard appear
}];

[_keyboardUtil setAnimateWhenKeyboardDisappearBlock:^(CGFloat keyboardHeight) {
    //do something when keyboard dismiss
}];

[_keyboardUtil setPrintKeyboardInfoBlock:^(ZYKeyboardUtil *keyboardUtil, KeyboardInfo *keyboardInfo) {
    //you can get keyboardInfo hear when animation ended
}];
```  
<br>
#####0.2.1版本更新后，增加animateWhenKeyboardAppearAutomaticAnimBlock，在Block中return一个字典[含两个value: 你的inputView(key:ADAPTIVE_VIEW(宏),controller的view(key:CONTROLLER_VIEW(宏)))]即可，不同animateWhenKeyboardAppearBlock同时使用，否则后者优先。   例子：
```objc
[_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^NSDictionary *{
    NSDictionary *adaptiveDict = [NSDictionary dictionaryWithObjectsAndKeys:weakSelf.mainTextField, ADAPTIVE_VIEW, weakSelf.view, CONTROLLER_VIEW, nil];
    return adaptiveDict;
}];
```

That all, thanks。
<br>
#**License：** 
ZYKeyboardUtil is available under the MIT license. See the LICENSE file for more info.
