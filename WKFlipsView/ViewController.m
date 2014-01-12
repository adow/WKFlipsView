//

//  ViewController.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "ViewController.h"
#import "WKFlipsView.h"
#import "TestFlipPageView.h"
#import "TestImagePageView.h"
@interface ViewController ()<WKFlipsViewDataSource,WKFlipsViewDelegate>{
    WKFlipsView* _flipsView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (!_flipsView){
        _flipsView=[[WKFlipsView alloc]initWithFrame:self.view.bounds atPageIndex:1];
        _flipsView.backgroundColor=[UIColor darkGrayColor];
        _flipsView.dataSource=self;
        _flipsView.delegate=self;
        //[_flipsView registerClass:[WKFlipPageView class] forPageWithReuseIdentifier:@"page"];
        //[_flipsView registerClass:[TestFlipPageView class] forPageWithReuseIdentifier:@"page"];
        [_flipsView registerClass:[TestImagePageView class] forPageWithReuseIdentifier:@"page"];
        [self.view addSubview:_flipsView];

    }
    [_flipsView reloadPages];

    UIButton* buttonNext=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonNext.frame=CGRectMake(10.0f, 400.0f, 300.0f, 50.0f);
    [buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    [buttonNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonNext.backgroundColor=[UIColor lightGrayColor];
    [buttonNext addTarget:self action:@selector(onButtonNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonNext];

    ///test prepare cache
    //[_flipsView preparePageCachesFromPageIndex:0 toPageIndex:3];
    
    ///test remove cache
//    NSMutableArray* removeArray=[NSMutableArray array];
//    for (int i=0; i<100; i++) {
//        NSString* cacheName=[NSString stringWithFormat:@"cache-%d",i];
//        [removeArray addObject:cacheName];
//    }
//    double delayInSeconds = 10.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"remove page caches");
//        [WKFlipPageView removeCacheImagesByCacheNames:removeArray];
//    });
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_flipsView flipToPageIndex:9 completion:^{
            
        }];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)onButtonNext:(id)sender{
    [_flipsView flipToPageIndex:_flipsView.pageIndex+1];
}
#pragma mark - WKFlipsViewDataSource & WKFlipsViewDelegate
-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView *)flipsView{
    return 23;
}
-(WKFlipPageView*)flipsView:(WKFlipsView *)flipsView pageAtPageIndex:(int)pageIndex{
    static NSString* identity=@"page";
    //WKFlipPageView* pageView=[flipsView dequeueReusablePageWithReuseIdentifier:identity];
//    TestFlipPageView* pageView=(TestFlipPageView*)[flipsView dequeueReusablePageWithReuseIdentifier:identity];
//    pageView.cacheName=[NSString stringWithFormat:@"cache-%d",pageIndex];
//    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame=CGRectMake(10.0f, 100.0f, 300.0f, 50.0f);
//    button.backgroundColor=[UIColor whiteColor];
//    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [button setTitle:[NSString stringWithFormat:@"page-%d",pageIndex] forState:UIControlStateNormal];
//    [pageView addSubview:button];
    TestImagePageView* pageView=(TestImagePageView*)[flipsView dequeueReusablePageWithReuseIdentifier:identity];
    pageView.cacheName=[NSString stringWithFormat:@"image-cache-%d",pageIndex];
    UIImage* image=[UIImage imageNamed:[NSString stringWithFormat:@"%d",pageIndex]];
    pageView.testImageView.image=image;
    return pageView;
}
@end
