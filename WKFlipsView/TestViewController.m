//
//  TestViewController.m
//  WKFlipsView
//
//  Created by 秦 道平 on 14-5-25.
//  Copyright (c) 2014年 秦 道平. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController (){
    CGFloat _dragging_last_translation_y;
}

@end

@implementation TestViewController

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
    self.view.backgroundColor=[UIColor darkGrayColor];
    if(!_flipLayer){
        _flipLayer=[[WKFlipsLayer alloc]initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height/2,
                                                                 self.view.bounds.size.width,
                                                                 self.view.bounds.size.height/2)];
        [self.view.layer addSublayer:_flipLayer];
        [_flipLayer drawWords:@"1 front layer" onPosition:0];
        [_flipLayer drawWords:@"1 back layer" onPosition:1];
        _flipLayer.frontLayer.contents=(id)[UIImage imageNamed:@"1.png"].CGImage;
        _flipLayer.backLayer.contents=(id)[UIImage imageNamed:@"2.png"].CGImage;
        _flipLayer.rotateDegree=1.0f;
        
    }
    
    if (!_flipLayer2){
        _flipLayer2=[[WKFlipsLayer alloc]initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height/2,
                                                                 self.view.bounds.size.width,
                                                                 self.view.bounds.size.height/2)];
        [self.view.layer addSublayer:_flipLayer2];
        [_flipLayer2 drawWords:@"2 front layer" onPosition:0];
        [_flipLayer2 drawWords:@"2 back layer" onPosition:1];
        _flipLayer2.frontLayer.contents=(id)[UIImage imageNamed:@"3.png"].CGImage;
        _flipLayer2.backLayer.contents=(id)[UIImage imageNamed:@"4.png"].CGImage;
        _flipLayer2.rotateDegree=0.0f;
    }
    
    UIButton* animationButton=[UIButton buttonWithType:UIButtonTypeCustom];
    animationButton.frame=CGRectMake(0.0, 60.0, 320.0f, 50.0f);
    animationButton.backgroundColor=[UIColor whiteColor];
    [animationButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [animationButton setTitle:@"animation" forState:UIControlStateNormal];
    [animationButton addTarget:self action:@selector(onAnimationButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animationButton];

    UIPanGestureRecognizer* panGeture=[[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_flippingPanGesture:)] autorelease];
    [self.view addGestureRecognizer:panGeture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [_flipLayer release];
    [super dealloc];
}

#pragma mark - Action
-(IBAction)onAnimationButton:(id)sender{
//    _flipLayer.rotateDegree=0.0f;
    [_flipLayer setRotateDegree:181.0f duration:3.0f afterDelay:0.0f completion:^{
        NSLog(@"completed");
    }];
    [_flipLayer2 setRotateDegree:180.0f duration:3.0f afterDelay:0.3f completion:^{
        NSLog(@"completed 2");
    }];
}
#pragma mark - touches
-(void)_flippingPanGesture:(UIPanGestureRecognizer*)recognizer{
    CGPoint translation=[recognizer translationInView:self.view];
    if (recognizer.state==UIGestureRecognizerStateBegan){
        [self dragBeganWithTranslation:translation];
    }
    else if (recognizer.state==UIGestureRecognizerStateCancelled|| recognizer.state==UIGestureRecognizerStateEnded){
        [self dragEndedWithTranslation:translation];
    }
    else if (recognizer.state==UIGestureRecognizerStateChanged){
        [self draggingWithTranslation:translation];
    }
}

#pragma mark - Drag
-(void)dragBeganWithTranslation:(CGPoint)translation{
    [_flipLayer cancelDragAnimation];
    _dragging_last_translation_y=translation.y;
    //[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
}
-(void)dragEndedWithTranslation:(CGPoint)translation{
    NSLog(@"%f",_flipLayer.rotateDegree);
    [_flipLayer removeShadow];
    if (_flipLayer.rotateDegree>=90.0f){
        [_flipLayer setRotateDegree:180.0f duration:1.0f afterDelay:0.0f completion:^{
            
        }];
    }
    else{
        [_flipLayer setRotateDegree:0.0f duration:1.0f afterDelay:0.0f completion:^{
            
        }];
    }
}
-(void)draggingWithTranslation:(CGPoint)translation{
    CGFloat rotateDegree=_flipLayer.rotateDegree-(translation.y-_dragging_last_translation_y)*0.5f;
    rotateDegree=fmaxf(rotateDegree, 1.0f);
    rotateDegree=fminf(rotateDegree, 180.0f);
    _flipLayer.rotateDegree=rotateDegree;
    _dragging_last_translation_y=translation.y;
    [_flipLayer showShadowOpacity:rotateDegree/180.0f];
    //NSLog(@"dragging:%f",translation.y);
    
}
@end
