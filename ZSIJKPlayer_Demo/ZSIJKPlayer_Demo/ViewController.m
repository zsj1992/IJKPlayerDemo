//
//  ViewController.m
//  ZSIJKPlayer_Demo
//
//  Created by zsj1992 on 16/12/28.
//  Copyright © 2016年 ichange. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnVideoPlay;

@property (weak, nonatomic) IBOutlet UIButton *btnLivePlay;

@end

@implementation ViewController


- (IBAction)playVideo:(id)sender {
    
    NSLog(@"播放点播视频");
   
    NSString * url = @"http://baobab.wdjcdn.com/1456231710844S(24).mp4";

    PlayViewController * playVc = [[PlayViewController alloc]init];
    
    playVc.url = url;
    
    [self.navigationController pushViewController:playVc animated:YES];
    
    
}
- (IBAction)playLive:(id)sender {
    NSLog(@"播放直播视频");
    
    NSString * url = @"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8";
//    NSString * url1 = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";

    PlayViewController * playVc = [[PlayViewController alloc]init];
    
    playVc.url = url;
    
    [self.navigationController pushViewController:playVc animated:YES];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.btnLivePlay.layer.borderColor=[UIColor orangeColor].CGColor;
//    self.btnLivePlay.layer.borderWidth=1;
    self.btnLivePlay.backgroundColor = [UIColor orangeColor];
    self.btnLivePlay.layer.cornerRadius = 3;
    self.btnLivePlay.layer.masksToBounds = YES;
    
//    self.btnVideoPlay.layer.borderWidth=1;
//    self.btnVideoPlay.layer.borderColor=[UIColor cyanColor].CGColor;
    self.btnVideoPlay.backgroundColor = [UIColor cyanColor];
    self.btnVideoPlay.layer.cornerRadius = 3;
    self.btnVideoPlay.layer.masksToBounds = YES;


}


@end
