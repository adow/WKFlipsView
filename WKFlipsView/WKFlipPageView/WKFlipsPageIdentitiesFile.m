//
//  WKFlipsIndexes.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-13.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "WKFlipsPageIdentitiesFile.h"

@implementation WKFlipsPageIdentitiesFile
+(id)createPageIdentitiesFile:(NSString *)filename{
    WKFlipsPageIdentitiesFile* indexes=[[[WKFlipsPageIdentitiesFile alloc]init] autorelease];
    indexes.filename=filename;
    [indexes write];
    return indexes;
}
+(id)loadPageIdentitiesFile:(NSString *)filename{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]){
        return nil;
    }
    WKFlipsPageIdentitiesFile* indexes=[[[WKFlipsPageIdentitiesFile alloc]init] autorelease];
    indexes.filename=filename;
    NSData* data=[NSData dataWithContentsOfFile:filename];
    NSString* string=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray* indexList=[string componentsSeparatedByString:@"\n"];
    [indexes.nameList addObjectsFromArray:indexList];
    return indexes;
}
+(BOOL)pageIdentitiesFileExisted:(NSString *)filename{
    return [[NSFileManager defaultManager] fileExistsAtPath:filename];
}
-(id)init{
    self=[super init];
    if (self){
        _nameList=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)dealloc{
    [_nameList release];
    [super dealloc];
}
-(void)write{
    NSMutableString* string=[NSMutableString string];
    for (NSString* index in self.nameList) {
        [string appendString:[NSString stringWithFormat:@"%@\n",index]];
    }
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:self.filename atomically:YES];
}
-(void)addPageIdentity:(NSString *)pageIdentity{
    [self.nameList addObject:pageIdentity];
    [self write];
}
-(void)insertPageIdentity:(NSString*)pageIdentity atPageIndex:(int)pageIndex{
    [self.nameList insertObject:pageIdentity atIndex:pageIndex];
    [self write];
}
-(int)pageIndexForPageIdentity:(NSString*)pageIdentity{
    return [self.nameList indexOfObject:pageIdentity];
}
-(NSString*)pageIdentityAtPageIndex:(int)pageIndex{
    return self.nameList[pageIndex];
}
-(void)deletePageIdentity:(NSString *)pageIdentity{
    [self.nameList removeObject:pageIdentity];
    [self write];
}
-(void)deletePageAtPageIndex:(int)pageIndex{
    [self.nameList removeObjectAtIndex:pageIndex];
    [self write];
}
@end
