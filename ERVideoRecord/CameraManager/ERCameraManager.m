//
//  ZingCameraManager.m
//  Zing
//
//  Created by 胡广宇 on 2017/3/30.
//  Copyright © 2017年 Witgo. All rights reserved.
//

#import "ERCameraManager.h"
#import <CoreMotion/CoreMotion.h> 
#import <AVFoundation/AVFoundation.h>

@interface ERCameraManager ()
/** AVCaptureSession对象来执行输入设备和输出设备之间的数据传递 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）*/
@property (nonatomic, strong) AVCaptureDevice *device;
/** 照片输入 */
@property (nonatomic, strong) AVCaptureDeviceInput *pictureInput;
/** 照片输出 */
@property (nonatomic ,strong) AVCaptureStillImageOutput *pictureOutput;
/** 照片控制 */
@property (nonatomic, strong) AVCaptureConnection *connection;
/** 预览图层 */
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;
/** 展示的父视图 */
@property (nonatomic, strong) UIView *superView;
/** 展示ImageView */
@property (nonatomic, strong) UIImageView *pictureImageView;
/** 拍摄图片 */
@property (nonatomic, strong) UIImage *resultImage;
/** 监听拍摄方向 */
@property (nonatomic, strong) CMMotionManager* montionManager;
/** 记录拍摄的方向 */
@property (nonatomic, assign) AVCaptureVideoOrientation currentOrientation;
/** 是否需要更新当前拍摄方向 */
@property (nonatomic, assign) BOOL shouldUpdateOrientation;
@end

@implementation ERCameraManager

- (void)dealloc{
    [self endUpdateCurrentOrientation];
}

/**
 初始化
 
 @param superView 父视图
 @return self
 */
- (instancetype)initWithSuperView:(UIView *)superView{
    if (self = [super init]) {
        self.superView = superView;
        //初始化输入设备
        [self createAVCaptureSession];
    }
    return self;
}

- (void)startUpdateCurrentOrientation{
    self.shouldUpdateOrientation = YES;
    if([self.montionManager isDeviceMotionAvailable]) {
        [self.montionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            NSLog(@"x : %f  y : %f  z: %f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z);
            if (self.shouldUpdateOrientation) {
                if (accelerometerData.acceleration.x < 0.75 && accelerometerData.acceleration.x > -0.75) {
                    if (accelerometerData.acceleration.y < 0) {
                        if (self.currentOrientation != AVCaptureVideoOrientationPortrait) {
                            self.currentOrientation = AVCaptureVideoOrientationPortrait;
                        }
                    }else if (accelerometerData.acceleration.y >= 0.75){
                        if (self.currentOrientation != AVCaptureVideoOrientationPortraitUpsideDown) {
                            self.currentOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        }
                    }
                }else if (accelerometerData.acceleration.y < 0.75 && accelerometerData.acceleration.y > -0.75) {
                    if (accelerometerData.acceleration.x > 0.75) {
                        if (self.currentOrientation != AVCaptureVideoOrientationLandscapeLeft) {
                            self.currentOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        }
                    }else if(accelerometerData.acceleration.x < -0.75){
                        if (self.currentOrientation != AVCaptureVideoOrientationLandscapeRight) {
                            self.currentOrientation = AVCaptureVideoOrientationLandscapeRight;
                        }
                    }
                }else {
                    return;
                }
            }
        }];
    }
}

- (void)endUpdateCurrentOrientation{
    NSLog(@"结束监听设备方向");
    [self.montionManager stopAccelerometerUpdates];
}


/**
 拍照 (调整照片方向)
 */
- (void)takePicture{
    self.shouldUpdateOrientation = false;
    if (self.connection) {
        [self.pictureOutput captureStillImageAsynchronouslyFromConnection:self.connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            [self closeVideo];
            if (imageDataSampleBuffer) {
                
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                self.resultImage = [UIImage imageWithData:imageData];
                
                UIImageOrientation imageOrientation = UIImageOrientationUp;
                switch (self.currentOrientation) {
                    case AVCaptureVideoOrientationLandscapeLeft:
                    {
                        self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageOrientation = UIImageOrientationDown;
                    }
                        break;
                    case AVCaptureVideoOrientationLandscapeRight:
                    {
                        self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageOrientation = UIImageOrientationUp;
                    }
                        break;
                    case AVCaptureVideoOrientationPortraitUpsideDown:
                    {
                        self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageOrientation  = UIImageOrientationLeft;
                    }
                        break;
                    case AVCaptureVideoOrientationPortrait:
                    {
                        self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageOrientation = UIImageOrientationRight;
                    }
                        break;
                }
                self.pictureImageView.image = [UIImage imageWithCGImage:self.resultImage.CGImage scale:1 orientation:imageOrientation];
                
                if (!self.pictureImageView.layer.superlayer) {
                    [self.superView.layer insertSublayer:self.pictureImageView.layer atIndex:0];
                    [self closeVideo];
                }
            }
        }];
    }
}

/**
 获取原图
 
 @return image
 */
- (UIImage *)getOriginalImage{
    return self.pictureImageView.image;
}

/**
 取消
 */
- (void)cannel{
    if (self.pictureImageView.layer.superlayer) {
        [self.pictureImageView.layer removeFromSuperlayer];
    }
    [self openVideo];
}

/**
 开启摄像
 */
- (void)openVideo{
    if (![self.session isRunning]) {
        [self.session startRunning];
        if (!self.previewLayer.superlayer) {
            [self.superView.layer insertSublayer:self.previewLayer atIndex:0];
        }
        [self startUpdateCurrentOrientation];
    }
}

/**
 关闭摄像
 */
- (void)closeVideo{
    if ([self.session isRunning]) {
        [self.session stopRunning];
        if (self.previewLayer.superlayer) {
            [self.previewLayer removeFromSuperlayer];
        }
        [self endUpdateCurrentOrientation];
    }
}

/**
 切换摄像头
 */
- (void)exchangeCamera{
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration];
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            self.connection = [self.pictureOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([self.connection isVideoStabilizationSupported]) {
                self.connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            [self.session commitConfiguration];
            break;
        }
    }
}

/**
 获取摄像头状态
 
 @param position 类型
 @return AVCaptureDevice
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

#pragma mark - 相关初始化

/**
 初始化输入设备
 */
- (void)createAVCaptureSession{
    
    //监听当前屏幕方向
    self.montionManager = [[CMMotionManager alloc] init];
    
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    self.pictureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    self.pictureOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //输入输出设备结合
    if ([self.session canAddInput:self.pictureInput]) {
        [self.session addInput:self.pictureInput];
    }
    if ([self.session canAddOutput:self.pictureOutput]) {
        [self.session addOutput:self.pictureOutput];
    }
    
    if ([self.device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [self.device unlockForConfiguration];
    }
    
    self.connection = [self.pictureOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([self.connection isVideoStabilizationSupported]) {
        self.connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 45, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 4 / 3);
    self.pictureImageView = [[UIImageView alloc] initWithFrame:self.previewLayer.frame];
    self.pictureImageView.clipsToBounds = YES;
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

@end
