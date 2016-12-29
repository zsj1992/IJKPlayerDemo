//
//  ZSPlayerView.m
//  testIJK
//
//  Created by zsj1992 on 16/12/20.
//  Copyright © 2016年 bjhj. All rights reserved.
//

#import "ZSPlayerView.h"
#import "ZSButton.h"
#import "ZSLoading.h"


@interface ZSPlayerView()<UIGestureRecognizerDelegate>{

    UIImageView * _placeHolderImgView;
    UIImageView * _voiceImgView;
    UIImageView * _brightnessImgView;
}
//工具蒙版

@property (nonatomic,strong)ZSButton * btnOperate;
@property (nonatomic,strong)ZSButton * btnLock;
@property (nonatomic,strong)ZSLoading * loading;



//标题栏
@property (nonatomic,strong)ZSButton * btnBack;
@property (nonatomic,strong)UILabel * lblTitle;

//工具蒙版
@property (nonatomic,strong)ZSButton *btnPlay;
@property (nonatomic,strong)ZSButton *btnFullScreen;
@property (nonatomic,strong)UILabel * lblCurrentTime;
@property (nonatomic,strong)UILabel * lblTotalTime;
@property (nonatomic,strong)UISlider * slider;//滑块
@property (nonatomic,strong)UIProgressView * progressView;//进度条


//计时器
@property (nonatomic,strong)NSTimer * timer;

//播放视图
@property (nonatomic,strong)UIView * playerView;


@end

@implementation ZSPlayerView


#pragma mark-初始化方法
-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate url:(NSString *)url{
    if (self = [super initWithFrame:frame]) {
        self.fullScreenDelegate = delegate;
        self.backDelegate = delegate;
        self.url = url;
    }
    return self;
}

#pragma mark-设置url



-(void)setUrl:(NSString *)url{
   
    _url = url;
    [self setupPlayerView];
}


