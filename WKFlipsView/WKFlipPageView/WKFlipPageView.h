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
@end
