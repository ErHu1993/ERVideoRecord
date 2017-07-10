//
//  ZingCameraViewController.m
//  Zing
//
//  Created by 胡广宇 on 2017/3/30.
//  Copyright © 2017年 Witgo. All rights reserved.
//

#import "CameraViewController.h"
#import "ERCameraManager.h"
#import <UIKit/UIKit.h>

@interface CameraViewController ()
/** 背景视图 */
@property (nonatomic, strong) UIView *backView;
/** 录制/暂停按钮 */
@property (nonatomic, strong) UIButton *inputButton;
/**  左侧 返回/重录 按钮, */
@property (nonatomic, strong) UIButton *leftButton;
/** 右侧 切换/确认 按钮 */
@property (nonatomic, strong) UIButton *rightButton;
/** 录制管理类 */
@property (nonatomic, strong) ERCameraManager *manager;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.manager openVideo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.manager closeVideo];
}


/**
 录制/暂停按钮点击事件
 
 @param btn btn
 */
- (void)inputButtonClick:(UIButton *)btn{
    [self takePicture];
}

/**
 左侧 返回/重拍 按钮点击事件
 
 @param btn btn
 */
- (void)leftButtonClick:(UIButton *)btn{
    if (!btn.selected) {
        //返回方法
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        //移除重拍方法
        [self cannel];
    }
}

/**
 右侧 切换/确认 按钮点击事件
 
 @param btn btn
 */
- (void)rightButtonClick:(UIButton *)btn{
    if (!btn.selected) {
        //切换摄像头
        [self.manager exchangeCamera];
    }else{
        //确定
        if ([self.manager getOriginalImage]) {
            NSLog(@"确定提交");
        }
    }
}


/**
 重拍
 */
- (void)cannel{
    [self.manager cannel];
    self.inputButton.hidden = false;
    self.leftButton.selected = false;
    self.rightButton.selected = false;
}

/**
 拍照
 */
- (void)takePicture{
    self.inputButton.hidden = true;
    [self.manager takePicture];
    self.leftButton.selected = true;
    self.rightButton.selected = true;
}


/**
 初始化界面
 */
- (void)initSubView{
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.backView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backView];
    
    //初始化录制管理类
    self.manager = [[ERCameraManager alloc] initWithSuperView:self.backView];
    [self.manager openVideo];
    
    self.inputButton = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 60)/2, [UIScreen mainScreen].bounds.size.height - 60 - 30, 60, 60)];
    [self.inputButton setBackgroundImage:[UIImage imageNamed:@"release_video_shooting"] forState:UIControlStateNormal];
    [self.inputButton addTarget:self action:@selector(inputButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.inputButton];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.inputButton.frame) - 36 - 44, CGRectGetMinY(self.inputButton.frame) + (CGRectGetHeight(self.inputButton.frame) - 36) / 2 , 36, 36)];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"release_video_down"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"release_video_return"] forState:UIControlStateSelected];
    [self.leftButton setShowsTouchWhenHighlighted:false];
    [self.leftButton setAdjustsImageWhenHighlighted:false];
    [self.leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.leftButton];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.inputButton.frame) + 44, CGRectGetMinY(self.leftButton.frame), 36, 36)];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"release_video_switch"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"release_video_determine"] forState:UIControlStateSelected];
    [self.rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setShowsTouchWhenHighlighted:false];
    [self.rightButton setAdjustsImageWhenHighlighted:false];
    [self.backView addSubview:self.rightButton];
}


@end
