# WKFlipsView

A Flipboard-like paging view.

实现类似Flipboard中那样的翻页效果，包括: 

* 动画连续翻页到第几页;
* 手动拖动翻页;



[实现效果的视频链接](http://v.youku.com/v_show/id_XNjY5NTQ3OTU2.html)


![image](http://farm6.staticflickr.com/5536/12322833674_14c5a1cb08_c.jpg)


![image](http://farm4.staticflickr.com/3748/12322833224_c89ce973f9_c.jpg)


## 使用

* 包含 

```
#import "WKFlipsView.h"
```
* UIViewController中要继承接口 `WKFlipsViewDataSource` 和 `WKFlipsViewDelegate`；
* 每个页面都是WKFlipPageView的页面，通过实现子类来定义自己的页面实现。
* 创建WKFlipsView；


每一个具体的页面在dataSource所对应的接口中实现，需要指定具体实现的页面定义。
registClass用来保存页面的类型，页面应该是WKFlipPageView的子类。所以首先定义页面实现类。由于每个页面是重用的，所以应该实现 `-(void)prepareForReuse` 方法，用来处理在重用前一些UI的清理。重复使用WKFlipPageView的好处在于可以减少创建UIView所花的时间，在页面很多的时候，这个尤为明显。

TestImagePageView.h， 实现WKFlipPageView 的子类


	#import "WKFlipPageView.h"
	
	@interface TestImagePageView : WKFlipPageView{
	    
	}
	@property (nonatomic,retain) UIImageView* testImageView;
	@end


TestImagePageView.m


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
	        [self addSubview:_testImageView];
	    }
	    for (UIView* view in self.subviews) {
	        if (view!=_testImageView){
	            [view removeFromSuperview];
	        }
	    }
	}
	@end

使用已经定义好的页面来创建WKFlipsView,创建时要提供一个cacheIdentity用来标识缓存位置，只要是一个字符串就可以了。需要指定`dataSource` 和 `delegate`，用来实现数据提供和操作委托。



	if (!_flipsView){
        _flipsView=[[WKFlipsView alloc]initWithFrame:self.view.bounds atPageIndex:1 withCacheIdentity:@"test"];
        _flipsView.backgroundColor=[UIColor darkGrayColor];
        _flipsView.dataSource=self;
        _flipsView.delegate=self;
        [_flipsView registerClass:[TestImagePageView class] forPageWithReuseIdentifier:@"page"];
        [self.view addSubview:_flipsView];

    }
    [_flipsView reloadPages];
	    

* 实现WKFlipsViewDataSource的方法,提供数据准备。


		///获取页面数量
		-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView *)flipsView{
		    return _images.count;
		}
		
		///实现每一页的具体内容，参数isThumbCopy指定了这个方法是否使用来创建缓存贴图时使用的
		-(WKFlipPageView*)flipsView:(WKFlipsView *)flipsView pageAtPageIndex:(int)pageIndex isThumbCopy:(bool)isThumbCopy{
		    static NSString* identity=@"page";
		    ///获取重用的WKFlipPageView
		    TestImagePageView* pageView=(TestImagePageView*)[flipsView dequeueReusablePageWithReuseIdentifier:identity isThumbCopy:isThumbCopy];
		    ///为这个page设置对应页面的内容
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


其中的的_images就是要使用的数据, 应该在之前就完成数据准备了。（测试中是载入一些和屏幕一样大小的图片）


		///从一个文件中载入一堆图片
		-(void)testPrepareImages{
		    if (!_images){
		        _images=[[NSMutableArray alloc]init];
		    }
		    [_images removeAllObjects];
		    NSString* filename=[NSString stringWithFormat:@"%@/test.images",WKFLIPS_PATH_DOCUMENT];
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



* 注意如果要在载入时就完成自动连续翻页，需要在主线程中延时一点


		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		    [_flipsView flipToPageIndex:9 completion:^{
		        
		    }];
		});

