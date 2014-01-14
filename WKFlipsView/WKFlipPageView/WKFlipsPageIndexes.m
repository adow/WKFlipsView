//
//  WKFlipsIndexes.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-13.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "WKFlipsPageIndexes.h"

@implementation WKFlipsPageIndexes
+(id)createPageIndexesFile:(NSString *)filename{
    WKFlipsPageIndexes* indexes=[[[WKFlipsPageIndexes alloc]init] autorelease];
    indexes.filename=filename;
    [indexes write];
    return indexes;
}
+(id)loadPageIndexesFile:(NSString *)filename{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]){
        return nil;
    }
    WKFlipsPageIndexes* indexes=[[[WKFlipsPageIndexes alloc]init] autorelease];
    indexes.filename=filename;
    NSData* data=[NSData dataWithContentsOfFile:filename];
    NSString* string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [indexes.indexList addObjectsFromArray:[string componentsSeparatedByString:@"\n"]];
    return indexes;
}
+(BOOL)pageIndexesFileExisted:(NSString *)filename{
    return [[NSFileManager defaultManager] fileExistsAtPath:filename];
}
-(id)init{
    self=[super init];
    if (self){
        _indexList=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)dealloc{
    [_indexList release];
    [super dealloc];
}
-(void)write{
    NSMutableString* string=[NSMutableString string];
    for (NSString* index in self.indexList) {
        [string appendString:[NSString stringWithFormat:@"%@\n",index]];
    }
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:self.filename atomically:YES];
}
-(void)addPageIndex:(NSString *)index{
    [self.indexList addObject:index];
    [self write];
}
-(void)insertPageIndex:(NSString *)index atPos:(int)pos{
    [self.indexList insertObject:index atIndex:pos];
    [self write];
}
-(int)posForPageIndex:(NSString *)index{
    return [self.indexList indexOfObject:index];
}
-(NSString*)indexAtPos:(int)pos{
    return self.indexList[pos];
}
-(void)deletePageIndex:(NSString *)index{
    [self.indexList removeObject:index];
    [self write];
}
@end
