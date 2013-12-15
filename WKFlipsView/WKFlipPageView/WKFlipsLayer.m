//
//  WKFlipsLayer.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsLayer.h"
#pragma makr - _WKFlipsLayerView
@interface _WKFlipsLayerView(){
    
}

@end
@implementation _WKFlipsLayerView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self){
        self.userInteractionEnabled=NO;
    }
    return self;
}
-(void)dealloc{
    [super dealloc];
}
#pragma mark - Drag
-(void)dragBegan{
    NSLog(@"dragBegan");
}
-(void)dragEnded{
    NSLog(@"dragEnded");
}
-(void)draggingWithTranslation:(CGPoint)translation{
    NSLog(@"dragging");
}
@end

#pragma mark - WKFlipsLayer
@interface WKFlipsLayer(){
    
}
@end
@implementation WKFlipsLayer
-(id)initWithFrame:(CGRect)frame{
    self=[super init];
    if (self){
        self.frame=frame;
        self.doubleSided=YES;
        self.anchorPoint=CGPointMake(0.5, 0);
        self.position=CGPointMake(self.position.x,
                                  self.position.y-self.frame.size.height/2);
        _frontLayer=[[CALayer alloc]init];
        _frontLayer.frame=self.bounds;
        _frontLayer.backgroundColor=[UIColor blueColor].CGColor;
        _frontLayer.doubleSided=NO;
        _frontLayer.name=@"frontLayer";
        
        _backLayer=[[CALayer alloc]init];
        _backLayer.frame=self.bounds;
        _backLayer.backgroundColor=[UIColor blueColor].CGColor;
        _backLayer.doubleSided=YES;
        _backLayer.name=@"backLayer";
        _backLayer.transform=WKFlipCATransform3DPerspectSimpleWithRotate(180.0f);
        
        [self insertSublayer:_frontLayer atIndex:0];
        [self insertSublayer:_backLayer atIndex:0];
    }
    return self;
}
-(void)dealloc{
    [_frontLayer release];
    [_backLayer release];
    [super dealloc];
}
#pragma mark - rotateDegree
-(void)setRotateDegree:(CGFloat)rotateDegree{
    _rotateDegree=rotateDegree;
    self.transform=WKFlipCATransform3DPerspectSimpleWithRotate(rotateDegree);
}
-(CGFloat)rotateDegree{
    return _rotateDegree;
}
///TODO: 动画设置翻转角度
-(void)setRotateDegree:(CGFloat)rotateDegree completion:(void (^)())completion{
    
}
@end
