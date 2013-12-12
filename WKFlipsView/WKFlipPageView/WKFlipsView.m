//
//  WKFlipsView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipsView.h"

@implementation WKFlipsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _reusedPageViewDictionary=[[NSMutableDictionary alloc]init];
        _currentPageView=[[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_currentPageView];
        _testCacheView=[[UIView alloc]initWithFrame:self.bounds];
        _testCacheView.backgroundColor=[UIColor whiteColor];
        [self addSubview:_testCacheView];
    }
    return self;
}

-(void)dealloc{
    [_reusedPageViewDictionary release];
    [_currentPageView release];
    [_testCacheView release];
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
}
-(WKFlipPageView*)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier{
    WKFlipPageView* pageView= _reusedPageViewDictionary[reuseIdentifier];
    [pageView prepareForReuse];
    return pageView;
}
#pragma mark - action
//显示第几页内容
-(void)showAtPageIndex:(int)pageIndex{
    for (UIView* view in self.currentPageView.subviews) {
        [view removeFromSuperview];
    }
    _pageIndex=pageIndex;
    WKFlipPageView* pageView=[self.dataSource flipsView:self pageAtPageIndex:pageIndex];
    [self.currentPageView addSubview:pageView];
    [pageView prepareCacheImage];
    ///test
    [self _test_update_cache_for_page:pageView];
//    double delayInSeconds = 0.001;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self _test_update_cache_for_page:pageView];
//        
//    });
}
-(void)preparePageCachesFromPageIndex:(int)startPageIndex toPageIndex:(int)toPageIndex{
    for (int pageIndex=startPageIndex; pageIndex<=toPageIndex; pageIndex++) {
        WKFlipPageView* pageView=[self.dataSource flipsView:self pageAtPageIndex:pageIndex];
        [pageView prepareCacheImage];
    }
}
#pragma mark - Test
///更新换乘图片显示
-(void)_test_update_cache_for_page:(WKFlipPageView*)pageView{
    for (UIView* view in _testCacheView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView* imageViewTop=[[[UIImageView alloc]initWithImage:pageView.cacheImageHTop] autorelease];
    CGRect imageViewTopFrame=imageViewTop.frame;
    imageViewTopFrame.origin.x=100.0f;
    imageViewTopFrame.origin.y=200.0f;
    imageViewTop.frame=imageViewTopFrame;
    [_testCacheView addSubview:imageViewTop];
    UIImageView* imageViewBottom=[[[UIImageView alloc]initWithImage:pageView.cacheImageHBottom] autorelease];
    CGRect imageViewBottomFrame=imageViewBottom.frame;
    imageViewBottomFrame.origin.x=100.0f;
    imageViewBottomFrame.origin.y=CGRectGetMaxY(imageViewTopFrame);
    imageViewBottom.frame=imageViewBottomFrame;
    [_testCacheView addSubview:imageViewBottom];
}
@end
