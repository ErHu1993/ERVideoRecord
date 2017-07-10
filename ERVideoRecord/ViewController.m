//
//  ViewController.m
//  ERVideoRecord
//
//  Created by 胡广宇 on 2017/7/10.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import "ViewController.h"
#import "VideoRecordingViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startRecording:(id)sender {
    VideoRecordingViewController *vc = [[VideoRecordingViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)startTakePhoto:(id)sender {
    CameraViewController *vc = [[CameraViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