* 翻页到指定的页面;

		[_flipsView flipToPageIndex:9 completion:^{
			        
		}];

* 在现在的位置添加插入一个页面;	

	要完成delegate中的方法，添加数据
	
		-(void)flipsView:(WKFlipsView *)flipsView willInsertPageAtPageIndex:(int)pageIndex{
		    [_images insertObject:@"a.png" atIndex:pageIndex];
		    [self testWriteImages];
		}	

* 更新当前这个页面;

	要完成delegate中的方法，更新数据
	
		-(void)flipsView:(WKFlipsView *)flipsView willUpdatePageAtPageIndex:(int)pageIndex{
		    _images[pageIndex]=@"b.png";
		    [self testWriteImages];
		}


* 删除当前这个页面;

	要完成delegate中的方法，删除数据
	
		-(void)flipwView:(WKFlipsView *)flipsView willDeletePageAtPageIndex:(int)pageIndex{
		    [_images removeObjectAtIndex:pageIndex];
		    [self testWriteImages];
		}

* 插入，更新页面时，dataSource中的 `-(NSInteger)numberOfPagesForFlipsView:(WKFlipsView *)flipsView` 和 `-(WKFlipPageView*)flipsView:(WKFlipsView *)flipsView pageAtPageIndex:(int)pageIndex` 会被调用来创建对应的页面，其他相关的贴图也会更新。


## 实现原理

要让一个UIView进行翻转是比较容易的，通过修改CALayer的transform就可以实现。但是要让一个UIView的上半部分进行翻转，下半部分还停着却是不可能了。

我唯一能想到的办法就是为这个UIView创建出两个图片，也就是一个UIView创建出自身的截图，然后当中切成两半，上面一部分和下面一部分，分别是两张图片，然后放在两个单独的CALayer中，翻转时只翻转其中的一个CALayer。

所以，我们能看到的翻页效果其实只是一堆图片组成的很多CALayer在进行翻动而已，他们并不是真正的UIView。

### 视图以及图层结构

```
- UIView 
	- WKFlipsView
		- UIView (currentPageView) #下层是真正显示的内容
			- WKFlipPageView (currentFlipPageView)
		- WKFlipsLayerView (flippingLayersView) #上层是用来实现翻页的效果，翻页结束后隐藏
			- CALayer (layer)
				- WKFlipsLayer 
					- frontLayer
						- CALayer (_shaodwOnFrontLayer)
					- backLayer				
						- CALayer (_shadowOnBackLayer)
				- WKFlipsLayer
					- frontLayer
						- CALayer (_shaodwOnFrontLayer)
					- backLayer				
						- CALayer (_shadowOnBackLayer)
				- WKFlipsLayer
					- frontLayer
						- CALayer (_shaodwOnFrontLayer)
					- backLayer				
						- CALayer (_shadowOnBackLayer)	
```

从上面的结构可以看出，WKFlipsView其实就是两层UIView，下面一层是真正的内容页面的UIView，在页面翻页后，显示新的页面内容时，其中的WKFlipPageView将会替换成新的内容。

在这上面是一层叫做flippingLayersView的WKFlipsLyaerView，他其中包含了所有需要的翻页时的页面图层，翻页的效果其实就是这次图层的翻转。也就是说，在一开始的时候，有多少个页面，就知道了有多少个需要进行翻页的图层了（应该是+1）。flippingLayersView中的WKFlipsLayer进行连续翻转动画，或者在手势拖动时进行翻转的效果，这些都在flippingLayersView中完成。当翻转动画完成时（手势拖放后也会有一个动画进行后续的翻页效果），这个flipingLayerView会隐藏掉，同时更新currentPageView中的实际显示的内容页面。

### 关于翻转角度

每个WKFlipsLayer包含了**两面的贴图**，而背面的贴图是一开始就翻转过了的。当图层翻转完后，背面的贴图就显示出来了。

