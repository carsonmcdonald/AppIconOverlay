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

#import "CGUtils.h"

@implementation CGUtils

+ (CGContextRef)createBitmapContextWithSize:(CGSize)contextSize
{
    size_t bitmapBytesPerRow = (contextSize.width * 4);
    size_t bitmapByteCount = (bitmapBytesPerRow * contextSize.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    void *bitmapData = calloc(1, bitmapByteCount);
    if(bitmapData == NULL)
    {
        fprintf(stderr, "Memory not allocated!");
        return NULL;
    }
    
    CGContextRef context = CGBitmapContextCreate(bitmapData,
                                                 contextSize.width,
                                                 contextSize.height,
                                                 8,
                                                 bitmapBytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast );
    if(context == NULL)
    {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
        return NULL;
    }
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

+ (bool)readImageFromFilename:(NSString *)inputFilename intoOverlayContext:(OverlayContext *)overlayContext
{
    NSData *inputData = [NSData dataWithContentsOfFile:inputFilename];
    if(inputData == nil)
    {
        return NO;
    }
    else
    {
        CGDataProviderRef imageDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inputData);
        
        CGImageRef inputImage = CGImageCreateWithPNGDataProvider(imageDataProvider, NULL, true, kCGRenderingIntentDefault);
        
        overlayContext.inputImageSize = CGSizeMake(CGImageGetWidth(inputImage), CGImageGetHeight(inputImage));
        
        overlayContext.workingContext = [self createBitmapContextWithSize:overlayContext.inputImageSize];
        
        CGContextDrawImage(overlayContext.workingContext, CGRectMake(0, 0, overlayContext.inputImageSize.width, overlayContext.inputImageSize.height), inputImage);
        
        CFRelease(inputImage);
        CFRelease(imageDataProvider);
        
        return YES;
    }
}

+ (void)writeImageFromContext:(OverlayContext *)overlayContext toFilename:(NSString *)outputFilename
{
    CGImageRef outputImage = CGBitmapContextCreateImage(overlayContext.workingContext);
    
    NSMutableData *outputData = [[NSMutableData alloc] init];
    CGImageDestinationRef outputDest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)(outputData), kUTTypePNG, 1, NULL);
    
    CGImageDestinationAddImage(outputDest, outputImage, NULL);
    
    if(!CGImageDestinationFinalize(outputDest))
    {
        NSLog(@"Error creating output image");
    }
    
    CFRelease(outputDest);
    
    [outputData writeToFile:outputFilename atomically:YES];

}

@end
