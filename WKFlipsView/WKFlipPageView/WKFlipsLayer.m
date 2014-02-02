//
//  WKFlipsLayer.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-13.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsLayer.h"
#import "WKFlipsView.h"
#import "WKFlip.h"
#pragma makr - WKFlipsLayerView
///重建页面时的贴图时间
#define WKFlipsLayerView_PasteImageDuration_When_Rebuild 1.0f
///翻页结束时的贴图时间
#define WKFlipsLayerView_PasteImageDuration_After_Flipped 0.5f
///在主线程中延时贴图的时间
#define WKFlipsLayerView_PasteImage_Delay 0.01f
@interface WKFlipsLayerView(){
    
}

@end
@implementation WKFlipsLayerView
@dynamic runState;
@dynamic numbersOfLayers;
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self){
        self.userInteractionEnabled=NO;
    }
    return self;
}
-(id)initWithFlipsView:(WKFlipsView *)flipsView{
    self=[super initWithFrame:flipsView.bounds];
    if (self){
        self.userInteractionEnabled=NO;
        self.flipsView=flipsView;
        //[self buildLayers];
    }
    return self;
}
-(void)dealloc{
    [super dealloc];
}
-(void)setRunState:(WKFlipsLayerViewRunState)runState{
    _runState=runState;
    switch (runState) {
        case WKFlipsLayerViewRunStateAnimation:
            self.hidden=NO;
            self.flipsView.currentPageView.hidden=YES;
            break;
        case WKFlipsLayerViewRunStateDragging:
            //[self _showShadowOnDraggingLayer];
            self.hidden=NO;
            self.flipsView.currentPageView.hidden=YES;
            break;
        case WKFlipsLayerViewRunStateStop:
            //[self _removeShadowOnDraggngLayer];
            self.hidden=YES;
            self.flipsView.currentPageView.hidden=NO;
            
            break;
        default:
            break;
    }
}
-(WKFlipsLayerViewRunState)runState{
    return _runState;
}
#pragma mark - build
-(int)numbersOfLayers{
    //return [self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]*2;
    return (int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]+1;
}
-(void)buildLayers{
//    double startTime=CFAbsoluteTimeGetCurrent();
    ///先删除现有的layer
    NSMutableArray* layerArray=[[self.layer.sublayers mutableCopy] autorelease];
    for (CALayer *layer in layerArray) {
        [layer removeFromSuperlayer];
    }
    
    ///layer的总数
    int layersNumber=[self numbersOfLayers];
//    int layersNumber=1;
    ///在重新创建新的layer,一开始的位置都在屏幕下半部分
    CGRect layerFrame=CGRectMake(0.0f, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2);
    for (int a=0; a<layersNumber; a++) {
        WKFlipsLayer* layer=[[[WKFlipsLayer alloc]initWithFrame:layerFrame] autorelease];
        [self.layer insertSublayer:layer atIndex:0];
//        [self.layer addSublayer:layer];
//        layer.frontLayer.contents=(id)[UIImage imageNamed:@"weather-default-bg"].CGImage;
//        layer.backLayer.contents=(id)[UIImage imageNamed:@"weather-default-bg"].CGImage;
        #ifdef DEBUG
        ///在页面上输出图层编号和页面编号,绘制文字会消耗不少时间
        [layer drawWords:[NSString stringWithFormat:@"layer:%d-front,page:%d",(layersNumber-a-1),a-1] onPosition:0];
        [layer drawWords:[NSString stringWithFormat:@"layer:%d-back,page:%d",(layersNumber-a-1),a] onPosition:1];
        #endif
        layer.rotateDegree=0.0f;
    }
//    NSLog(@"buildLayers duration:%f",CFAbsoluteTimeGetCurrent()-startTime);
    [self _pasteImagesToLayersForTargetPageIndex:self.flipsView.pageIndex inSeconds:WKFlipsLayerView_PasteImageDuration_When_Rebuild];///重建时可以使用更多的时间来贴图
    ///TEST
//    [self flipToPageIndex:1 completion:^(BOOL completed) {
//    }];
    ///直接已经翻页到现在的页面
    [self flipToPageIndex:self.flipsView.pageIndex];
}
///在允许的时间范围内为尽可能多的layer贴图,如果maxSeconds是0那就忽略时间
///应该从当前页面两边优先贴图
-(void)_pasteImagesToLayersForTargetPageIndex:(int)targetPageIndex inSeconds:(double)maxSeconds{
    double startTime=CFAbsoluteTimeGetCurrent();
    double duration=0;
    int totalPages=(int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView];
    ///检查缓存索引键是否完全
    for (int a=0; a<totalPages; a++) {
        if (![self.flipsView.cache pageCacheAtPageIndex:a]){
            [self.flipsView.cache addPage];
        }
    }
    ///对贴图顺序进行排序
    NSArray* sortedPages=[self _sortedPagesForTargetPageIndex:targetPageIndex];
    ///统计贴图的页面数和跳过的页面数(WKFlipsLayer的正反面)
    int numbersPastes=0,numbersSkips=0;
    for(NSNumber* pageNumber in sortedPages) {
        int pageIndex=[pageNumber intValue];
        duration=CFAbsoluteTimeGetCurrent()-startTime;
        ///超出设定时间了，跳过贴图
        if (maxSeconds>0 && duration>=maxSeconds){
            //NSLog(@"duration:%f",duration);
            //break;
            numbersSkips+=2;
            continue;
        }
        int layerIndexForTop=totalPages-pageIndex;
        int layerIndexForBottom=layerIndexForTop-1;
        WKFlipsLayer* layerForTop=self.layer.sublayers[layerIndexForTop];
        WKFlipsLayer* layerForBottom=self.layer.sublayers[layerIndexForBottom];
        ///如果已经有贴图了就跳过
        if (layerForTop.backLayer.contents && layerForBottom.frontLayer.contents){
            numbersSkips+=2;
            continue;
        }
        ///用作缩略图的页面内容
        WKFlipPageView* page=[self.flipsView.dataSource flipsView:self.flipsView pageAtPageIndex:pageIndex isThumbCopy:YES];
        WKFlipPageViewCache* pageCache=[self.flipsView.cache pageCacheAtPageIndex:pageIndex];
        NSArray* images=nil;
        if (!layerForTop.backLayer.contents){
            ///没有缓存
            if (!pageCache.topImage){
                images=[page makeHSnapShotImages];
                [pageCache setTopImage:images[0]];
            }
            layerForTop.backLayer.contents=(id)pageCache.topImage.CGImage;
            numbersPastes+=1;
            //NSLog(@"new image pasted");
        }
        else{
            numbersSkips+=1;
        }
        if (!layerForBottom.frontLayer.contents){
            if (!pageCache.bottomImage){
                ///如果已经有截图了就不要重新创建了
                if (!images){
                    images=[page makeHSnapShotImages];
                }
                [pageCache setBottomImage:images[1]];
            }
            layerForBottom.frontLayer.contents=(id)pageCache.bottomImage.CGImage;
            numbersPastes+=1;
            //NSLog(@"new images pasted");
        }
        else{
            numbersSkips+=1;
        }
        
    }
    duration=CFAbsoluteTimeGetCurrent()-startTime;
    NSLog(@"pastes:%d,skips:%d,duration:%f",numbersPastes,numbersSkips,duration);
}
///对页面的贴图顺序进行排序，当前页面周边的优先贴图
-(NSArray*)_sortedPagesForTargetPageIndex:(int)targetPageIndex{
    NSMutableArray* pagesArray=[NSMutableArray array];
    int numbersOfPages=(int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView];
    for (int a=0; a<numbersOfPages; a++) {
        [pagesArray addObject:[NSNumber numberWithInt:a]];
    }
    //NSLog(@"pagesArray:%@",pagesArray);
    //targetPageIndex=self.flipsView.pageIndex;
    NSArray* sortedPagesArray=[pagesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int page_1=[(NSNumber*)obj1 intValue];
        int distance_1=abs(page_1-targetPageIndex);
        int page_2=[(NSNumber*)obj2 intValue];
        int distance_2=abs(page_2-targetPageIndex);
        if (distance_1<distance_2){
            return NSOrderedAscending;
        }
        else if (distance_1>distance_2){
            return NSOrderedDescending;
        }
        else
            return NSOrderedSame;
    }];
    //NSLog(@"sortedPagesArray:%@",sortedPagesArray);
    return sortedPagesArray;
}
#pragma mark - flips
///无动画的翻页
-(void)flipToPageIndex:(int)pageIndex{
//    if (pageIndex && pageIndex==self.flipsView.pageIndex)
//        return;
    pageIndex=MIN(pageIndex, (int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]-1);
    pageIndex=MAX(pageIndex, 0);
    int layersNumber=[self numbersOfLayers];
    ///往前翻页，也就是把上半部分的页面往下面翻
    if (pageIndex<self.flipsView.pageIndex){
        for (int layerIndex=0; layerIndex<layersNumber; layerIndex++) {
            CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            WKFlipsLayer *flipLayer=self.layer.sublayers[layerIndex];
            flipLayer.rotateDegree=rotateDegree;
        }
    }
    ///往后面翻页,也就是把下半部分的往上面翻
    else{
        for (int layerIndex=layersNumber-1; layerIndex>=0; layerIndex--) {
            CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
            flipLayer.rotateDegree=rotateDegree;
        }
    }
    self.flipsView.pageIndex=pageIndex;
}
-(void)flipToPageIndex:(int)pageIndex completion:(void (^)(BOOL completed))completionBlock{
    if(self.runState!=WKFlipsLayerViewRunStateStop)
        return;
    pageIndex=MIN(pageIndex, (int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView]-1);
    pageIndex=MAX(pageIndex, 0);
    if (pageIndex==self.flipsView.pageIndex)
        return;
    self.runState=WKFlipsLayerViewRunStateAnimation;
    CGFloat durationFull=3.0f;
    CGFloat delayFromDuration=0.05f;
    ///往前翻页，也就是把上半部分往下面翻页
    CGFloat delay=0.0f;
    int layersNumber=[self numbersOfLayers];
    __block int complete_hits=0;
    if (pageIndex<self.flipsView.pageIndex){
        for (int layerIndex=0; layerIndex<layersNumber; layerIndex++) {
            CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            //NSLog(@"layerIndex:%d,%f",layerIndex,rotateDegree);
            WKFlipsLayer *flipLayer=self.layer.sublayers[layerIndex];
            CGFloat rotateDistance=fabsf(rotateDegree-flipLayer.rotateDegree);
            CGFloat duration=rotateDistance/180.0f*durationFull;
            delay+=duration*delayFromDuration;
            [flipLayer setRotateDegree:rotateDegree duration:duration afterDelay:delay completion:^{
                if (++complete_hits>=layersNumber){
                        //NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        ///延时一点进行贴图
                        double delayInSeconds = WKFlipsLayerView_PasteImage_Delay;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            ///先创建贴图在设置pageIndex
                            [self _pasteImagesToLayersForTargetPageIndex:pageIndex inSeconds:WKFlipsLayerView_PasteImageDuration_After_Flipped];
                        });
                        completionBlock(YES);
                        self.runState=WKFlipsLayerViewRunStateStop;
                    }
            }];
            
        }
    }
    else{
        for (int layerIndex=layersNumber-1; layerIndex>=0; layerIndex--) {
            CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:pageIndex];
            //NSLog(@"layerIndex:%d,%f",layerIndex,rotateDegree);
            WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
            CGFloat rotateDistance=fabsf(rotateDegree-flipLayer.rotateDegree);
            CGFloat duration=rotateDistance/180.0f*durationFull;
            delay+=duration*delayFromDuration;
            [flipLayer setRotateDegree:rotateDegree duration:duration afterDelay:delay completion:^{
                if (++complete_hits>=layersNumber){
                        //NSLog(@"flip completed");
                        self.flipsView.pageIndex=pageIndex;
                        ///延时一点进行贴图
                        double delayInSeconds = WKFlipsLayerView_PasteImage_Delay;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            ///先创建贴图在设置pageIndex
                            [self _pasteImagesToLayersForTargetPageIndex:pageIndex inSeconds:WKFlipsLayerView_PasteImageDuration_After_Flipped];
                        });
                        completionBlock(YES);
                        self.runState=WKFlipsLayerViewRunStateStop;
                    
                    }
            }];
        }
    }
}
///当翻页到一个pageIndex,为每个layer计算角度
-(CGFloat)_calculateRotateDegreeForLayerIndex:(int)layerIndex toTargetPageIndex:(int)pageIndex{
    int layersNumber=[self numbersOfLayers];
    int stopLayerIndexAtTop=layersNumber-1-pageIndex;
    int stopLayerIndexAtBottom=stopLayerIndexAtTop-1;
    //CGFloat spaceRotate=1.0f;
    CGFloat spaceRotate=0.01f;
    if (layerIndex>=stopLayerIndexAtTop){
        return 180.0f+(layerIndex-stopLayerIndexAtTop)*spaceRotate;
    }
    else if (layerIndex<=stopLayerIndexAtBottom){
        return 0.0f-(stopLayerIndexAtBottom-layerIndex)*spaceRotate;
    }
    else{
        return 0.0f;
    }

}
#pragma mark - Drag
-(void)dragBegan{
//    NSLog(@"dragBegan");
//    if (self.runState!=WKFlipsLayerViewRunStateStop)
//        return;
    if (self.runState==WKFlipsLayerViewRunStateAnimation) ///如果正在连续动画就不拖动
        return;
    [_dragging_layer cancelDragAnimation];///如果有_dragging_layer的话，取消拖动的动画
    self.runState=WKFlipsLayerViewRunStateDragging;
}
-(void)dragEnded{
//    NSLog(@"dragEnded");
    if (self.runState!=WKFlipsLayerViewRunStateDragging)
        return;
    CGFloat durationFull=1.0f;
    if (_dragging_position==WKFlipsLayerDragAtPositionTop){
        ///返回现在的页面
        if (_dragging_layer.rotateDegree>=90.0f){
            int layerIndex=(int)[self.layer.sublayers indexOfObject:_dragging_layer];
            CGFloat oldRotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:self.flipsView.pageIndex];
            CGFloat duration=fabsf(oldRotateDegree-_dragging_layer.rotateDegree)/180.0f*durationFull;
            [_dragging_layer setRotateDegree:oldRotateDegree duration:duration afterDelay:0.0f completion:^{
                _dragging_layer=nil;
                self.runState=WKFlipsLayerViewRunStateStop;
            }];
        }
        else{///到前一页
            int previousPageIndex=self.flipsView.pageIndex-1;
            int layersNumber=[self numbersOfLayers];
            for (int layerIndex=0; layerIndex<layersNumber; layerIndex++) {
                CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:previousPageIndex];
                //NSLog(@"layerIndex:%d,rotateDegree:%f",layerIndex,rotateDegree);
                WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
                if (flipLayer!=_dragging_layer){
                    [flipLayer setRotateDegree:rotateDegree];
                }
            }
            int layerIndex=(int)[self.layer.sublayers indexOfObject:_dragging_layer];
            CGFloat newRotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:previousPageIndex];
            CGFloat duration=fabsf(newRotateDegree-_dragging_layer.rotateDegree)/180.0f*durationFull;
            [_dragging_layer setRotateDegree:newRotateDegree duration:duration afterDelay:0.0f completion:^{
                _dragging_layer=nil;
                self.flipsView.pageIndex=previousPageIndex;
                ///延时一点进行贴图
                double delayInSeconds = WKFlipsLayerView_PasteImage_Delay;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    ///先创建贴图在设置pageIndex
                    [self _pasteImagesToLayersForTargetPageIndex:previousPageIndex inSeconds:WKFlipsLayerView_PasteImageDuration_After_Flipped];
                });
                self.runState=WKFlipsLayerViewRunStateStop;
            }];
        }
    }
    else{
        ///到后一页
        if (_dragging_layer.rotateDegree>=90.0f){
            int nextPageIndex=self.flipsView.pageIndex+1;
            int layersNUmber=[self numbersOfLayers];
            for (int layerIndex=layersNUmber-1; layerIndex>=0; layerIndex--) {
                CGFloat rotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:nextPageIndex];
                WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
                if (flipLayer!=_dragging_layer)
                    [flipLayer setRotateDegree:rotateDegree];
            }
            int layerIndex=(int)[self.layer.sublayers indexOfObject:_dragging_layer];
            CGFloat newRotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:nextPageIndex];
            CGFloat duration=fabsf(newRotateDegree-_dragging_layer.rotateDegree)/180.0f*durationFull;
            [_dragging_layer setRotateDegree:newRotateDegree duration:duration afterDelay:0.0f completion:^{
                _dragging_layer=nil;
                self.flipsView.pageIndex=nextPageIndex;
                ///延时一点进行贴图
                double delayInSeconds = WKFlipsLayerView_PasteImage_Delay;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    ///先创建贴图在设置pageIndex
                    [self _pasteImagesToLayersForTargetPageIndex:nextPageIndex inSeconds:WKFlipsLayerView_PasteImageDuration_After_Flipped];
                });
                
                self.runState=WKFlipsLayerViewRunStateStop;
                
            }];
        }
        else{///返回到现在的页面
            int layerIndex=(int)[self.layer.sublayers indexOfObject:_dragging_layer];
            CGFloat oldRotateDegree=[self _calculateRotateDegreeForLayerIndex:layerIndex toTargetPageIndex:self.flipsView.pageIndex];
            CGFloat duration=fabsf(oldRotateDegree-_dragging_layer.rotateDegree)/180.0f*durationFull;
            [_dragging_layer setRotateDegree:oldRotateDegree duration:duration afterDelay:0.0f completion:^{
                _dragging_layer=nil;
                self.runState=WKFlipsLayerViewRunStateStop;
            }];
        }
    }
}
-(void)draggingWithTranslation:(CGPoint)translation{
    //NSLog(@"dragging:%f",translation.y);
    if (self.runState!=WKFlipsLayerViewRunStateDragging)
        return;
    if (!_dragging_layer){
        int layersNumber=[self numbersOfLayers];
        int stopLayerIndexAtTop=layersNumber-1-self.flipsView.pageIndex;
        int stopLayerIndexAtBottom=stopLayerIndexAtTop-1;
        if (translation.y>0){
            _dragging_layer=self.layer.sublayers[stopLayerIndexAtTop];
            _dragging_position=WKFlipsLayerDragAtPositionTop;
        }
        else{
            _dragging_layer=self.layer.sublayers[stopLayerIndexAtBottom];
            _dragging_position=WKFlipsLayerDragAtPositionBottom;
        }
    }
    ///往下面翻
    if (_dragging_position==WKFlipsLayerDragAtPositionTop){
        CGFloat rotateDegree=_dragging_layer.rotateDegree-(translation.y-_dragging_last_translation_y)*0.5;
        rotateDegree=fminf(rotateDegree, 179.0f);
        ///最后一页翻不到下面
        if (_dragging_layer==self.layer.sublayers.lastObject){
            rotateDegree=fmaxf(rotateDegree, 91.0f);
        }
        else{
            rotateDegree=fmaxf(rotateDegree, 1.0f);
        }
        _dragging_layer.rotateDegree=rotateDegree;
    }
    else{ ///往上面翻
        CGFloat rotateDegree=_dragging_layer.rotateDegree-(translation.y-_dragging_last_translation_y)*0.5f;
        ///第一页翻不到上面
        if (_dragging_layer==self.layer.sublayers.firstObject){
            rotateDegree=fminf(rotateDegree, 89.0f);
        }
        else{
            rotateDegree=fminf(rotateDegree, 179.0f);
        }
        rotateDegree=fmaxf(rotateDegree, 1.0f);
        _dragging_layer.rotateDegree=rotateDegree;
    }
    _dragging_last_translation_y=translation.y;
    
}
///显示拖动时的图层阴影
-(void)_showShadowOnDraggingLayer{
    ///找到需要设置阴影的图层
    int layersNumber=[self numbersOfLayers];
    int stopLayerIndexAtTop=layersNumber-1-self.flipsView.pageIndex;
    int stopLayerIndexAtBottom=stopLayerIndexAtTop-1;
    ///设置阴影
    WKFlipsLayer* topLayer=self.layer.sublayers[stopLayerIndexAtTop];
    [topLayer showShadowStyle:WKFlipsLayerShadowStyle1];
    WKFlipsLayer* bottomLayer=self.layer.sublayers[stopLayerIndexAtBottom];
    [bottomLayer showShadowStyle:WKFlipsLayerShadowStyle2];
}
///去掉图层阴影，从所有图层上处理
-(void)_removeShadowOnDraggngLayer{
    double startTime=CFAbsoluteTimeGetCurrent();
    int layersNUmber=[self numbersOfLayers];
    for (int layerIndex=layersNUmber-1; layerIndex>=0; layerIndex--){
        WKFlipsLayer* flipLayer=self.layer.sublayers[layerIndex];
        [flipLayer removeShadow];
    }
    NSLog(@"removeShaodw duration:%f",CFAbsoluteTimeGetCurrent()-startTime);
}
@end

