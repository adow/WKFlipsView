//
//  WKFlipPageView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipPageView.h"

@interface WKFlipPageView(){
    
}
///上半部分图片
@property (nonatomic,readonly) NSString* cacheNameHTop;
///下半部分图片
@property (nonatomic,readonly) NSString* cacheNameHBottom;
///上半部分图片的文件名
@property (nonatomic,readonly) NSString* filenameForCacheHTop;
///下半部分的图片文件名
@property (nonatomic,readonly) NSString* filenameForCacheHBottom;
@end
@implementation WKFlipPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)init{
    self=[super init];
    if (self){
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc{
    [_cacheName release];
    [super dealloc];
}
-(void)prepareForReuse{
    
}

#pragma mark - SnapShot
-(UIImage*)makeSnapShotImage{
    return WKFlip_make_image_for_view(self);
}
-(NSArray*)makeHSnapShotImages{
    return WKFlip_make_hsplit_images_for_view(self);
}
#pragma mark - Cache
-(NSString*)cacheNameHTop{
    return [NSString stringWithFormat:@"%@-top",self.cacheName];
}
-(NSString*)cacheNameHBottom{
    return [NSString stringWithFormat:@"%@-bottom",self.cacheName];
}
-(NSString*)filenameForCacheHTop{
    return [NSString stringWithFormat:@"%@/%@.png",WK_PATH_DOCUMENT,self.cacheNameHTop];
}
-(NSString*)filenameForCacheHBottom{
    return [NSString stringWithFormat:@"%@/%@.png",WK_PATH_DOCUMENT,self.cacheNameHBottom];
}
-(UIImage*)cacheImageHTop{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filenameForCacheHTop]){
        NSLog(@"cacheImageHTop exists:%@",self.filenameForCacheHTop);
        UIImage* image=[UIImage imageWithContentsOfFile:self.filenameForCacheHTop];
        return image;
    }
    else{
        NSLog(@"cacheImageHTop new:%@",self.filenameForCacheHTop);
        NSLog(@"cacheImageHBottom new:%@",self.filenameForCacheHBottom);
        NSArray* images=[self makeHSnapShotImages];
        UIImage* imageHTop=images[0];
        UIImage* imageHBottom=images[1];
        NSData* dataHTop=UIImageJPEGRepresentation(imageHTop, 1.0f);
        [dataHTop writeToFile:self.filenameForCacheHTop atomically:YES];
        NSData* dataHBottom=UIImageJPEGRepresentation(imageHBottom, 1.0f);
        [dataHBottom writeToFile:self.filenameForCacheHBottom atomically:YES];
        return imageHTop;
    }
}
-(UIImage*)cacheImageHBottom{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filenameForCacheHBottom]){
        NSLog(@"cacheImageHBottom exists:%@",self.filenameForCacheHBottom);
        UIImage* image=[UIImage imageWithContentsOfFile:self.filenameForCacheHBottom];
        return image;
    }
    else{
        NSLog(@"cacheImageHTop new:%@",self.filenameForCacheHTop);
        NSLog(@"cacheImageHBottom new:%@",self.filenameForCacheHBottom);
        NSArray* images=[self makeHSnapShotImages];
        UIImage* imageHTop=images[0];
        UIImage* imageHBottom=images[1];
        NSData* dataHTop=UIImagePNGRepresentation(imageHTop);
        [dataHTop writeToFile:self.filenameForCacheHTop atomically:YES];
        NSData* dataHBottom=UIImagePNGRepresentation(imageHBottom);
        [dataHBottom writeToFile:self.filenameForCacheHBottom atomically:YES];
        return imageHBottom;
    }
}
-(void)prepareCacheImage{
    [self cacheImageHTop];
    [self cacheImageHBottom];
}
+(void)removeCacheImagesByCacheNames:(NSArray *)cacheNames{
    for (NSString* cacheName in cacheNames) {
        NSString *cacheNameHTop=[NSString stringWithFormat:@"%@-top",cacheName];
        NSString *cacheNameHBottom=[NSString stringWithFormat:@"%@-bottom",cacheName];
        NSString* filenameForCacheHTop=[NSString stringWithFormat:@"%@/%@.png",WK_PATH_DOCUMENT,cacheNameHTop];
        NSString* filenameForCacheHBottom=[NSString stringWithFormat:@"%@/%@.png",WK_PATH_DOCUMENT,cacheNameHBottom];
        [[NSFileManager defaultManager] removeItemAtPath:filenameForCacheHTop error:NULL];
        [[NSFileManager defaultManager] removeItemAtPath:filenameForCacheHBottom error:NULL];
    }
}
@end