#pragma mark-初始化playerView
-(void)setupPlayerView{
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:256 forKey:@"vol"];

    
    NSURL *url = [NSURL URLWithString:self.url];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    [self.player setScalingMode:IJKMPMovieScalingModeFill];
    [self.player prepareToPlay];
    [self installMovieNotificationObservers];
    
    //获取播放视图
    self.playerView = [self.player view];
    self.playerView.frame = self.bounds;
    //把播放视图插到最上面去
    [self insertSubview:self.playerView atIndex:0];

    
    _placeHolderImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBG"]];
    [self.playerView addSubview:_placeHolderImgView];
    [_placeHolderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.playerView);

        
    }];
    

    UITapGestureRecognizer * tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerViewTap:)];
    tap.delegate = self;
    [self.playerView addGestureRecognizer:tap];
    self.cover = [[UIView alloc]init];
    self.cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self.playerView addSubview:self.cover];
    [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.playerView);
    }];
    

    
    /***********************************************************/

    
    //返回按钮
    _btnBack = [[ZSButton alloc]init];
    [_btnBack setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [_cover addSubview:_btnBack];
    [_btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cover);
        make.top.equalTo(_cover).offset(10);
        make.width.height.mas_equalTo(40);
    }];
    [_btnBack addTarget:self action:@selector(back:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //视频信息
    _lblTitle = [[UILabel alloc]init];
    _lblTitle.font = [UIFont systemFontOfSize:14];
    _lblTitle.textColor = [UIColor whiteColor];
    _lblTitle.text =@"一个视频";
    [_cover addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnBack.mas_right);
        make.centerY.equalTo(_btnBack);
    }];
    


    /***********************************************************/

    
    //音量控件--屏蔽系统音量改变提醒
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    
    volumeView.frame = CGRectMake(1000, 300, 100, 20);
    
    [self addSubview:volumeView];
    

    
    
    //全屏按钮
    _btnFullScreen = [[ZSButton alloc]init];
    [_btnFullScreen setImage:[UIImage imageNamed:@"fullScreen"] forState:(UIControlStateNormal)];
    [_btnFullScreen setImage:[UIImage imageNamed:@"quiteScreen"] forState:(UIControlStateSelected)];
    [_cover addSubview:_btnFullScreen];
    [_btnFullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_cover);
        make.bottom.equalTo(_cover);
        make.width.height.mas_equalTo(50);
    }];
    [_btnFullScreen addTarget:self action:@selector(fullScreen:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    //视频当前时间
    _lblCurrentTime = [[UILabel alloc]init];
    _lblCurrentTime.font = [UIFont systemFontOfSize:15];
    _lblCurrentTime.text = @"00:00:00";
    _lblCurrentTime.textAlignment = NSTextAlignmentLeft;
    _lblCurrentTime.textColor = [UIColor whiteColor];
    [_cover addSubview:_lblCurrentTime];
    [_lblCurrentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cover).offset(10);
        make.centerY.equalTo(_btnFullScreen);
        make.width.mas_equalTo(65);
    }];
    
    //视频总时长
    _lblTotalTime = [[UILabel alloc]init];
    _lblTotalTime.font = [UIFont systemFontOfSize:15];
    _lblTotalTime.text = @"00:00:00";
    _lblTotalTime.textAlignment = NSTextAlignmentRight;
    _lblTotalTime.textColor = [UIColor whiteColor];
    [_cover addSubview:_lblTotalTime];
    [_lblTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_btnFullScreen.mas_left);
        make.centerY.equalTo(_btnFullScreen);
        make.width.mas_equalTo(65);
        
    }];
    
    
    //缓冲进度条
    _progressView = [[UIProgressView alloc]init];
    [_cover addSubview:_progressView];
    _progressView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lblCurrentTime.mas_right).offset(5);
        make.right.equalTo(_lblTotalTime.mas_left).offset(-5);
        make.centerY.equalTo(_btnFullScreen);//progressView向下一个像素
    }];
    _progressView.tintColor = [UIColor whiteColor];
    [_progressView setProgress:0];
    
    
    
    //滑块
    _slider = [[UISlider alloc]init];
    _slider.userInteractionEnabled = YES;
    _slider.continuous = YES;//设置为NO,只有在手指离开的时候调用valueChange
    [_slider addTarget:self action:@selector(sliderValuechange:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer * sliderTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTap:)];
    [_slider addGestureRecognizer:sliderTap];
    [_cover addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_progressView);
        make.centerY.equalTo(_progressView).offset(-1);
    }];
    _slider.minimumTrackTintColor = [UIColor whiteColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];
    UIImage * image = [self createImageWithColor:[UIColor whiteColor]];
    UIImage * circleImage = [self circleImageWithImage:image borderWidth:0 borderColor:[UIColor clearColor]];
    [_slider setThumbImage:circleImage forState:(UIControlStateNormal)];
    [self layoutIfNeeded];
    
    //播放按钮
    _btnPlay = [[ZSButton alloc]init];
    [_cover addSubview:_btnPlay];
    [_btnPlay setImage:[UIImage imageNamed:@"pause"] forState:(UIControlStateNormal)];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:(UIControlStateSelected)];
    [_btnPlay addTarget:self action:@selector(play:) forControlEvents:(UIControlEventTouchUpInside)];
    [_btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(_cover);
        make.width.height.mas_equalTo(100);
    }];
    
    _btnLock = [[ZSButton alloc]init];
    [_btnLock setImage:[UIImage imageNamed:@"lock1"] forState:(UIControlStateNormal)];
    [_btnLock setImage:[UIImage imageNamed:@"lockSel1"] forState:(UIControlStateSelected)];
    //[_btnLock addTarget:self action:@selector(lock:) forControlEvents:(UIControlEventTouchUpInside)];
    [_cover addSubview:_btnLock];
    [_btnLock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnPlay);
        make.left.equalTo(_btnBack);
        make.width.height.mas_equalTo(40);
    }];
    
    //loading的位置用计算的...
    _loading = [[ZSLoading alloc]init];
    [_cover addSubview:_loading];
    [_loading mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(_cover);
        make.width.height.mas_equalTo(100);

    }];
    [_cover layoutIfNeeded];
    _loading.frame = _loading.frame;
    //////////////////////随加载状态的改变而改变
    
    _btnPlay.hidden = YES;
    _lblTotalTime.hidden = YES;
    _lblCurrentTime.hidden = YES;
    _slider.hidden = YES;
    _progressView.hidden = YES;
    
    
    
    
    
}



