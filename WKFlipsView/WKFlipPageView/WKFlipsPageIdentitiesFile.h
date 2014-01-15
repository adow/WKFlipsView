//
//  WKFlipsIndexes.h
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-13.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKFlipsPageIdentitiesFile : NSObject{
    
}
///索引列表
@property (nonatomic,retain) NSMutableArray* nameList;
@property (nonatomic,copy) NSString* filename;
///创建文件
+(id)createPageIdentitiesFile:(NSString*)filename;
///读取文件
+(id)loadPageIdentitiesFile:(NSString*)filename;
///检查文件存在
+(BOOL)pageIdentitiesFileExisted:(NSString*)filename;
///更新文件
-(void)write;
///添加页面
-(void)addPageIdentity:(NSString*)pageIdentity;
///插入页面
-(void)insertPageIdentity:(NSString*)pageIdentity atPageIndex:(int)pageIndex;
///获取页面位置
-(int)pageIndexForPageIdentity:(NSString*)pageIdentity;
///获取页面所以
-(NSString*)pageIdentityAtPageIndex:(int)pageIndex;
///删除页面
-(void)deletePageIdentity:(NSString*)pageIdentity;
-(void)deletePageAtPageIndex:(int)pageIndex;
@end
