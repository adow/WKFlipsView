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
    }
    return self;
}

-(void)dealloc{
    [_reusedPageViewDictionary release];
    [_currentPageView release];
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
}
@end