//加载状态发生改变的时候切换
-(void)changeState{
    //移除加载条
    [_loading removeFromSuperview];
    _loading = nil;
    
    //改变隐藏的状态
    _lblCurrentTime.hidden = !_lblCurrentTime.hidden;
    _lblTotalTime.hidden = !_lblTotalTime.hidden;
    _slider.hidden = !_slider.hidden;
    _progressView.hidden = !_progressView.hidden;
    _btnPlay.hidden = !_progressView;
    
}

//点击了返回按钮
-(void)back:(UIButton *)sender{
    
    NSLog(@"点击了返回按钮");

    if (self.backDelegate&&[self.backDelegate respondsToSelector:@selector(btnFullScreenDidClick:)]) {
        [self.backDelegate btnBackClick:sender];
    }

    
}





BOOL _hideTool;

#pragma mark-点击了playerView
-(void)playerViewTap:(UITapGestureRecognizer *)recognizer{
    
    //每次点击取消还在进程中的隐藏方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    _hideTool = !_hideTool;

    [UIView animateWithDuration:0.25 animations:^{
        if (_hideTool) {
            self.cover.alpha = 0;
        }else{
            self.cover.alpha = 1;
        }
    } completion:^(BOOL finished) {
        if (_hideTool) {
            self.cover.hidden = YES;
        }else{
            self.cover.hidden = NO;
            //如果最后没隐藏,在调用隐藏的代码
            [self performSelector:@selector(hide) withObject:nil afterDelay:4];
        }
    }];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[ZSButton class]]){
        return NO;
    }
    return YES;
}


#pragma mark-隐藏cover

-(void)hide{
    [UIView animateWithDuration:0.25 animations:^{
        self.cover.alpha =0 ;
    }completion:^(BOOL finished) {
        self.cover.hidden = YES;
        _hideTool = YES;
    }];
}


#pragma mark-touchBengan

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touchbegan=======%d",_hideTool);

    startP = [[touches anyObject] locationInView:self.playerView];
    
    if (!_hideTool) {
        [self hide];
    }
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesMoved __  PLAY");

    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.playerView];
//    CGFloat deltaX = point.x-startP.x;//这个可以用来进行拖动播放进度
    CGFloat deltaY = point.y-startP.y;
    CGFloat volume = [MPMusicPlayerController applicationMusicPlayer].volume;
   
    if (startP.x>[UIScreen mainScreen].bounds.size.width/2) {//调节音量
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume-deltaY/500];
        [self setupLayerLeft:NO];
    }else{
        CGFloat brightness = [UIScreen mainScreen].brightness;
        [[UIScreen mainScreen] setBrightness:brightness-deltaY/5000];
        [self setupLayerLeft:YES];
    }
}



//点击结束
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [layerContainer removeFromSuperlayer];
}

//点击取消
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [layerContainer removeFromSuperlayer];
}



CGPoint startP;
CAShapeLayer *layer;
CAShapeLayer * layerContainer;

#pragma mark-设置音量条,亮度条
-(void)setupLayerLeft:(BOOL)left{
    
    [layerContainer removeFromSuperlayer];
    [layer removeFromSuperlayer];
    layerContainer = nil;
    layer = nil;
    
    CGFloat volume = [MPMusicPlayerController applicationMusicPlayer].volume;
    CGFloat brightness = [UIScreen mainScreen].brightness;
    
    
    // 创建layer并设置属性
    layerContainer = [CAShapeLayer layer];
    layerContainer.lineWidth =  3;
    layerContainer.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor;
    [self.playerView.layer addSublayer:layerContainer];
    layerContainer.strokeEnd = 1;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointMake(left?29:SCREEN_W-29, self.playerView.center.y+20);
    [path moveToPoint:point];
    [path addLineToPoint:CGPointMake(point.x, point.y-100)];
    layerContainer.path = path.CGPath;
    
    
    // 创建layer并设置属性
    layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.lineWidth =  3;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    [layerContainer addSublayer:layer];
    layer.strokeEnd = left?brightness:volume;
    layer.path = path.CGPath;
}


