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
        _flipsView=[[WKFlipsView alloc]initWithFrame:self.view.bounds];
        _flipsView.backgroundColor=[UIColor darkGrayColor];
        _flipsView.dataSource=self;
        _flipsView.delegate=self;
        //[_flipsView registerClass:[WKFlipPageView class] forPageWithReuseIdentifier:@"page"];
        [_flipsView registerClass:[TestFlipPageView class] forPageWithReuseIdentifier:@"page"];
        [self.view addSubview:_flipsView];

    }
    [_flipsView showAtPageIndex:0];

    UIButton* buttonNext=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonNext.frame=CGRectMake(10.0f, 400.0f, 300.0f, 50.0f);
    [buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    [buttonNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonNext.backgroundColor=[UIColor lightGrayColor];
    [buttonNext addTarget:self action:@selector(onButtonNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonNext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)onButtonNext:(id)sender{
    [_flipsView showAtPageIndex:_flipsView.pageIndex+1];
}
#pragma mark - WKFlipsViewDataSource & WKFlipsViewDelegate
-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView *)flipsView{
    return 3;
}
-(WKFlipPageView*)flipsView:(WKFlipsView *)flipsView pageAtPageIndex:(int)pageIndex{
    static NSString* identity=@"page";
    //WKFlipPageView* pageView=[flipsView dequeueReusablePageWithReuseIdentifier:identity];
    TestFlipPageView* pageView=(TestFlipPageView*)[flipsView dequeueReusablePageWithReuseIdentifier:identity];
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10.0f, 100.0f, 300.0f, 50.0f);
    button.backgroundColor=[UIColor whiteColor];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"page-%d",pageIndex] forState:UIControlStateNormal];
    [pageView addSubview:button];
    return pageView;
}
@end
