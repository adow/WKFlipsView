//
//  TestImagePageView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-1-7.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "TestImagePageView.h"

@implementation TestImagePageView

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
    [_testImageView release];
    [super dealloc];
}
-(void)prepareForReuse{
    if (!_testImageView){
        _testImageView=[[UIImageView alloc]initWithFrame:self.bounds];
        _testImageView.opaque=YES;
        [self addSubview:_testImageView];
    }
    for (UIView* view in self.subviews) {
        if (view!=_testImageView){
            [view removeFromSuperview];
        }
    }
}
@end
