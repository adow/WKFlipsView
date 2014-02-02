//
//  WKFlipsView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsView.h"
@implementation WKFlipsView
@dynamic pageIndex;
- (id)initWithFrame:(CGRect)frame atPageIndex:(int)pageIndex withCacheIdentity:(NSString *)cacheIdentity{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cache=[[WKFlipsViewCache alloc]initWithIdentity:cacheIdentity];
        _reusedPageViewDictionary=[[NSMutableDictionary alloc]init];
        _reusedPageViewDictionaryCopy=[[NSMutableDictionary alloc]init];
        _currentPageView=[[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_currentPageView];
        self.pageIndex=pageIndex;
        _flippingLayersView=[[WKFlipsLayerView alloc] initWithFlipsView:self];
        [self addSubview:_flippingLayersView];
        _flippingLayersView.hidden=YES;
        UIPanGestureRecognizer* panGeture=[[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_flippingPanGesture:)] autorelease];
        [self addGestureRecognizer:panGeture];
    }
    return self;
}
-(void)dealloc{
    [_reusedPageViewDictionary release];
    [_reusedPageViewDictionaryCopy release];
    [_currentPageView release];
    [_cache release];
    //[_testCacheView release];
    [super dealloc];
}
#pragma mark - page
-(void)registerClass:(Class)class forPageWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (![class isSubclassOfClass:[WKFlipPageView class]])
        return;
    if (_reusedPageViewDictionary[reuseIdentifier])
        return;
    WKFlipPageView* pageView=[[class alloc]init];
    pageView.frame=self.bounds;
    _reusedPageViewDictionary[reuseIdentifier]=pageView;
    [pageView release];
    ///要保存两份
    WKFlipPageView* pageViewCopy=[[class alloc]init];
    pageViewCopy.frame=self.bounds;
    _reusedPageViewDictionaryCopy[reuseIdentifier]=pageViewCopy;
    [pageViewCopy release];
}
-(WKFlipPageView*)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier isThumbCopy:(bool)isThumbCopy{
    WKFlipPageView* pageView= nil;
    ///用来创建缩略图
    if (isThumbCopy){
        pageView=_reusedPageViewDictionaryCopy[reuseIdentifier];
    }
    else{
        pageView=_reusedPageViewDictionary[reuseIdentifier];
    }
    [pageView prepareForReuse];
    return pageView;
}
#pragma mark - action
-(void)reloadPages{    
    [_flippingLayersView buildLayers];
}
#pragma mark pageIndex
-(int)pageIndex{
    return _pageIndex;
}
///设置正在显示的页面,会更改正在显示的内容
-(void)setPageIndex:(int)pageIndex{
//    if (_pageIndex && _pageIndex==pageIndex)
//        return;
    for (UIView* view in self.currentPageView.subviews) {
        [view removeFromSuperview];
    }
    _pageIndex=pageIndex;
    ///这里的pageView也从deque中获取，所以是一个实例，如果其他地方在创建贴图时也调用了下面这个方法，会导致实例进行更新，所以正在实际显示的页面会被修改.这就要求，在设置pageIndex的前面就应该调用完成创建贴图的过程
    if (pageIndex>=0 && pageIndex<[self.dataSource numberOfPagesForFlipsView:self]){
        WKFlipPageView* pageView=[self.dataSource flipsView:self pageAtPageIndex:pageIndex isThumbCopy:NO];
        ///TODO:这里可能需要禁止动画
        [self.currentPageView addSubview:pageView];
    }
}
-(WKFlipPageView*)currentFlipPageView{
    if(self.currentPageView.subviews.count>0){
        return (WKFlipPageView*)self.currentPageView.subviews[0];
    }
    return nil;
}
-(void)flipToPageIndex:(int)pageIndex{
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex];
}
-(void)flipToPageIndex:(int)pageIndex completion:(void (^)())completion{
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex completion:^(BOOL completed) {
    }];
}
#pragma mark create update and detele
-(void)deleteCurrentPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    ///删除数据
    [self.delegate flipwView:self willDeletePageAtPageIndex:self.pageIndex];
    ///删除缓存
    [self.cache removeAtPageIndex:self.pageIndex];
    ///重建页面
    [self reloadPages];
}
-(void)insertPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    ///更新数据
    [self.delegate flipsView:self willInsertPageAtPageIndex:self.pageIndex];
    ///添加缓存索引
    [self.cache insertAtPageIndex:self.pageIndex];
    ///重建页面
    [self reloadPages];
}
-(void)updateCurrentPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    ///更新数据
    [self.delegate flipsView:self willUpdatePageAtPageIndex:self.pageIndex];
    ////删除已有的缓存图片,索引还是原来的
    [self.cache removeCacheImageAtPageIndex:self.pageIndex];
    ///重建页面
    [self reloadPages];
}
#pragma mark - cache
#pragma mark - touches
-(void)_flippingPanGesture:(UIPanGestureRecognizer*)recognizer{
    if (recognizer.state==UIGestureRecognizerStateBegan){
        [self.flippingLayersView dragBegan];
    }
    else if (recognizer.state==UIGestureRecognizerStateCancelled|| recognizer.state==UIGestureRecognizerStateEnded){
        [self.flippingLayersView dragEnded];
    }
    else if (recognizer.state==UIGestureRecognizerStateChanged){
        CGPoint translation=[recognizer translationInView:self];
        [self.flippingLayersView draggingWithTranslation:translation];
    }
}
@end
