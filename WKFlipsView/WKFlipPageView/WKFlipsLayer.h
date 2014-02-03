//
//  WKFlipsLayer.h
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#pragma makr - WKFlipsLayerView
///翻页的状态
typedef enum WKFlipsLayerViewRunState:NSUInteger{
   ///停止
    WKFlipsLayerViewRunStateStop=0,
    ///拖动翻页中
    WKFlipsLayerViewRunStateDragging=1,
    ///翻页动画中
    WKFlipsLayerViewRunStateAnimation=2,
}WKFlipsLayerViewRunState;
typedef enum WKFlipsLayerDragAtPosition:NSUInteger{
    ///拖动上面的
    WKFlipsLayerDragAtPositionTop=0,
    ///拖动底部的
    WKFlipsLayerDragAtPositionBottom=1,
}WKFlipsLayerDragAtPosition;
@class WKFlipsLayer;
@class WKFlipsView;
///用来放那些WKFlipsLayer，多个页面的集合，全部用layer
@interface WKFlipsLayerView:UIView{
    WKFlipsLayerViewRunState _runState;
    ///正在被拖动的页面
    WKFlipsLayer* _dragging_layer;
    ///正在被拖动的页面的位置，上面的，还是下面的
    WKFlipsLayerDragAtPosition _dragging_position;
    ///上一次的位置
    CGFloat _dragging_last_translation_y;
    
}
///使用flipsView
-(id)initWithFlipsView:(WKFlipsView*)flipsView;
///翻页的状态
@property (nonatomic,assign) WKFlipsLayerViewRunState runState;
///引用flipsView
@property (nonatomic,assign) WKFlipsView* flipsView;
///页面数
@property (nonatomic,readonly) int numbersOfLayers;
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
///图层阴影样式
typedef enum WKFlipsLayerShadowStyle:NSUInteger{
    WKFlipsLayerShadowStyle1=0,
    WKFlipsLayerShadowStyle2=1,
    WKFlipsLayerShadowStyle3=2,
}WKFlipsLayerShadowStyle;
///单个页面，layer,每个页面有两面，翻页是已经被翻转过的
@interface WKFlipsLayer : CATransformLayer{
    CGFloat _rotateDegree;
    ///图层的阴影
    CALayer* _shadowOnFronLayer;
    ///图层的阴影
    CALayer* _shadowOnBackLayer;
}

@property (nonatomic,retain) CALayer* frontLayer;
@property (nonatomic,retain) CALayer* backLayer;
-(id)initWithFrame:(CGRect)frame;
///设置翻转角度，因为一开始的位置是在底部，所以在底部时0度，翻转到上面时变成180度
@property (nonatomic,assign) CGFloat rotateDegree;
///动画设置翻转角度
-(void)setRotateDegree:(CGFloat)rotateDegree duration:(CGFloat)duration afterDelay:(NSTimeInterval)delay completion:(void(^)())completion;
///取消拖动后的动画
-(void)cancelDragAnimation;
///画出来测试用的文字
-(void)drawWords:(NSString*)words onPosition:(int)position;
#pragma mark shadow
///显示图层阴影
-(void)showShadowStyle:(WKFlipsLayerShadowStyle)style;
///去掉图层阴影
-(void)removeShadow;
///显示阴影的透明度
-(void)showShadowOpacity:(CGFloat)opacity;
@end
