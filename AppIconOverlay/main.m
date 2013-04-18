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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <libgen.h>

#import "OverlayContext.h"
#import "BannerOverlayBuilder.h"
#import "CGUtils.h"
#import "FontOverlayBuilder.h"

static struct option long_options[] =
{
    {"input",     required_argument,    NULL,   'i'},
    {"output",    required_argument,    NULL,   'o'},
    {"text",      required_argument,    NULL,   't'},
    {"height",    required_argument,    NULL,   'h'},
    {"padding",   required_argument,    NULL,   'p'},
    {NULL,        0,                    NULL,   0}
};

void usage(char *execName)
{
    fprintf(stderr, "Usage: %s [options]\n", basename(execName));
    fprintf(stderr, "  options:\n");
    fprintf(stderr, "    --input,-i: image file to read in\n");
    fprintf(stderr, "    --output,-o: output image file\n");
    fprintf(stderr, "    --text,-t: text to put on banner\n");
    fprintf(stderr, "    --height,-h: height of banner\n");
    fprintf(stderr, "    [--padding,-p]: padding around banner text\n");
    fprintf(stderr, "  example:\n");
    fprintf(stderr, "    %s -i input.png -o output.png --text 1.2.0 -h 19.0\n", basename(execName));
}

OverlayContext *configureOverlayContext(int argc, const char *argv[])
{
    OverlayContext *overlayContext = [[OverlayContext alloc] init];
    
    CGFloat bannerHeight = -1.0;
    NSString *inputFilename = nil;
    bool optionError = NO;
    
    bool done = NO;
    do
    {
        int option_index = 0;
        
        switch(getopt_long(argc, (char **)argv, "i:o:t:h:p:", long_options, &option_index))
        {
            case -1:
            {
                done = YES;
            } break;
                
            case 'i':
            {
                inputFilename = optarg == nil ? nil : [NSString stringWithFormat:@"%s", optarg];
            } break;
                
            case 'o':
            {
                overlayContext.outputFilename = optarg == nil ? nil : [NSString stringWithFormat:@"%s", optarg];
            } break;
                
            case 't':
            {
                overlayContext.bannerText = optarg == nil ? nil : [NSString stringWithFormat:@"%s", optarg];
            } break;
                
            case 'h':
            {
                bannerHeight = optarg == nil ? -1.0 : atof(optarg);
            } break;
                
            case 'p':
            {
                overlayContext.bannerHeightPadding = optarg == nil ? -1.0 : atof(optarg);
            } break;

            case '?':
            default:
            {
                usage((char*)argv[0]);
                optionError = YES;
                done = YES;
            }
        }
    } while(!done);
    
    if(!optionError && inputFilename == nil)
    {
        fprintf(stderr, "input is a required option.\n");
        usage((char*)argv[0]);
        optionError = YES;
    }
    
    if(!optionError && overlayContext.outputFilename == nil)
    {
        fprintf(stderr, "output is a required option.\n");
        usage((char*)argv[0]);
        optionError = YES;
    }
    
    if(!optionError && overlayContext.bannerText == nil)
    {
        fprintf(stderr, "text is a required option.\n");
        usage((char*)argv[0]);
        optionError = YES;
    }
    
    if(!optionError && bannerHeight == -1.0)
    {
        fprintf(stderr, "height is a required option.\n");
        optionError = YES;
    }
    
    if(!optionError && overlayContext.bannerHeightPadding == -1.0)
    {
        fprintf(stderr, "padding value could not be parsed.\n");
        usage((char*)argv[0]);
        optionError = YES;
    }
    
    if(!optionError)
    {
        if(![CGUtils readImageFromFilename:inputFilename intoOverlayContext:overlayContext])
        {
            fprintf(stderr, "Could not read input file: %s.\n", inputFilename.UTF8String);
            optionError = YES;
        }
    }
    
    if(!optionError)
    {
        overlayContext.bannerSize = CGSizeMake(overlayContext.inputImageSize.width, bannerHeight);
        
        overlayContext.bannerContext = [CGUtils createBitmapContextWithSize:overlayContext.bannerSize];
        
        return overlayContext;
    }

    return nil;
}

int main(int argc, const char *argv[])
{
    int exitCode = 0;
    
    @autoreleasepool
    {
        OverlayContext *overlayContext = configureOverlayContext(argc, argv);
        if(overlayContext != nil)
        {
            BannerOverlayBuilder *bannerOverlayBuilder = [[BannerOverlayBuilder alloc] initWithOverlayContext:overlayContext];
            
            FontOverlayBuilder *fontOverlayBuilder = [[FontOverlayBuilder alloc] initWithOverlayContext:overlayContext];
            
            [bannerOverlayBuilder createGradientOverlayBanner];
            
            [fontOverlayBuilder drawTextOverlay];
            
            [bannerOverlayBuilder rotateOverlayBannerAndApplyToFinalImage];
            
            [CGUtils writeImageFromContext:overlayContext toFilename:overlayContext.outputFilename];
            
            exitCode = 0;
        }
        else
        {
            exitCode = -1;
        }
    }
    
    return exitCode;
}

