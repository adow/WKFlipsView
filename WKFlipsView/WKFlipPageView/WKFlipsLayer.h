//
//  WKFlipsLayer.h
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
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
@class WKFlipsLayer;
@class WKFlipsView;
///用来放那些WKFlipsLayer
@interface _WKFlipsLayerView:UIView{
    
}
///使用flipsView
-(id)initWithFlipsView:(WKFlipsView*)flipsView;
///翻页的状态
@property (nonatomic,assign) WKFlipsLayerViewRunState runState;
///引用flipsView
@property (nonatomic,assign) WKFlipsView* flipsView;
///重建所有页面
-(void)buildLayers;
#pragma mark - FlipAnimation
-(void)flipToPageIndex:(int)pageIndex;
-(void)flipToPageIndex:(int)pageIndex completion:(void(^)(BOOL completed))completionBlock;
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
///动画设置翻转角度
-(void)setRotateDegree:(CGFloat)rotateDegree duration:(CGFloat)duration afterDelay:(NSTimeInterval)delay completion:(void(^)())completion;
///画出来测试用的文字
-(void)drawWords:(NSString*)words onPosition:(int)position;
@end
