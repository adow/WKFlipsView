//
//  _WKFlipsViewCache.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-18.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "WKFlipsViewCache.h"
#import "WKFlip.h"
@implementation WKFlipPageViewCache
@dynamic topImage;
@dynamic bottomImage;
+(id)flipPageCacheWithIdentity:(NSString *)pageIdentity inFlipsViewCache:(WKFlipsViewCache *)flipsViewCache{
    WKFlipPageViewCache* pageCache=[[WKFlipPageViewCache alloc]init];
    pageCache.pageIdentity=pageIdentity;
    pageCache.flipsViewCache=flipsViewCache;
    return [pageCache autorelease];
}
-(void)dealloc{
    [_pageIdentity release];
    [_topImage release];
    [_bottomImage release];
    [super dealloc];
}
#pragma mark - Properties
-(int)pageIndex{
    return (int)[_flipsViewCache.pageIdentityArray indexOfObject:self.pageIdentity];
}
-(NSString*)topImageFilename{
    return [NSString stringWithFormat:@"%@/top.png",self.folder];
}
-(NSString*)bottomImageFilename{
    return [NSString stringWithFormat:@"%@/bottom.png",self.folder];
}
-(NSString*)folder{
    return [NSString stringWithFormat:@"%@/%@",self.flipsViewCache.folder,self.pageIdentity];
}
-(UIImage*)topImage{
    if (!_topImage){
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.topImageFilename]){
            _topImage=[[UIImage alloc] initWithContentsOfFile:self.topImageFilename];
        }
    }
    return _topImage;
}
-(void)setTopImage:(UIImage *)topImage{
    [_topImage release];
    [topImage retain];
    _topImage=topImage;
    BOOL is_folder=NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.folder isDirectory:&is_folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.folder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSData* data=UIImagePNGRepresentation(topImage);
//    NSLog(@"%@",self.topImageFilename);
    [data writeToFile:self.topImageFilename atomically:YES];
}
-(UIImage*)bottomImage{
    if (!_bottomImage){
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.bottomImageFilename]){
            _bottomImage=[[UIImage alloc]initWithContentsOfFile:self.bottomImageFilename];
        }
    }
    return _bottomImage;
}
-(void)setBottomImage:(UIImage *)bottomImage{
    [_bottomImage release];
    [bottomImage retain];
    _bottomImage=bottomImage;
    BOOL is_folder=NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.folder isDirectory:&is_folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.folder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSData* data=UIImagePNGRepresentation(bottomImage);
//    NSLog(@"%@",self.bottomImageFilename);
    [data writeToFile:self.bottomImageFilename atomically:YES];
}
-(void)removeCacheImage{
    [[NSFileManager defaultManager] removeItemAtPath:self.topImageFilename error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:self.bottomImageFilename error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:self.folder error:NULL];
    [_topImage release];
    _topImage=nil;
    [_bottomImage release];
    _bottomImage=nil;
}
@end
@implementation WKFlipsViewCache
-(id)initWithIdentity:(NSString *)identity{
    self=[super init];
    if (self){
        self.identity=identity;
        _pageIdentityArray=[[NSMutableArray alloc]init];
        [self read];
    }
    return self;
}
-(void)dealloc{
    [_pageIdentityArray release];
    [_identity release];
    [super dealloc];
}
#pragma mark - file
-(NSString*)folder{
    return [NSString stringWithFormat:@"%@/%@.cache",WKFLIPS_PATH_DOCUMENT,self.identity];
}
-(NSString*)indexFilename{
    return [NSString stringWithFormat:@"%@/index",self.folder];
}
-(void)write{
    NSMutableString* string=[NSMutableString string];
    for (NSString* pageIdentity in self.pageIdentityArray) {
        if ([pageIdentity isEqualToString:@""]){
            continue;
        }
        [string appendFormat:@"%@\n",pageIdentity];
    }
    NSData* data=[string dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:self.indexFilename atomically:YES];
}
-(void)read{
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.folder isDirectory:&isDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.folder withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.indexFilename]){
        return;
    }
    NSString* string=[NSString stringWithContentsOfFile:self.indexFilename encoding:NSUTF8StringEncoding error:NULL];
    NSArray* array=[string componentsSeparatedByString:@"\n"];
    [self.pageIdentityArray removeAllObjects];
    [self.pageIdentityArray addObjectsFromArray:array];
    for (NSString* identity in self.pageIdentityArray) {
        if (!identity || [identity isEqualToString:@""]){
            [self.pageIdentityArray removeObject:identity];
        }
    }
}
#pragma mark - pageCache
-(WKFlipPageViewCache*)pageCacheAtPageIndex:(int)pageIndex{
    if (pageIndex<0 || pageIndex>=self.pageIdentityArray.count)
        return nil;
    NSString* pageIdentity=self.pageIdentityArray[pageIndex];
    WKFlipPageViewCache* pageCache=[WKFlipPageViewCache flipPageCacheWithIdentity:pageIdentity inFlipsViewCache:self];
    return pageCache;
}
-(WKFlipPageViewCache*)pageCacheForPageIdentity:(NSString *)pageIdentity{
    WKFlipPageViewCache* pageCache=[WKFlipPageViewCache flipPageCacheWithIdentity:pageIdentity inFlipsViewCache:self];
    return pageCache;
}
-(void)removeAtPageIndex:(int)pageIndex{
    WKFlipPageViewCache* pageCache=[self pageCacheAtPageIndex:pageIndex];
    ///delete uuid
    [self.pageIdentityArray removeObjectAtIndex:pageIndex];
    [self write];
    ///delete cache
    [pageCache removeCacheImage];
}
-(void)removeCacheImageAtPageIndex:(int)pageIndex{
    WKFlipPageViewCache* pageCache=[self pageCacheAtPageIndex:pageIndex];
    [pageCache removeCacheImage];
}
-(WKFlipPageViewCache*)insertAtPageIndex:(int)pageIndex{
    NSString* uuid=[[NSUUID UUID] UUIDString];
    [self.pageIdentityArray insertObject:uuid atIndex:pageIndex];
    [self write];
    return [self pageCacheAtPageIndex:pageIndex];
}
-(WKFlipPageViewCache*)addPage{
    NSString* uuid=[[NSUUID UUID] UUIDString];
    [self.pageIdentityArray addObject:uuid];
    [self write];
    return [self pageCacheForPageIdentity:uuid];
}
@end
