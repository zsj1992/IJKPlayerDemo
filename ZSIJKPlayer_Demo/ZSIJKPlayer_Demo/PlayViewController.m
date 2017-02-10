//
//  PlayViewController.m
//  ZSIJKPlayer_Demo
//
//  Created by zsj1992 on 16/12/28.
//  Copyright © 2016年 ichange. All rights reserved.
//

#import "PlayViewController.h"

#import "ZSPlayerView.h"
#import "AppDelegate.h"

@interface PlayViewController ()<backDelegate,fullScreenDelegate>
@property (nonatomic,strong)ZSPlayerView * playerView;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    
    self.playerView = [[ZSPlayerView alloc]initWithFrame: CGRectMake(0, 0, SCREEN_W, SCREEN_W*(SCREEN_W/SCREEN_H)*1.3) delegate:self url:self.url];
    
    [self.view addSubview:self.playerView];
    
    
    
}

#pragma mark -与全屏相关的代理方法等

BOOL fullScreen;

static UIButton * btnFullScreen;

//点击了全屏按钮
-(void)btnFullScreenDidClick:(UIButton *)sender{
    
    fullScreen = !fullScreen;
    
    btnFullScreen = sender;
    
    if (fullScreen) {//小屏->全屏
        [UIView animateWithDuration:0.25 animations:^{
            NSNumber * value  = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        }];
        
    }else{//全屏->小屏
        [UIView animateWithDuration:0.25 animations:^{
            NSNumber * value  = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        }];
    }
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        fullScreen = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.playerView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
            self.playerView.player.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        }];
    }
    
    if (orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        fullScreen = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.playerView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
            self.playerView.player.view.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        }];
    }
    if (orientation == UIInterfaceOrientationPortrait)
    {
        fullScreen = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.playerView.transform= CGAffineTransformMakeRotation(0);
            self.playerView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W*(SCREEN_W/SCREEN_H)*1.3);
            self.playerView.player.view.frame = self.playerView.frame;
        }];
    }
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"其他");
    }
}

//点击了返回按钮
-(void)btnBackClick:(UIButton *)sender{

    [self.playerView.player shutdown];
    self.playerView = nil;
    
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)dealloc{

    NSLog(@"+++++++++++++delloc+++++++++++");
    [self.playerView.player shutdown];
    self.playerView = nil;
    
}

@end
