//
//  Utility.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

#pragma mark - Image From URL
+ (UIImage *)fullScreenImageWithURL:(NSURL *)url;
+ (UIImage *)maxSizeImageWithURL:(NSURL *)url;
+ (UIImage *)imageWithURL:(NSURL *)url maxPixelSize:(CGFloat)maxPixelSize;

#pragma mark - Flip Image Orientation
+ (UIImage *)flipImageLeftRight:(UIImage *)originalImage;

#pragma mark - Image From Bundle
+ (UIImage *)imageFromAlbumBundle:(NSString *)name;
+ (UIImage *)imageFromCameraBundle:(NSString *)name;

#pragma mark - Get Color Value
+ (id)getColorWith:(NSString *)hexColorNum corlorAlpha:(float)mAlpha;

@end
