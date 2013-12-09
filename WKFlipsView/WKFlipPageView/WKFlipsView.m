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
    }
    return self;
}

-(void)dealloc{
    [_reusedPageViewDictionary release];
    [super dealloc];
}
-(void)resigerClass:(Class)class forPageWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (class!=[WKFlipPageView class])
        return;
    if (_reusedPageViewDictionary[reuseIdentifier])
        return;
    WKFlipPageView* pageView=[[class alloc]init];
    _reusedPageViewDictionary[reuseIdentifier]=pageView;
    [pageView release];
}
-(WKFlipPageView*)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier{
    return _reusedPageViewDictionary[reuseIdentifier];
}
@end
