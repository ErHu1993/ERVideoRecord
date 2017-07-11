# ERVideoRecord

## 自己封装了一个视频录制和拍照的功能,可以方便集成使用

![Gif浏览](http://upload-images.jianshu.io/upload_images/2773241-d3fa41b6ee844291.gif?imageMogr2/auto-orient/strip)

### 视频录制功能: 

#### 1.视频录制的过程我使用的定时器来监听进度,最长时间和最短时间可在```VideoRecordManager.m 文件顶部修改```
#### 2.通过```VideoFileManager```类管理存储路径,默认存储路径为Temp文件夹,视频为.mp4格式,缩略图为.jpg格式,文件名为当前时间格式化生成的.视频录制的文件和缩略图(我获取的是视频中间那一帧)会打印出来.
#### 3.在视频录制开始前我通过```CMMotionManager```监听设备方向,竖拍时视频画布大小为宽720*高1280 ,横拍时画布大小为高720宽1280(9:16),所以横拍完成后会旋转过来.
#### 4.关于UI可自行参考Demo

##### ```#import "VideoRecordManager.h"``` 中提供了以下方法

```
/**
 初始化
 
 @param superView 父视图
 @return self
 */
- (instancetype)initWithSuperView:(UIView *)superView;

/**
 开启摄像头
 */
- (void)openVideo;

/**
 关闭摄像头
 */
- (void)closeVideo;

/**
 切换摄像头
 */
- (void)exchangeCamera;

/**
 开始录像
 */
- (void)startVideoRecord;

/**
 停止录像
 */
- (void)stopVideoRecord;

/**
 删除录像
 */
- (void)deleteVideoRecord;

/**
 获取视频数据路径
 
 @param callback 回调
 */
- (void)getVideoAndThumbnailPathWithBlock:(void (^)(NSString *videoPath , NSString *thumbnailPath))callback;

/**
 获取视频时长
 
 @return 时长
 */
- (CGFloat)getRecordTime;
```
##### Deleagate 可以获取进度回调

```
@protocol VideoRecordManagerDelegate <NSObject>

@optional;

/**
 视频录制过短代理
 
 @param manager self
 */
- (void)recordTimerTooShort:(VideoRecordManager *)manager;

/**
 录制视频时间结束
 
 @param manager self
 */
- (void)recordTimerEnd:(VideoRecordManager *)manager;


/**
 录制进度改变
 
 @param progress progress(0 ~ 1)
 */
- (void)recordProgressChange:(CGFloat)progress;

@end
```

<br />

### 拍照功能:
#### 拍照的```AVCaptureVideoPreviewLayer```大小为 4 : 3,根据需求自行修改~
#### 在拍照前我依然通过```CMMotionManager```监听设备方向,横拍完成后会旋转过来.
##### ```#import "ERCameraManager.h"``` 中提供了以下方法

```

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
```
<br />

### 参考类库 (已表感谢 ! 学习并膜拜大神们 ~)

[PKShortVideo](https://github.com/pepsikirk/PKShortVideo)
