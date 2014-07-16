//
//  KYTipsView.h
//  Nemo
//
//  Created by zhihui zhao on 13-10-12.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//



@class KYBgIndicator;

@interface KYTipsView : UIView

+ (void)showWithMessage:(NSString *)message timeout:(NSTimeInterval)timeout;
+ (void)showWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showWithTitle:(NSString *)title message:(NSString *)message showRect:(CGRect)rect;

+ (void)showColorIndicator;
+ (void)showColorIndicatorWithShowRect:(CGRect)rect;
+ (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message showRect:(CGRect)rect;

+ (void)dismiss;
+ (BOOL)isVisible;

@end

@interface UIView (UIViewExTips)

- (void)showPopMsg:(NSString *)msg timeout:(NSTimeInterval)timeout;
- (void)showPopMsg:(NSString *)msg atY:(CGFloat)y timeout:(NSTimeInterval)timeout;
- (void)showPopTitle:(NSString *)title msg:(NSString *)msg timeout:(NSTimeInterval)timeout;

- (void)showPopTitle:(NSString *)title msg:(NSString *)msg;
- (void)showPopTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center;
- (void)showPopTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center shouldFreezeUI:(BOOL)freezeUI;

- (void)showColorIndicatorFreezeUI:(BOOL)freezeUI;
- (void)showColorIndicatorWithCenter:(CGPoint)center;
- (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message;
- (void)showColorIndicatorWithTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center;
- (void)showColorIndicatorWithTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center shouldFreezeUI:(BOOL)freezeUI;

- (void)dismissMsg;
- (void)dismiss;

@end



@interface KYTipsContentView : UIView
@property (nonatomic, strong) NSString*				title;
@property (nonatomic, strong) NSString*				message;
@property (nonatomic, strong) KYBgIndicator*	indicator;
- (CGSize)framesFitSize:(CGSize)size;
@end



@interface KYBgIndicator : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end



@interface KYTipsWindow : UIWindow

@end



@interface KYTipsViewController : UIViewController

- (id)initWithView:(KYTipsView *)tipsView;

@end

