//
//  WK.h
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-25.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#ifndef WKPagesScrollView_WK_h
#define WKPagesScrollView_WK_h
///获取主目录
#define WK_PATH_HOME NSHomeDirectory()
///获取临时目录
#define WK_PATH_TEMP NSTemporaryDirectory()
///获取文档目录
#define WK_PATH_DOCUMENT NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)[0]

static inline CATransform3D WKFlipCATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, -300.0f);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 300.0f);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}
static inline CATransform3D WKFlipCATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, WKFlipCATransform3DMakePerspective(center, disZ));
}
static inline CATransform3D WKFlipCATransform3DPerspectSimple(CATransform3D t){
    return WKFlipCATransform3DPerspect(t, CGPointMake(0, 0), 500.0f);
}
static inline CATransform3D WKFlipCATransform3DPerspectSimpleWithRotate(CGFloat degree){
    return WKFlipCATransform3DPerspectSimple(CATransform3DMakeRotation((M_PI*degree/180.0f), 1.0, 0.0, 0.0));
}
///为UIView创建一个截图
static inline UIImage* WKFlip_make_image_for_view(UIView* view){
    double startTime=CFAbsoluteTimeGetCurrent();
    if(UIGraphicsBeginImageContextWithOptions != NULL){
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //[view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"makeImage duration:%f", CFAbsoluteTimeGetCurrent()-startTime);
    return image;
}
///分割图片
static inline NSArray* WKFlip_make_hsplit_images_for_image(UIImage* image){
    CGSize halfSize=CGSizeMake(image.size.width, image.size.height/2);
    UIGraphicsBeginImageContext(halfSize);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
    CGContextTranslateCTM(context, 0, halfSize.height); // 3-1
    CGContextScaleCTM(context, 1.0, -1.0); // 4-1
    CGImageRef imageRef=image.CGImage;
    CGContextDrawImage(context, CGRectMake(0, -1*halfSize.height,
                                           image.size.width,
                                           image.size.height),
                       imageRef);
    UIImage* imageFirst=UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextClearRect(context, CGRectMake(0, 0, image.size.width , image.size.height));
    CGContextDrawImage(context, CGRectMake(0,0,
                                           image.size.width,
                                           image.size.height),
                       imageRef);
    UIImage* imageSecond=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    //WLog_Float(@"hSplitImageToArray duration", CFAbsoluteTimeGetCurrent()-startTime);
    return @[imageFirst,imageSecond,];
}
///为UIView创建截图并且分割
static inline NSArray* WKFlip_make_hsplit_images_for_view(UIView* view){
    UIImage* image=WKFlip_make_image_for_view(view);
    return WKFlip_make_hsplit_images_for_image(image);
}
#endif