#pragma mark-锁定
-(void)lock:(ZSButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        for (UIView * subView in _cover.subviews) {
            subView.alpha = 0;
        }
        sender.alpha = 1;
    }else{
    }
}


#pragma mark-暂停/播放

-(void)play:(ZSButton *)sender{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.player pause];

    }else{
    
        [self.player play];
    }
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:4];

}


#pragma mark-点击滑块

-(void)sliderTap:(UITapGestureRecognizer *)tap{
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    UISlider * slider = (UISlider *)tap.view;
    
    CGPoint point = [tap locationInView:_slider];

    [_slider setValue:point.x/_slider.bounds.size.width*1 animated:YES];
    
    _player.currentPlaybackTime = slider.value*_player.duration;

    [self performSelector:@selector(hide) withObject:nil afterDelay:4];

}


#pragma mark-滑块值发生改变
-(void)sliderValuechange:(UISlider *)sender{
    
    NSLog(@"sliderValuechange");
    
    //取消收回工具栏的动作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    _player.currentPlaybackTime = sender.value*_player.duration;

    [self performSelector:@selector(hide) withObject:nil afterDelay:4];

}


BOOL _hideToolbar;

#pragma mark-点击了全屏按钮

- (void)fullScreen:(ZSButton *)sender {
    
    NSLog(@"点击全屏");
    
    sender.selected = !sender.selected;
    
    if (self.fullScreenDelegate&&[self.fullScreenDelegate respondsToSelector:@selector(btnFullScreenDidClick:)]) {
        [self.fullScreenDelegate btnFullScreenDidClick:sender];
    }
}


#pragma mark-更新方法

-(void)update{

    _lblCurrentTime.text =[self TimeformatFromSeconds:self.player.currentPlaybackTime];
    
    CGFloat current = self.player.currentPlaybackTime;
    CGFloat total = self.player.duration;
    CGFloat able = self.player.playableDuration;
    [_slider setValue:current/total animated:YES];
    [_progressView setProgress:able/total animated:YES];
}


NSTimer * timer;

#pragma mark-加载状态改变

- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
        _lblTotalTime.text =[NSString stringWithFormat:@"%@",[self TimeformatFromSeconds:self.player.duration]];
        
        
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

#pragma mark-播放状态改变
- (void)moviePlayBackFinish:(NSNotification*)notification {
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: 播放完毕: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: 用户退出播放: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: 播放出现错误: %d\n", reason);
            
            
#pragma mark-播放出现错误,需要添重新加载播放视频的按钮

            
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
    
    [_placeHolderImgView removeFromSuperview];
    
    [self changeState];

    
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    
    if (self.player.playbackState==IJKMPMoviePlaybackStatePlaying) {
        //视频开始播放的时候开启计时器
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];

        [self performSelector:@selector(hide) withObject:nil afterDelay:4];

    }

    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);

            [self.player shutdown];
            self.player = nil;
            
            self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.url] withOptions:nil];
            [self.player prepareToPlay];
            [self.player play];
            
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}


#pragma mark-观察视频播放状态

- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}


#pragma mark-公共方法

- (NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

//从图片
- (UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0,0,15,15);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



- (UIImage *)circleImageWithImage:(UIImage *)oldImage borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 22 * borderWidth;
    CGFloat imageH = oldImage.size.height + 22 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文,这里得到的就是上面刚创建的那个图片上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆。As a side effect when you call this function, Quartz clears the current path.
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
