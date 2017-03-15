//
//  ZSLoading.m
//  testLoading
//
//  Created by zsj1992 on 16/12/28.
//  Copyright © 2016年 zsj1992 All rights reserved.
//

#import "ZSLoading.h"

@interface ZSLoading()

@end

@implementation ZSLoading

static CAShapeLayer * layer;

static CGFloat angle = 0;

static UIBezierPath * path;

-(void)setFrame:(CGRect)frame{
    
    if (!_firstSetFrame) {
        _firstSetFrame = !_firstSetFrame;
        return;
    }
    layer = [[CAShapeLayer alloc]init];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = self.bounds;
    [self.layer addSublayer:layer];
    
    layer.strokeColor =[[UIColor colorWithRed:0/255.0 green:255.0/255.0 blue:255.0/255.0  alpha:1] colorWithAlphaComponent:1].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeEnd = 0;
    layer.lineWidth = 2;
    layer.lineCap = @"round";
    
    path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(layer.frame.size.width/2, layer.frame.size.height/2) radius:14 startAngle:angle endAngle:
     angle+M_PI*2 clockwise:YES];
    layer.path = path.CGPath;
    
    [self setupAniamtion];

}


-(void)setupAniamtion{
    
    //动画的对象---想哪个值动画改变
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0);
    animation.toValue = @(0.95);
    animation.duration = 0.7;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    
    CABasicAnimation * rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = 0;
    rotateAnimation.toValue = @(M_PI_2);
    rotateAnimation.duration=1.4;
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    [layer addAnimation:rotateAnimation forKey:@"rotation"];
    

    CABasicAnimation * animation1 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation1.fromValue = @(0);
    animation1.toValue = @(1);
    animation1.duration = 0.7;
    animation1.beginTime = 0.7;
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    

    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[animation,animation1];
    group.duration = 1.4;
    group.delegate = self;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [layer addAnimation:group forKey:@"group"];
}



-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    //每次停止重新初始化动画
    
    angle+=M_PI_2;

    if (angle<M_PI*2) {
        
    }else{
        
        angle = angle-M_PI*2;
    }
    
    path = [UIBezierPath bezierPath];
    
    [path addArcWithCenter:CGPointMake(layer.frame.size.width/2, layer.frame.size.height/2) radius:14 startAngle:angle endAngle:
     angle+M_PI*2 clockwise:YES];
    
    layer.path = path.CGPath;

    if (!self.animationStop) {
        [self setupAniamtion];
    }
    
}


-(void)setAnimationStop:(BOOL)animationStop{
    _animationStop = animationStop;
}


@end





























