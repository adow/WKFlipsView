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
@dynamic _operateAvailable;
- (id)initWithFrame:(CGRect)frame atPageIndex:(int)pageIndex withCacheIdentity:(NSString *)cacheIdentity{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque=YES;
        self.flipable=YES;
        _cache=[[WKFlipsViewCache alloc]initWithIdentity:cacheIdentity];
        _reusedPageViewDictionary=[[NSMutableDictionary alloc]init];
        _reusedPageViewDictionaryCopy=[[NSMutableDictionary alloc]init];
        _currentPageView=[[UIView alloc]initWithFrame:self.bounds];
        _currentPageView.opaque=YES;
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
#pragma mark - state
-(void)set_operateAvailable:(BOOL)_operateAvailable{
    if (_operateAvailable==__operateAvailable){
        return;
    }
    __operateAvailable=_operateAvailable;
    if ([self.delegate respondsToSelector:@selector(flipsView:operateAvailableChangedTo:)]){
        [self.delegate flipsView:self operateAvailableChangedTo:_operateAvailable];
    }
}
-(BOOL)_operateAvailable{
    return __operateAvailable;
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
    if (!self.flipable){
        NSLog(@"not flipable");
        return;
    }
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex];
//    if ([self.delegate respondsToSelector:@selector(flipsView:didFlippedToPageIndex:)]){
//        [self.delegate flipsView:self didFlippedToPageIndex:pageIndex];
//    }
}
-(void)flipToPageIndex:(int)pageIndex completion:(void (^)())completion{
    if (!self.flipable){
        NSLog(@"not flipable");
        return;
    }
    if (pageIndex<0 || pageIndex>=[self.dataSource numberOfPagesForFlipsView:self]){
        return;
    }
    [_flippingLayersView flipToPageIndex:pageIndex completion:^(BOOL completed) {
        completion();
        if ([self.delegate respondsToSelector:@selector(flipsView:didFlippedToPageIndex:)]){
            [self.delegate flipsView:self didFlippedToPageIndex:pageIndex];
        }
    }];
}
-(void)flipToPageIndex:(int)pageIndex delay:(CGFloat)delay completion:(void (^)())completion{
    if (!delay){
        [self flipToPageIndex:pageIndex completion:completion];
    }
    else{
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self flipToPageIndex:pageIndex completion:completion];
        });
    }
}
#pragma mark create update and detele
-(void)deleteCurrentPage{
//    ///在动画或者拖动时不可以编辑
//    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
//        return;
//    }
//    if (![self.delegate respondsToSelector:@selector(flipsView:willDeletePageAtPageIndex:)]){
//        NSLog(@"no willDeletePageAtPageIndex");
//        return;
//    }
//    ///为当前页面创建一个截图，用来演示删除时的效果
//    UIImage* deleteImageForCurrentPageView=WKFlip_make_image_for_view(self.currentFlipPageView);
//    UIImageView* deleteImageView=[[[UIImageView alloc]initWithImage:deleteImageForCurrentPageView] autorelease];
////    deleteImageView.frame=CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
//    [self.window addSubview:deleteImageView];
//    ///删除数据
//    [self.delegate flipsView:self willDeletePageAtPageIndex:self.pageIndex];
//    ///删除缓存
//    [self.cache removeAtPageIndex:self.pageIndex];
//    ///重建页面
//    [self reloadPages];
//    ///重建页面完成后，显示页面删除的动画
//    double delayInSeconds = 0.01f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
//            deleteImageView.transform=CGAffineTransformMakeTranslation(0.0f, self.frame.size.height);
//            deleteImageView.alpha=0.0f;
//        } completion:^(BOOL finished) {
//            [deleteImageView removeFromSuperview];
//            if ([self.delegate respondsToSelector:@selector(flipsView:didDeletePageAtPageIndex:)]){
//                [self.delegate flipsView:self didDeletePageAtPageIndex:self.pageIndex];
//            }
//        }];
//
//    });
    [self deletePage:self.pageIndex];
}
-(void)deletePage:(int)pageIndex{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    if (![self.delegate respondsToSelector:@selector(flipsView:willDeletePageAtPageIndex:)]){
        NSLog(@"no willDeletePageAtPageIndex");
        return;
    }
    ///如果在删除当前显示的页面，有一个动画
    UIImageView* deleteImageView=nil;
    if (pageIndex==self.pageIndex){
        ///为当前页面创建一个截图，用来演示删除时的效果
        UIImage* deleteImageForCurrentPageView=WKFlip_make_image_for_view(self.currentFlipPageView);
        deleteImageView=[[[UIImageView alloc]initWithImage:deleteImageForCurrentPageView] autorelease];
        [self addSubview:deleteImageView];
    }
    ///删除数据
    [self.delegate flipsView:self willDeletePageAtPageIndex:pageIndex];
    ///删除缓存
    [self.cache removeAtPageIndex:pageIndex];
    ///重建页面
    [self reloadPages];
    ///需要删除的动画
    if (deleteImageView){
        ///重建页面完成后，显示页面删除的动画
        double delayInSeconds = 0.01f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                deleteImageView.transform=CGAffineTransformMakeTranslation(0.0f, self.frame.size.height);
                deleteImageView.alpha=0.0f;
            } completion:^(BOOL finished) {
                [deleteImageView removeFromSuperview];
                if ([self.delegate respondsToSelector:@selector(flipsView:didDeletePageAtPageIndex:)]){
                    [self.delegate flipsView:self didDeletePageAtPageIndex:pageIndex];
                }
            }];
            
        });
    }
    ///不需要删除的过度动画
    else{
        if ([self.delegate respondsToSelector:@selector(flipsView:didDeletePageAtPageIndex:)]){
            [self.delegate flipsView:self didDeletePageAtPageIndex:pageIndex];
        }
    }
}
-(void)insertPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    if (![self.delegate respondsToSelector:@selector(flipsView:willInsertPageAtPageIndex:)]){
        NSLog(@"no willInsertPageAtPageIndex");
        return;
    }
    ///更新数据
    [self.delegate flipsView:self willInsertPageAtPageIndex:self.pageIndex];
    ///添加缓存索引
    [self.cache insertAtPageIndex:self.pageIndex];
    ///在重建页面时，现在的页面已经到后面一页了
    int to_pageIndex=self.pageIndex;
    _pageIndex+=1;
    ///重建页面
    [self reloadPages];
    ///翻页到插入的这个页面
    [self flipToPageIndex:to_pageIndex delay:0.01f completion:^{
        if ([self.delegate respondsToSelector:@selector(flipsView:didInsertPageAtPageIndex:)]){
            [self.delegate flipsView:self didInsertPageAtPageIndex:to_pageIndex];
        }
    }];
}
-(void)appendPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    if (![self.delegate respondsToSelector:@selector(willAppendPageIntoFlipsView:)]){
        NSLog(@"no willAppendPageIntoFlipsView");
        return ;
    }
    [self.delegate willAppendPageIntoFlipsView:self];
    ///添加索引
    [self.cache addPage];
