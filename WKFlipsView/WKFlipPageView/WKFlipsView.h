//   
//  WKFlipsView.h
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKFlip.h"
#import "WKFlipPageView.h"
#import "WKFlipsLayer.h"
#import "WKFlipsViewCache.h"
@class WKFlipsView;
@protocol WKFlipsViewDataSource <NSObject>
///每一页内容
-(WKFlipPageView*)flipsView:(WKFlipsView*)flipsView pageAtPageIndex:(int)pageIndex isThumbCopy:(bool)isThumbCopy;
///总页数
-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView*)flipsView;

@end
@protocol WKFlipsViewDelegate <NSObject>
@optional
-(void)flipsView:(WKFlipsView*)flipsView willDeletePageAtPageIndex:(int)pageIndex;
-(void)flipsView:(WKFlipsView*)flipsView willInsertPageAtPageIndex:(int)pageIndex;
-(void)flipsView:(WKFlipsView*)flipsView willUpdatePageAtPageIndex:(int)pageIndex;
-(void)willAppendPageIntoFlipsView:(WKFlipsView*)flipsView;
@end
@interface WKFlipsView : UIView{
    ///用于存储页面类型
    NSMutableDictionary* _reusedPageViewDictionary;
    ///用于存储页面类型，用作缓存用
    NSMutableDictionary* _reusedPageViewDictionaryCopy;
    UIView* _testCacheView;
    int _pageIndex;
}
-(id)initWithFrame:(CGRect)frame atPageIndex:(int)pageIndex withCacheIdentity:(NSString*)cacheIdentity;
///数据源
@property (nonatomic,assign) id<WKFlipsViewDataSource> dataSource;
///委托
@property (nonatomic,assign) id<WKFlipsViewDelegate> delegate;
///翻页集
@property (nonatomic,retain) WKFlipsLayerView* flippingLayersView;
///缓存管理
@property (nonatomic,retain) WKFlipsViewCache* cache;
#pragma mark - page
///用来显示页面
@property (nonatomic,retain) UIView* currentPageView;
///正在显示的页面
@property (nonatomic,readonly) WKFlipPageView* currentFlipPageView;
///当前的页面,不能直接由外部设置这个页面，因为没有重新计算角度，这个方法只能有_flippingLayersView在flip结束后进行更新
@property (nonatomic,assign) int pageIndex;
///注册页面class
-(void)registerClass:(Class)class forPageWithReuseIdentifier:(NSString*)reuseIdentifier;
///获取一个已经使用的page，这个需要收工添加cacheName，可以使用带pageIndex的代替,isThumbCopy表明是否用作缩略图缓存
-(WKFlipPageView*)dequeueReusablePageWithReuseIdentifier:(NSString*)reuseIdentifier isThumbCopy:(bool)isThumbCopy;
#pragma mark - action
///载入页面
-(void)reloadPages;
///无动画的翻页
-(void)flipToPageIndex:(int)pageIndex;
///动画翻页到一个指定的页面
-(void)flipToPageIndex:(int)pageIndex completion:(void(^)())completion;
///在主线程中延时翻页,如果delay=0就立刻执行
-(void)flipToPageIndex:(int)pageIndex delay:(CGFloat)delay completion:(void (^)())completion;
#pragma mark create update and delete
///删除当前这个位置的页面
-(void)deleteCurrentPage;
///在当前的位置添加一个页面
-(void)insertPage;
///在最后面添加一个页面
-(void)appendPage;
///更新当前页面的内容
-(void)updateCurrentPage;
@end
