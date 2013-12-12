//
//  WKFlipPageView.h
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WK.h"
@interface WKFlipPageView : UIView{
    
}

///重用时调用
-(void)prepareForReuse;
#pragma mark - SnapShot
///创建截图
-(UIImage*)makeSnapShotImage;
///创建截图并且横向分割
-(NSArray*)makeHSnapShotImages;
#pragma mark - Cache
///缓存名字
@property (nonatomic,copy) NSString* cacheName;
///上半部分缓存图片
@property (nonatomic,readonly) UIImage* cacheImageHTop;
///下半部分缓存的图片
@property (nonatomic,readonly) UIImage* cacheImageHBottom;
///批量删除缓存图片
+(void)removeCacheImagesByCacheNames:(NSArray*)cacheNames;
@end