//    ///把页面编号设置为最新的页面(最后一页)
//    _pageIndex=[self.dataSource numberOfPagesForFlipsView:self]-1;
    ///重建页面
    [self reloadPages];
    ///重建完后自动翻页到最后一页
    [self flipToPageIndex:(int)[self.dataSource numberOfPagesForFlipsView:self]-1 delay:0.01f completion:^{
        if ([self.delegate respondsToSelector:@selector(didAppendPageIntoFlipsView:)]){
            [self.delegate didAppendPageIntoFlipsView:self];
        }
    }];
}
-(void)updateCurrentPage{
    ///在动画或者拖动时不可以编辑
    if (self.flippingLayersView.runState!=WKFlipsLayerViewRunStateStop){
        return;
    }
    if (![self.delegate respondsToSelector:@selector(flipsView:willUpdatePageAtPageIndex:)]){
        NSLog(@"no willUpdatePageAtPageIndex");
        return;
    }
    ///更新数据
    [self.delegate flipsView:self willUpdatePageAtPageIndex:self.pageIndex];
    ////删除已有的缓存图片,索引还是原来的
    [self.cache removeCacheImageAtPageIndex:self.pageIndex];
    ///重建页面
    [self reloadPages];
    if ([self.delegate respondsToSelector:@selector(flipsView:didUpdatePageAtPageIndex:)]){
        [self.delegate flipsView:self didUpdatePageAtPageIndex:self.pageIndex];
    }
}
#pragma mark - cache
#pragma mark - touches
-(void)_flippingPanGesture:(UIPanGestureRecognizer*)recognizer{
    if (!self.flipable){
        NSLog(@"not flipable");
        return;
    }
    CGPoint translation=[recognizer translationInView:self];
    if (recognizer.state==UIGestureRecognizerStateBegan){
        [self.flippingLayersView dragBeganWithTranslation:translation];
    }
    else if (recognizer.state==UIGestureRecognizerStateCancelled|| recognizer.state==UIGestureRecognizerStateEnded){
        [self.flippingLayersView dragEndedWithTranslation:translation];
    }
    else if (recognizer.state==UIGestureRecognizerStateChanged){        
        [self.flippingLayersView draggingWithTranslation:translation];
    }
    else if (recognizer.state==UIGestureRecognizerStateFailed){
        NSLog(@"recognizer failed");
    }
}
@end
