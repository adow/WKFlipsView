//
//  TestFlipPageView.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-10.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "TestFlipPageView.h"

@implementation TestFlipPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
-(void)prepareForReuse{
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    self.backgroundColor=[UIColor lightTextColor];
}
@end
