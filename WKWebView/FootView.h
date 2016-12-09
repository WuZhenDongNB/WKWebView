//
//  FootView.h
//  WKWebView
//
//  Created by Mr. Wu on 16/12/2.
//  Copyright © 2016年 wuzhendong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FootViewDelegate <NSObject>

-(void)goBackClick:(UIButton*)Bt_goBack;
-(void)goFowardClick:(UIButton*)Bt_goFoward;
-(void)goReloadClick:(UIButton*)Bt_reload;
-(void)goSafarrClick:(UIButton*)Bt_Safari;

@end

@interface FootView : UIView
@property (weak, nonatomic) UIButton *backBtn;
@property (weak, nonatomic) UIButton *forwardBtn;
@property (weak, nonatomic) UIButton *reloadBtn;
@property (weak, nonatomic) UIButton *browserBtn;
@property(nonatomic,weak) id delegate;


@end