翻转的效果只需要通过修改CALayer的transform属性就可以实现了。我们已经为每个页面创建了上下两部分的截图，并放在两个CALayer中，然后对图层进行翻转设置。在开始的时候（也就是图层全部创建的时候），所有的图层都在屏幕的下半部分。这时他们的角度都是0°，当进行翻转的时候，角度逐渐增大，到180°的时候，就是完成这个图层从下翻转到上的过程了。由于我们的图层是双面的，翻转到上面的时候，我们就能看到背面的内容了。

这样看好像很简单，如果是很多页面连续翻页只要按照顺序对这些图层依次翻转就可以了。但是实际看下来却有点问题。当第一个翻转到上面的时候没问题，但是当第二个翻转到180°并且停住时，你会发现又一闪出现了下面那一层（第一个翻转图层）的内容。这是什么原因呢？我们都知道很多图层依次添加到一个父图层的时候是有顺序的，这会影响谁遮挡谁的效果。当所有的图层在开始被建立时，他们都位于屏幕的下半部分，新的图层会被添加到下面，当页面翻转到最上面时，原来图层一挡住了图层二的顺序却应该变成图层二挡住图层一。但是绘图时他并不知道这两个的图层因为翻转而更换了遮挡关系，所以又会把图层一给显示出来了。解决的办法就是为每个页面设置不同的角度，当所有的图层的翻转角度不同就可以了。所以当一个图层翻转到屏幕上方时，如果后面还有一个图层翻转过来，那他可以设置一个超过180的角度，这样就不会出现了。

