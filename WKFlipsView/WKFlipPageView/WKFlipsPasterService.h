//
//  WKFlipsPasterService.h
//  WKFlipsView
//
//  Created by 秦 道平 on 14-6-5.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WKFlipsLayer;
@class WKFlipsLayerView;
@interface _WKFlipsPasterService : NSObject{
    NSMutableArray *_taskList;
    NSTimeInterval _runSecnods;///运行时间
    double _startTime;
}
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,assign) WKFlipsLayerView *flipsLayerView;
-(instancetype)initWithFlipsLayerView:(WKFlipsLayerView*)flipsLayerView;
-(void)startWithPriorPageIndex:(int)pageIndex inSecnods:(NSTimeInterval)seconds;
-(void)stop;
/**
 *  为一个具体的页面完成贴图工作
 *
 *  @param pageIndex 
 */
-(void)pasterWorkAtPageIndex:(int)pageIndex;
@end
