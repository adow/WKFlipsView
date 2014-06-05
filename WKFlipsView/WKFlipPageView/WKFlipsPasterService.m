//
//  WKFlipsPasterService.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-6-5.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "WKFlipsPasterService.h"
#import "WKFlipsLayer.h"
#import "WKFlipsView.h"
@implementation _WKFlipsPasterService
-(instancetype)initWithFlipsLayerView:(WKFlipsLayerView *)flipsLayerView{
    self=[super init];
    if (self){
        self.flipsLayerView=flipsLayerView;
        _taskList=[[NSMutableArray alloc]init];
        _runSecnods=5.0f;///默认运行5s
    }
    return self;
}
-(void)dealloc{
    [_timer invalidate];
    [_timer release];
    [_taskList release];
    [super dealloc];
}
#pragma mark - Action
///开始页面贴图，指定优先页面
-(void)startWithPriorPageIndex:(int)pageIndex inSecnods:(NSTimeInterval)seconds{
    NSLog(@"PasterService start");
    _runSecnods=seconds;
    _startTime=CFAbsoluteTimeGetCurrent();
//    int totalPages=self.flipsLayerView.totalPages;
    ///检查缓存索引键是否完全
    [self.flipsLayerView preparePageCache];
    ///更新任务队列，保存的是每个页面编码
    [_taskList removeAllObjects];
    [_taskList addObjectsFromArray:[self _sortedPagesForPriorPageIndex:pageIndex]];
    ///开始计时器
    if (!self.timer.isValid){
        self.timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(_timerPasterWork) userInfo:nil repeats:YES];
    }
}
///结束贴图任务
-(void)stop{
    [_timer invalidate];    
//    [_timer release];
    NSLog(@"PasterService stop");
}
///排序贴图页面顺序
-(NSArray*)_sortedPagesForPriorPageIndex:(int)priorPageIndex{
    NSMutableArray* pagesArray=[NSMutableArray array];
    int numbersOfPages=self.flipsLayerView.totalPages;
    for (int a=0; a<numbersOfPages; a++) {
        [pagesArray addObject:[NSNumber numberWithInt:a]];
    }
    //NSLog(@"pagesArray:%@",pagesArray);
    //targetPageIndex=self.flipsView.pageIndex;
    NSArray* sortedPagesArray=[pagesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int page_1=[(NSNumber*)obj1 intValue];
        int distance_1=abs(page_1-priorPageIndex);
        int page_2=[(NSNumber*)obj2 intValue];
        int distance_2=abs(page_2-priorPageIndex);
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
-(void)_timerPasterWork{
    if (_taskList.count<=0 || CFAbsoluteTimeGetCurrent()-_startTime>=_runSecnods){
        [self stop];
        return;
    }
    int totalPages=self.flipsLayerView.totalPages;
    int pageIndex=[_taskList[0] intValue];
    [_taskList removeObjectAtIndex:0];
    NSLog(@"paster work:%d",pageIndex);
    int layerIndexForTop=totalPages-pageIndex;
    int layerIndexForBottom=layerIndexForTop-1;
    WKFlipsLayer* layerForTop=self.flipsLayerView.layer.sublayers[layerIndexForTop];
    WKFlipsLayer* layerForBottom=self.flipsLayerView.layer.sublayers[layerIndexForBottom];
    ///已经有贴图了
    if (layerForTop.backLayer.contents && layerForBottom.frontLayer.contents){
        return;
    }
    ///用作缩略图的页面内容
    WKFlipPageView* page=[self.flipsLayerView.flipsView.dataSource flipsView:self.flipsLayerView.flipsView pageAtPageIndex:pageIndex isThumbCopy:YES];
    WKFlipPageViewCache* pageCache=[self.flipsLayerView.flipsView.cache pageCacheAtPageIndex:pageIndex];
    NSArray* images=nil;
    if (!layerForTop.backLayer.contents){
        ///没有缓存
        if (!pageCache.topImage){
            images=[page makeHSnapShotImages];
            [pageCache setTopImage:images[0]];
        }
        layerForTop.backLayer.contents=(id)pageCache.topImage.CGImage;
        //NSLog(@"new image pasted");
    }
    else{
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
        //NSLog(@"new images pasted");
    }
    else{
    }
    
}
@end
