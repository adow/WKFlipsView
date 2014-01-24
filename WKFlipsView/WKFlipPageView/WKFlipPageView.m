//
//  WKFlipPageView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKFlipPageView.h"
#import "WKFlip.h"
@interface WKFlipPageView(){
    
}
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
@end