#pragma mark - WKFlipsLayer
@interface WKFlipsLayer(){
    
}
///动画是否被取消
@property (nonatomic,assign) BOOL isAnimationCancelled;
///正在取消拖动时，记录当前的位置
@property (nonatomic,assign) CATransform3D cancelledTransform;
@end
@implementation WKFlipsLayer
-(id)initWithFrame:(CGRect)frame{
    self=[super init];
    if (self){
        self.frame=frame;
        self.doubleSided=YES;
        self.anchorPoint=CGPointMake(0.5, 0.0f);
        self.position=CGPointMake(self.position.x,
                                  self.position.y-self.frame.size.height/2);
        _frontLayer=[[CALayer alloc]init];
        _frontLayer.frame=self.bounds;
        _frontLayer.backgroundColor=[UIColor grayColor].CGColor;
        _frontLayer.doubleSided=NO;
        _frontLayer.name=@"frontLayer";
        
        _backLayer=[[CALayer alloc]init];
        _backLayer.frame=self.bounds;
        _backLayer.backgroundColor=[UIColor whiteColor].CGColor;
        _backLayer.doubleSided=YES;
        _backLayer.name=@"backLayer";
        _backLayer.transform=WKFlipCATransform3DPerspectSimpleWithRotate(180.0f);
        
        [self insertSublayer:_frontLayer atIndex:0];
        [self insertSublayer:_backLayer atIndex:0];
    }
    return self;
}
-(void)dealloc{
    [_shadowOnFronLayer release];
    [_shadowOnBackLayer release];
    [_frontLayer release];
    [_backLayer release];
    [super dealloc];
}
#pragma mark - Test
-(void)drawWords:(NSString *)words onPosition:(int)position{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
    CGContextTranslateCTM(context, 0, self.frame.size.height); // 3-1
    CGContextScaleCTM(context, 1.0, -1.0); // 4-1
    ///Text
    NSMutableAttributedString* attributeString=[[[NSMutableAttributedString alloc]initWithString:words] autorelease];
    CTFontRef fontRefBold = CTFontCreateWithName((CFStringRef)@"Helvetica-Bold", 20.0f, NULL); // 3-3  字体
    NSDictionary *attrDictionaryBold = [NSDictionary dictionaryWithObjectsAndKeys:(id)fontRefBold, (NSString *)kCTFontAttributeName, (id)[[UIColor blackColor] CGColor], (NSString *)(kCTForegroundColorAttributeName), nil]; // 4-3，另一个格式，用来设置部分文字的样式
    [attributeString addAttributes:attrDictionaryBold range:NSMakeRange(0,attributeString.length)]; // 5-3 一段范围内的文字格式，添加这个样式（只对应指定长度内）
    CFRelease(fontRefBold); // 6-3
    CGMutablePathRef path = CGPathCreateMutable(); // 5-2
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)); // 6-2 绘制的区域
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString); // 7-2，设置text frame的样式和内容
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, NULL); // 8-2 创建text frame
    CFRelease(framesetter); // 9-2
    CFRelease(path); // 10-2
    CTFrameDraw(theFrame, context); // 11-2 绘制这个区域
    CFRelease(theFrame); // 12-2
    UIImage* imageOutput=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    CALayer *wordsLayer=[[[CALayer alloc]init] autorelease];
    wordsLayer.frame=self.bounds;
    wordsLayer.contents=(id)imageOutput.CGImage;
    if (position==0){
        [self.frontLayer addSublayer:wordsLayer];
    }
    else{
        [self.backLayer addSublayer:wordsLayer];
    }
}
#pragma mark - Cancel Drag
-(void)cancelDragAnimation{
    self.cancelledTransform=((CALayer*)self.presentationLayer).transform;
    self.isAnimationCancelled=YES;
    [self removeAllAnimations];
}
#pragma mark - rotateDegree
-(void)setRotateDegree:(CGFloat)rotateDegree{
    _rotateDegree=rotateDegree;
    self.transform=WKFlipCATransform3DPerspectSimpleWithRotate(rotateDegree);
}
-(CGFloat)rotateDegree{
    return _rotateDegree;
}
#pragma mark rotateDegree animation
-(void)setRotateDegree:(CGFloat)rotateDegree duration:(CGFloat)duration afterDelay:(NSTimeInterval)delay completion:(void (^)())completion{
    CATransform3D fromTrnasform=self.transform;
    CGFloat halfRotateDegree=self.rotateDegree+(rotateDegree-self.rotateDegree)/2.0f;
    CATransform3D halfTransform=WKFlipCATransform3DPerspectSimpleWithRotate(halfRotateDegree);
    CATransform3D toTransform=WKFlipCATransform3DPerspectSimpleWithRotate(rotateDegree);
    //NSLog(@"%f,%f,%f",self.rotateDegree,halfRotateDegree,rotateDegree);
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
    CAKeyframeAnimation* flipAnimation=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    flipAnimation.delegate=self;
    flipAnimation.duration=duration;
    flipAnimation.beginTime=[self convertTime:CACurrentMediaTime() fromLayer:nil]+delay;
    flipAnimation.removedOnCompletion=NO;
    flipAnimation.fillMode=kCAFillModeForwards;
    flipAnimation.keyTimes=@[@0.0f,@0.5f,@1.0f];
    flipAnimation.values=@[[NSValue valueWithCATransform3D:fromTrnasform],[NSValue valueWithCATransform3D:halfTransform],
                           [NSValue valueWithCATransform3D:toTransform]];
    [CATransaction setCompletionBlock:^{
        if (!_isAnimationCancelled){
            self.rotateDegree=rotateDegree;
            completion();
        }
        else{
            self.transform=self.cancelledTransform;///动画被取消，停在当前的位置,也不要回调
        }
        [self removeAllAnimations];
        
        _isAnimationCancelled=NO;
    }];
    [self addAnimation:flipAnimation forKey:@"animation-flip"];
    [CATransaction commit];
}
#pragma mark shadow
-(void)showShadowStyle:(WKFlipsLayerShadowStyle)style{
    if (_shadowOnBackLayer || _shadowOnFronLayer)
        return;
    //NSLog(@"showShadowStyle:%d",style);
    _shadowOnFronLayer=[[CALayer alloc]init];
    _shadowOnFronLayer.frame=self.bounds;
    _shadowOnBackLayer=[[CALayer alloc]init];
    _shadowOnBackLayer.frame=self.bounds;
    [self.frontLayer addSublayer:_shadowOnFronLayer];
    [self.backLayer addSublayer:_shadowOnBackLayer];
    switch (style) {
        case WKFlipsLayerShadowStyle1:
            _shadowOnBackLayer.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2f].CGColor;
            _shadowOnFronLayer.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2f].CGColor;
            break;
        case WKFlipsLayerShadowStyle2:
            _shadowOnBackLayer.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.15f].CGColor;
            _shadowOnFronLayer.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.15f].CGColor;
            break;
        default:
            break;
    }
    
    
}
-(void)removeShadow{
    //NSLog(@"removeShadow");
    if (_shadowOnFronLayer){
        [_shadowOnFronLayer removeFromSuperlayer];
        _shadowOnFronLayer=nil;
    }
    if (_shadowOnBackLayer){
        [_shadowOnBackLayer removeFromSuperlayer];
        _shadowOnBackLayer=nil;
    }
}
@end
