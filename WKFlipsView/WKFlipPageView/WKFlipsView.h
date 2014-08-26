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
///删除前用来删除数据
-(void)flipsView:(WKFlipsView*)flipsView willDeletePageAtPageIndex:(int)pageIndex;
///插入前用来插入数据
-(void)flipsView:(WKFlipsView*)flipsView willInsertPageAtPageIndex:(int)pageIndex;
///更新前用来更新数据
-(void)flipsView:(WKFlipsView*)flipsView willUpdatePageAtPageIndex:(int)pageIndex;
///追加前用来追加数据
-(void)willAppendPageIntoFlipsView:(WKFlipsView*)flipsView;
///删除页面后通知
-(void)flipsView:(WKFlipsView*)flipsView didDeletePageAtPageIndex:(int)pageIndex;
///插入页面后通知
-(void)flipsView:(WKFlipsView*)flipsView didInsertPageAtPageIndex:(int)pageIndex;
///更新页面后通知
-(void)flipsView:(WKFlipsView*)flipsView didUpdatePageAtPageIndex:(int)pageIndex;
///追加页面后通知
-(void)didAppendPageIntoFlipsView:(WKFlipsView*)flipsView;
///翻页到指定页面之后的通知
-(void)flipsView:(WKFlipsView*)flipsView didFlippedToPageIndex:(int)pageIndex;
///当WKFlipsViewLayer的动作状态改变时，会修改_operateAvailable，并发出回调,在动画，拖放过程中是不可以操作的
-(void)flipsView:(WKFlipsView*)flipsView operateAvailableChangedTo:(BOOL)operateAvailable;
@end
@interface WKFlipsView : UIView{
    ///用于存储页面类型
    NSMutableDictionary* _reusedPageViewDictionary;
    ///用于存储页面类型，用作缓存用
    NSMutableDictionary* _reusedPageViewDictionaryCopy;
    UIView* _testCacheView;
    int _pageIndex;
    ///_operateAvailable
    BOOL __operateAvailable;
    BOOL _pageIndexVisible;
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
///是否可以进行操作,这个值只有WLFlipsLayerView里的状态改变时可以修改,并在修改时发出回调
@property (nonatomic,assign) BOOL _operateAvailable;
#pragma mark - page
///用来显示页面
@property (nonatomic,retain) UIView* currentPageView;
///显示页面编号
@property (nonatomic,retain) UILabel* pageIndexLabel;
///是否显示页面编号
@property (nonatomic,assign) BOOL pageIndexVisible;
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
///是否可以进行翻页操作，包括拖动和动画翻页,一般由外部控制这里是否可以翻页
@property (nonatomic,assign) BOOL flipable;
///由外部来停止贴图队列
-(void)stopPasterService;
#pragma mark pageindex
///隐藏显示页面编号
-(void)hidePageIndex;
///更新显示页面编号
-(void)showPageIndex;
#pragma mark create update and delete
///删除当前这个位置的页面
-(void)deleteCurrentPage;
///删除指定的页面
-(void)deletePage:(int)pageIndex;
///在当前的位置添加一个页面
-(void)insertPage;
///在最后面添加一个页面
-(void)appendPage;
///更新当前页面的内容
-(void)updateCurrentPage;
@end
