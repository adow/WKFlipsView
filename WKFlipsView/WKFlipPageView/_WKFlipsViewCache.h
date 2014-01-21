//
//  _WKFlipsViewCache.h
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-18.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  _WKFlipsViewCache;
@interface _WKFlipPageViewCache:NSObject{
    UIImage* _topImage;
    UIImage* _bottomImage;
}
///页面标识
@property (nonatomic,copy) NSString* pageIdentity;
///缓存top
@property (nonatomic,retain) UIImage* topImage;
///缓存bottom
@property (nonatomic,retain) UIImage* bottomImage;
///缓存文件文件名top
@property (nonatomic,readonly) NSString* topImageFilename;
///缓存文件名bottom
@property (nonatomic,readonly) NSString* bottomImageFilename;
///所在目录
@property (nonatomic,readonly) NSString* folder;
///页面顺序
@property (nonatomic,readonly) int pageIndex;
@property (nonatomic,assign) _WKFlipsViewCache* flipsViewCache;
+(id)flipPageCacheWithIdentity:(NSString*)pageIdentity inFlipsViewCache:(_WKFlipsViewCache*)flipsViewCache;
///删除缓存图片
-(void)removeCacheImage;
@end
@interface _WKFlipsViewCache : NSObject{
    
}
@property (nonatomic,retain) NSMutableArray* pageIdentityArray;
///文件夹标识
@property (nonatomic,copy) NSString* identity;
///文件名
@property (nonatomic,readonly) NSString* folder;
///索引文件名
@property (nonatomic,readonly) NSString* indexFilename;
-(id)initWithIdentity:(NSString*)identity;
-(_WKFlipPageViewCache*)pageCacheAtPageIndex:(int)pageIndex;
-(_WKFlipPageViewCache*)pageCacheForPageIdentity:(NSString*)pageIdentity;
-(void)removeAtPageIndex:(int)pageIndex;
-(void)removeCacheImageAtPageIndex:(int)pageIndex;
-(_WKFlipPageViewCache*)insertAtPageIndex:(int)pageIndex;
-(_WKFlipPageViewCache*)addPage;
@end