![image](http://farm4.staticflickr.com/3753/12167410256_903d0111bc_z.jpg)


```
上半部分
- WKFlipsLayer (layer on top, 181°)
- WKFlipsLayer (layer on top, 182°)
- WKFlipsLyaer (layer on top, 180°，可见)
--- 
下半部分
- WKFlipsLayer (layer on bottom, 0°,可见)
- WKFlipsLayer (layer on bottom, -1°)
- WKFlipsLayer (layer on bottom, -2°)
```

由上面的结构能看出来，通过设置每个图层的不同角度来控制上下部分那两个图层是可见的(0°和180°)。


### 贴图缓存

由于所有的翻页都是图层，而图层上面是每个页面对应的图片，所以需要为这些页面来创建截图。为UIView来创建一个截图是比较方便的，但是无论用什么方法，UIView的截图效率都不高（主要是因为renderInContext的效率不高），而且他只能在主线程上进行。所以，当我们有很多页面时，创建截图就需要花费大量的时间，并且会让主线程租塞。

我的优化方法是将这些UIView的截图都保存下来，这样避免反复创建截图。当需要更新的时候，对应的图片文件会被删除。所以在WKFlipsView创建的时候，是需要一个标识缓存的参数的`withCacheIdentity`用来标识这一组页面的缓存位置。

当WKFlipsView创建的时候，或者有页面进行插入/修改/删除的时候，现有的翻页图层会被全部重建(WKFlipsLayerView下面的WKFlipsLayer会被重建)，建立图层的同时，会为他们进行贴图，如果对应页面的贴图已经有缓存文件的话，他会直接从文件中载入的，如果没有的话，会为这个页面来创建截图并缓存。所以，我们能看出来，重建图层的时候可能会消耗大量时间，主要是由于贴图的时间，如果一开始没有任何截图缓存的时候，这个过程的时间是更长的。我能想到的办法就是在贴图过程中设置一个时间阀值，超过这个时间就会停止贴图了，这时你就会看到一些空白的图层页面在翻页。

		///在允许的时间范围内为尽可能多的layer贴图,如果maxSeconds是0那就忽略时间
		///应该从当前页面两边优先贴图
		-(void)_pasteImagesToLayersForTargetPageIndex:(int)targetPageIndex inSeconds:(double)maxSeconds{
		    double startTime=CFAbsoluteTimeGetCurrent();
		    double duration=0;
		    int totalPages=(int)[self.flipsView.dataSource numberOfPagesForFlipsView:self.flipsView];
		    ///检查缓存索引键是否完全
		    for (int a=0; a<totalPages; a++) {
		        if (![self.flipsView.cache pageCacheAtPageIndex:a]){
		            [self.flipsView.cache addPage];
		        }
		    }
		    ///对贴图顺序进行排序
		    NSArray* sortedPages=[self _sortedPagesForTargetPageIndex:targetPageIndex];
		    ///统计贴图的页面数和跳过的页面数(WKFlipsLayer的正反面)
		    int numbersPastes=0,numbersSkips=0;
		    for(NSNumber* pageNumber in sortedPages) {
		        int pageIndex=[pageNumber intValue];
		        duration=CFAbsoluteTimeGetCurrent()-startTime;
		        ///超出设定时间了，跳过贴图
		        if (maxSeconds>0 && duration>=maxSeconds){
		            //NSLog(@"duration:%f",duration);
		            //break;
		            numbersSkips+=2;
		            continue;
		        }
		        int layerIndexForTop=totalPages-pageIndex;
		        int layerIndexForBottom=layerIndexForTop-1;
		        WKFlipsLayer* layerForTop=self.layer.sublayers[layerIndexForTop];
		        WKFlipsLayer* layerForBottom=self.layer.sublayers[layerIndexForBottom];
		        ///如果已经有贴图了就跳过
		        if (layerForTop.backLayer.contents && layerForBottom.frontLayer.contents){
		            numbersSkips+=2;
		            continue;
		        }
		        WKFlipPageView* page=[self.flipsView.dataSource flipsView:self.flipsView pageAtPageIndex:pageIndex];
		        WKFlipPageViewCache* pageCache=[self.flipsView.cache pageCacheAtPageIndex:pageIndex];
		        NSArray* images=nil;
		        if (!layerForTop.backLayer.contents){
		            ///没有缓存
		            if (!pageCache.topImage){
		                images=[page makeHSnapShotImages];
		                [pageCache setTopImage:images[0]];
		            }
		            layerForTop.backLayer.contents=(id)pageCache.topImage.CGImage;
		            numbersPastes+=1;
		            //NSLog(@"new image pasted");
		        }
		        else{
		            numbersSkips+=1;
		        }
		        if (!layerForBottom.frontLayer.contents){
		            if (!pageCache.bottomImage){
		                ///如果已经有截图了就不要重新创建了
		                if (!images){
		                    images=[page makeHSnapShotImages];
		                }
		                [pageCache setBottomImage:images[1]];
		            }
		            layerForBottom.frontLayer.contents=(id)pageCache.bottomImage.CGImage;
		            numbersPastes+=1;
		            //NSLog(@"new images pasted");
		        }
		        else{
		            numbersSkips+=1;
		        }
		        
		    }
		    duration=CFAbsoluteTimeGetCurrent()-startTime;
		    NSLog(@"pastes:%d,skips:%d,duration:%f",numbersPastes,numbersSkips,duration);
		}
		
上面就是整个贴图的过程，为了减少看到空白图层的机会，这最大程度上取决于调用这个贴图过程的时机。举例来说，在WKFlipsView创建时，我们可以给1秒时间来贴图，也许这时用户看到一个载入的进度条不会太反感。在插入/更新/删除页面后，我们可以有1-2秒的时间来重新贴图，因为这会用户也会有一点等待的时间。比如在翻页动画或者我手动拖放页面完成的时候，也可以有1秒的时间来进行一些贴图，因为用户在翻页之后会有一个惯性，总要看一下新的页面吧。所以，这些贴图就是这样被一点一点创造出来的。另一个可以优化的地方在于贴图的顺序，并不一定是要重头到尾依次贴图的。为当前所在的页面两边先创造贴图，比如现在正在显示第9页时，那优先为第9页，第8页和第7页进行贴图的话，在翻页时就不会一下就出来空白图层了。
