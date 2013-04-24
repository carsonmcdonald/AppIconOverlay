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

#import "FontOverlayBuilder.h"
#import "config.h"

@implementation FontOverlayBuilder
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

- (CFMutableAttributedStringRef)createAttributedStringUsingFont:(NSString *)fontName withFontSize:(double)fontSize withTextString:(NSString *)textString
{
    CFMutableAttributedStringRef attrStr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), (CFStringRef)textString);
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting _settings[] = { {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTForegroundColorAttributeName, CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0));
    CFRelease(paragraphStyle);
    CFRelease(font);
    
    return attrStr;
}

- (bool)willStringFit:(NSString *)versionNumber withSize:(CGSize) size withMaxLabelLength:(double)maxLabelLength withHeightPadding:(double) heightPadding withFontSize:(double) fontSize withImageSize:(CGSize) imageSize withFontName:(NSString *)fontName
{
    CFMutableAttributedStringRef attrStr = [self createAttributedStringUsingFont:fontName withFontSize:fontSize withTextString:versionNumber];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
    
    CFRange range;
    CGSize constraint = CGSizeMake(maxLabelLength - (heightPadding * 2.0), size.height - (heightPadding * 2.0));
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), nil, constraint, &range);
    
#if DEBUG
    NSLog(@"CoreText.SuggestFrameSize: %f x %f vs %f x %f", coreTextSize.width, coreTextSize.height, maxLabelLength - (heightPadding * 2.0), size.height - (heightPadding*2.0));
    NSLog(@"Character count in constraint frame: %ld (total: %ld)", range.length, CFAttributedStringGetLength(attrStr));
#endif
    
    return range.length == CFAttributedStringGetLength(attrStr);
}

- (bool)drawTextOverlay
{
    // Compute the shortest size of the label, this only works when the label is at 45 degrees
    CGFloat rotHyp = (hypot(overlayContext.inputImageSize.width, overlayContext.inputImageSize.height) - overlayContext.inputImageSize.height)/2.0;
    CGFloat maxLabelLength = overlayContext.inputImageSize.width - (hypot(rotHyp, rotHyp)*2.0);
    
    double finalFontSize = DEFAULT_MIN_FONT_SIZE;
    for(double testFontSize = DEFAULT_MAX_FONT_SIZE; testFontSize >= DEFAULT_MIN_FONT_SIZE; testFontSize--)
    {
        if([self willStringFit:overlayContext.bannerText withSize:overlayContext.bannerSize withMaxLabelLength:maxLabelLength withHeightPadding:overlayContext.bannerHeightPadding withFontSize:testFontSize withImageSize:overlayContext.inputImageSize withFontName:overlayContext.fontName])
        {
            finalFontSize = testFontSize;
            break;
        }
    }
    
#if DEBUG
    NSLog(@"Final font size: %f", finalFontSize);
#endif
    
    CFMutableAttributedStringRef attrStr = [self createAttributedStringUsingFont:overlayContext.fontName withFontSize:finalFontSize withTextString:overlayContext.bannerText];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
    
    CFRange range;
    CGSize constraint = CGSizeMake(maxLabelLength - (overlayContext.bannerHeightPadding * 2.0), overlayContext.bannerSize.height - (overlayContext.bannerHeightPadding * 2.0));
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), nil, constraint, &range);
    
#if DEBUG
    NSLog(@"CoreText.SuggestFrameSize: %f x %f vs %f x %f", coreTextSize.width, coreTextSize.height, maxLabelLength - (overlayContext.bannerHeightPadding * 2.0), overlayContext.bannerSize.height - (overlayContext.bannerHeightPadding * 2.0));
    NSLog(@"Character count in constraint frame: %ld (total: %ld)", range.length, CFAttributedStringGetLength(attrStr));
#endif
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake((overlayContext.bannerSize.width/2.0) - (coreTextSize.width/2.0), (overlayContext.bannerSize.height/2.0) - (coreTextSize.height/2.0), coreTextSize.width, coreTextSize.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), path, NULL);
    
    CTFrameDraw(frame, overlayContext.bannerContext);
    
    return range.length == CFAttributedStringGetLength(attrStr);
}

@end
