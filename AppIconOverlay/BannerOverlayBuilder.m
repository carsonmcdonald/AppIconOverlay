//
// Copyright (c) 2013 Carson McDonald
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

#import "BannerOverlayBuilder.h"

#import "CGUtils.h"

@implementation BannerOverlayBuilder
{
    OverlayContext *overlayContext;
}

- (id)initWithOverlayContext:(OverlayContext *)oc
{
    if(self = [super init])
    {
        overlayContext = oc;
    }
    return self;
}

- (void)createGradientOverlayBanner
{
    // Gradient fill the label
    CGFloat colors [] = {
        0.0, 0.20, 1.0, 1.0,
        0.0, 0.60, 1.0, 1.0,
        0.0, 0.20, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 3);
    CGColorSpaceRelease(baseSpace);
    
    CGContextDrawLinearGradient(overlayContext.bannerContext, gradient, CGPointMake(0, overlayContext.bannerSize.height), CGPointMake(overlayContext.bannerSize.width, 0), 0);
    CGGradientRelease(gradient);
    
    // draw the label area
    CGContextSetRGBStrokeColor(overlayContext.bannerContext, 0.0, 0.50, 1.0, 1.0);
    CGContextMoveToPoint(overlayContext.bannerContext, 0, 0);
    CGContextAddLineToPoint(overlayContext.bannerContext, overlayContext.bannerSize.width, 0);
    CGContextAddLineToPoint(overlayContext.bannerContext, overlayContext.bannerSize.width, overlayContext.bannerSize.height);
    CGContextAddLineToPoint(overlayContext.bannerContext, 0, overlayContext.bannerSize.height);
    CGContextClosePath(overlayContext.bannerContext);
    CGContextStrokePath(overlayContext.bannerContext);
}

#define DEGSTORADS(degs) (0.0174532925 * degs)

- (void)rotateOverlayBannerAndApplyToFinalImage
{
    CGImageRef inputImage = CGBitmapContextCreateImage(overlayContext.bannerContext);
    
    CGContextRef context = [CGUtils createBitmapContextWithSize:overlayContext.inputImageSize];
    
    CGContextTranslateCTM(context, overlayContext.inputImageSize.width * 0.5, 0);
    CGContextRotateCTM(context, DEGSTORADS(45.0));
    CGContextDrawImage(context, CGRectMake(0, 0, overlayContext.bannerSize.width, overlayContext.bannerSize.height), inputImage);
    
    CGImageRelease(inputImage);
    
    CGContextRelease(overlayContext.bannerContext);
    
    overlayContext.bannerContext = context;

    CGFloat hOffset = hypot(overlayContext.inputImageSize.width, overlayContext.inputImageSize.height);
    
    CGImageRef textImage = CGBitmapContextCreateImage(overlayContext.bannerContext);
    
    CGContextDrawImage(overlayContext.workingContext, CGRectMake(0, -(hOffset-overlayContext.inputImageSize.height)/2.0, overlayContext.inputImageSize.width, overlayContext.inputImageSize.height), textImage);
    
    CGImageRelease(textImage);
}

@end
