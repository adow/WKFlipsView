//

//  ViewController.m
//  WKFlipsView
//
//  Created by 秦 道平 on 13-12-9.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "ViewController.h"
#import "WKFlipsView.h"
#import "_WKFlipsViewCache.h"
#import "TestFlipPageView.h"
#import "TestImagePageView.h"
@interface ViewController ()<WKFlipsViewDataSource,WKFlipsViewDelegate>{
    WKFlipsView* _flipsView;
    NSMutableArray* _images;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self testPrepareImages];
    
    if (!_flipsView){
        _flipsView=[[WKFlipsView alloc]initWithFrame:self.view.bounds atPageIndex:1 withCacheIdentity:@"test"];
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
-(void)dealloc{
    [_images release];
    [super dealloc];
}
-(IBAction)onButtonNext:(id)sender{
    [_flipsView flipToPageIndex:_flipsView.pageIndex+1];
}
-(IBAction)onButtonDelete:(id)sender{
    [_flipsView deleteCurrentPage];
}
#pragma mark - WKFlipsViewDataSource & WKFlipsViewDelegate
-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView *)flipsView{
    return _images.count;
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
    //pageView.cacheName=[NSString stringWithFormat:@"image-cache-%d",pageIndex];
//    pageView.cacheName=[self flipsView:flipsView keyAtPageIndex:pageIndex];
    //UIImage* image=_images[pageIndex];;
    UIImage* image=[UIImage imageNamed:_images[pageIndex]];
    pageView.testImageView.image=image;
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10.0f, 30.0f+20*pageIndex, 300.0f, 50.0f);
    [button setTitle:@"delete" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    button.backgroundColor=[UIColor whiteColor];
    [button addTarget:self action:@selector(onButtonDelete:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:button];
    return pageView;

}
-(void)flipwView:(WKFlipsView *)flipsView willDeletePageAtPageIndex:(int)pageIndex{
    [_images removeObjectAtIndex:pageIndex];
    [self testWriteImages];
}
#pragma mark - Test
-(void)testPrepareImages{
    if (!_images){
        _images=[[NSMutableArray alloc]init];
    }
    [_images removeAllObjects];
    NSString* filename=[NSString stringWithFormat:@"%@/test.images",WK_PATH_DOCUMENT];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]){
        NSLog(@"load test images");
        NSString* string=[NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        NSArray* array=[string componentsSeparatedByString:@"\n"];
        [_images addObjectsFromArray:array];
        NSMutableArray* delete_array=[NSMutableArray array];
        for (NSString* one_image in _images) {
            if (!one_image || [one_image isEqualToString:@""]){
                [delete_array addObject:one_image];
            }
        }
        [_images removeObjectsInArray:delete_array];
    }
    else{
        NSLog(@"new images");
        for (int a=0; a<23; a++) {
            [_images addObject:[NSString stringWithFormat:@"%d.png",a]];
        }
        [self testWriteImages];
    }
}
-(void)testWriteImages{
    NSString* filename=[NSString stringWithFormat:@"%@/test.images",WK_PATH_DOCUMENT];
    NSMutableString* string=[NSMutableString string];
    for (NSString* one_image in _images) {
        if ([one_image isEqualToString:@""]){
            continue;
        }
        [string appendFormat:@"%@\n",one_image];
    }
    NSData* data=[string dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:filename atomically:YES];
    NSLog(@"writeImages:%@",filename);
}
@end
