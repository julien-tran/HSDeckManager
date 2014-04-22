//
//  UIImage+HS.m
//  HSDeckManager
//
//  Created by Minh-Hang LE on 22/04/2014.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "UIImage+HS.h"

@implementation UIImage (HS)

+ (UIImage *)imageFromView:(UIView *)view
{
    UIImage *img = nil;
    UIGraphicsBeginImageContext(view.frame.size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
