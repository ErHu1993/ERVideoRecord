//
//  ZingCameraViewController.h
//  Zing
//
//  Created by 胡广宇 on 2017/3/30.
//  Copyright © 2017年 Witgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewControllerDelegate;

@interface CameraViewController : UIViewController

@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;

@end

@protocol CameraViewControllerDelegate <NSObject>

@optional
- (void)photoCompleteWithPhoto:(NSString *)photo data:(NSData *)data;

@end
