//
//  ZingCameraManager.h
//  Zing
//
//  Created by 胡广宇 on 2017/3/30.
//  Copyright © 2017年 Witgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ERCameraManager : NSObject

/**
 初始化
 
 @param superView 父视图
 @return self
 */
- (instancetype)initWithSuperView:(UIView *)superView;

/**
 开启摄像
 */
- (void)openVideo;

/**
 关闭摄像
 */
- (void)closeVideo;

/**
 拍照
 */
- (void)takePicture;

/**
 取消
 */
- (void)cannel;

/**
 切换摄像头
 */
- (void)exchangeCamera;

/**
 获取原图

 @return image
 */
- (UIImage *)getOriginalImage;
@end
