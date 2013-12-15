//
//  WKFlipsLayer.h
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WK.h"
#pragma makr - WKFlipsLayerView
///翻页的状态
typedef enum WKFlipsLayerViewRunState:NSUInteger{
   ///禁止
    WKFlipsLayerViewRunStateStop=0,
    ///拖动翻页中
    WKFlipsLayerViewRunStateDragging=1,
    ///翻页动画中
    WKFlipsLayerViewRunStateAnimation=2,
}WKFlipsLayerViewRunState;
///用来放那些WKFlipsLayer
@interface _WKFlipsLayerView:UIView{
    
}
///翻页的状态
@property (nonatomic,assign) WKFlipsLayerViewRunState runState;
#pragma mark - Drag
///开始拖动
-(void)dragBegan;
///拖动结束
-(void)dragEnded;
///正在拖动
-(void)draggingWithTranslation:(CGPoint)translation;
@end
#pragma mark - WKFlipsLayer
@interface WKFlipsLayer : CATransformLayer{
    CGFloat _rotateDegree;
}

@property (nonatomic,retain) CALayer* frontLayer;
@property (nonatomic,retain) CALayer* backLayer;
-(id)initWithFrame:(CGRect)frame;
@property (nonatomic,assign) CGFloat rotateDegree;
///动画设置翻转
-(void)setRotateDegree:(CGFloat)rotateDegree completion:(void(^)())completion;
@end
