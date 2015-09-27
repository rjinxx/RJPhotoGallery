//
//  ImageDataAPI.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ImageDataAPI : NSObject

+ (ImageDataAPI *)sharedInstance;

// Integrated API
- (void)getMomentsWithBatchReturn:(BOOL)batch // batch for iOS 7 only
                        ascending:(BOOL)ascending
                       completion:(void (^)(BOOL done, id obj))completion;

- (void)getThumbnailForAssetObj:(id)asset
                       withSize:(CGSize)size  // size for iOS 8 only
                     completion:(void (^)(BOOL ret, UIImage *image))completion;

- (void)getURLForAssetObj:(id)asset
                /*usingPH:(BOOL)usingPH*/
               completion:(void (^)(BOOL ret, NSURL *URL))completion;

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion;

- (void)getPosterImageForAlbumObj:(id)album
                       completion:(void (^)(BOOL ret, id obj))completion;

- (void)getPhotosWithGroup:(id)group
                completion:(void (^)(BOOL ret, id obj))completion;

- (void)getImageForPhotoObj:(id)asset
                   withSize:(CGSize)size
                 completion:(void (^)(BOOL ret, UIImage *image))completion;

- (BOOL)haveAccessToPhotos;
- (void)stopEnumeratePhoto:(BOOL)res;

@end
