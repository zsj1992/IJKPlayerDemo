//
//  ZSPlayerView.h
//  testIJK
//
//  Created by zsj1992 on 16/12/20.
//  Copyright © 2016年 zsj1992 All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "Masonry.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@protocol fullScreenDelegate <NSObject>

-(void)btnFullScreenDidClick:(UIButton *)sender;

@end

@protocol backDelegate <NSObject>

-(void)btnBackClick:(UIButton *)sender;

@end

@interface ZSPlayerView : UIView
@property (nonatomic,copy)NSString * url;
@property (nonatomic,strong)IJKFFMoviePlayerController * player;
@property (nonatomic,strong)id<fullScreenDelegate> fullScreenDelegate;
@property (nonatomic,strong)id<backDelegate> backDelegate;

@property (nonatomic,strong)UIView * cover;


-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate url:(NSString *)url;

@end
