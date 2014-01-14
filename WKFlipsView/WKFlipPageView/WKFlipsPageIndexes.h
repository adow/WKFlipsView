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
///添加页面
-(void)addPageIndex:(NSString*)index;
///插入页面
-(void)insertPageIndex:(NSString*)index atPageNumber:(int)pageNumber;
///获取页面位置
-(int)pageNumberForPageIndex:(NSString*)index;
///获取页面所以
-(NSString*)indexAtPageNumber:(int)pageNumber;
///删除页面
-(void)deletePageIndex:(NSString*)index;
@end
