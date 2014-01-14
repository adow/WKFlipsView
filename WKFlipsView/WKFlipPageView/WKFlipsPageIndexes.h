//
//  WKFlipsIndexes.h
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-13.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKFlipsPageIndexes : NSObject{
    
}
///索引列表
@property (nonatomic,retain) NSMutableArray* indexList;
@property (nonatomic,copy) NSString* filename;
///创建文件
+(id)createPageIndexesFile:(NSString*)filename;
///读取文件
+(id)loadPageIndexesFile:(NSString*)filename;
///检查文件存在
+(BOOL)pageIndexesFileExisted:(NSString*)filename;
///更新文件
-(void)write;
-(void)addPageIndex:(NSString*)index;
-(void)insertPageIndex:(NSString*)index atPos:(int)pos;
-(int)posForPageIndex:(NSString*)index;
-(NSString*)indexAtPos:(int)pos;
-(void)deletePageIndex:(NSString*)index;
@end
