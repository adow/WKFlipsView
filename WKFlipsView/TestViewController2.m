//
//  TestViewController2.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-6-4.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "TestViewController2.h"
#include "WKFlip.h"
@interface TestViewController2 ()

@end

@implementation TestViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onButton:(id)sender{
    CGRect frame=self.view.bounds;
    frame.origin.x+=100.0f;
    frame.origin.y+=100.0f;
//    UIImage *snapImage=WKFlip_make_image_for_view(self.view);
//    UIImageView *snapImageView=[[[UIImageView alloc]initWithFrame:frame] autorelease];
//    [self.view addSubview:snapImageView];
//    snapImageView.image=snapImage;

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *snapImage=WKFlip_make_image_for_view(self.view);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImageView *snapImageView=[[[UIImageView alloc]initWithFrame:frame] autorelease];
//            snapImageView.userInteractionEnabled=NO;
//            [self.view addSubview:snapImageView];
//            snapImageView.image=snapImage;
//        });
//    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *snapImage=WKFlip_make_image_for_view(self.view);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *snapImageView=[[[UIImageView alloc]initWithFrame:frame] autorelease];
            snapImageView.userInteractionEnabled=NO;
            [self.view addSubview:snapImageView];
            snapImageView.image=snapImage;
        });
    });
    
}
@end
