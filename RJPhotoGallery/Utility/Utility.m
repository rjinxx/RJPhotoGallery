//
//  Utility.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "Utility.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#define display_Pixel_Size 1000
#define MAX_Pixel_Size     2048

@implementation Utility

#pragma mark - Image From URL
// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t __arcGetAssetBytesCallback(void *info, void *buffer, off_t position, size_t count)
{
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error)
    {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void __arcReleaseAssetCallback(void *info)
{
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks =
    {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = __arcGetAssetBytesCallback,
        .releaseInfo = __arcReleaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source,
                                                              0,
                                                              (__bridge CFDictionaryRef)
                                                              @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                (NSString *)kCGImageSourceThumbnailMaxPixelSize :@(size),
                                                                (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,}
                                                              );
    if (source) CFRelease(source); if (provider) CFRelease(provider); if (!imageRef) return nil;
    
    UIImage *toReturn = nil;
    
    if (imageRef)
    {
        toReturn = [UIImage imageWithCGImage:imageRef];
        CFRelease(imageRef);
    }
    return toReturn;
}

+ (UIImage *)maxSizeImageWithURL:(NSURL *)url
{
    return [Utility imageWithURL:url maxPixelSize:MAX_Pixel_Size];
}

+ (UIImage *)fullScreenImageWithURL:(NSURL *)url
{
    return [Utility imageWithURL:url maxPixelSize:display_Pixel_Size];
}

+ (UIImage *)imageWithURL:(NSURL *)url maxPixelSize:(CGFloat)maxPixelSize
{
    if ([[url scheme] isEqualToString:@"assets-library"])
    {
        return [Utility imageFromAssetURL:url maxPixelSize:maxPixelSize];
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (!imageSource) return nil;
    
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways,
                                                         (id)[NSNumber numberWithFloat:maxPixelSize], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                         nil];
    CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    
    UIImage* scaled = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CFRelease(imageSource);
    
    return scaled;
}

+ (UIImage *)imageFromAssetURL:(NSURL *)url maxPixelSize:(CGFloat)maxPixelSize
{
    __block UIImage *image = nil;
    __block dispatch_semaphore_t _loadAlbumSemophore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init] ;
        [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset)
        {
            if (asset)
            {
                image = [Utility thumbnailForAsset:asset maxPixelSize:maxPixelSize];
            }
            
            dispatch_semaphore_signal(_loadAlbumSemophore);
        }
        failureBlock:^(NSError *error)
        {
            dispatch_semaphore_signal(_loadAlbumSemophore);
        }];
    });
    
    dispatch_semaphore_wait(_loadAlbumSemophore, DISPATCH_TIME_FOREVER);
    return image;
}

#pragma mark - Flip Image Orientation
+ (UIImage *)flipImageLeftRight:(UIImage *)originalImage
{
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:originalImage];
    
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0,
                                                           0, -1,
                                                           0, tempImageView.frame.size.height);
    CGContextConcatCTM(context, flipVertical);
    
    [tempImageView.layer renderInContext:context];
    
    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    flipedImage = [UIImage imageWithCGImage:flipedImage.CGImage scale:1.0 orientation:UIImageOrientationDown];
    UIGraphicsEndImageContext();
    
    return flipedImage;
}

#pragma mark - Image From Bundle
+ (UIImage *)imageFromAlbumBundle:(NSString *)name
{
    NSString *mPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PGallery.bundle/images/album"];
    NSString *image_path = [mPath stringByAppendingPathComponent:name];
    
    return [UIImage imageWithContentsOfFile:image_path];
}

+ (UIImage *)imageFromCameraBundle:(NSString *)name
{
    NSString *mPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PGallery.bundle/images/camera"];
    NSString *image_path = [mPath stringByAppendingPathComponent:name];
    
    return [UIImage imageWithContentsOfFile:image_path];
}

#pragma mark - Get Color Value
+ (id)getColorWith:(NSString *)hexColorNum corlorAlpha:(float)mAlpha
{
    NSString *cString = [[hexColorNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                         uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return nil;
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    unsigned int redInt, greenInt, blueInt;
    
    // red
    range.location = 0;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&redInt];
    
    // green
    range.location = 2;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&greenInt];
    
    // blue
    range.location = 4;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&blueInt];
    
    return [UIColor colorWithRed:(redInt/255.0) green:(greenInt/255.0) blue:(blueInt/255.0) alpha:mAlpha];
}

@end
