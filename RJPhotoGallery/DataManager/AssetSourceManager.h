//
//  AssetSourceManager.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface AssetSourceManager : NSObject

@property (nonatomic, assign) BOOL stopEnumeratePhoto;

- (BOOL)haveAccessToPhotos;

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion;

- (void)getPhotosWithGroup:(ALAssetsGroup *)group
                completion:(void (^)(BOOL ret, id obj))completion;

- (void)getPhotosWithGroupTypes:(ALAssetsGroupType)types
                    batchReturn:(BOOL)batch
                     completion:(void (^)(BOOL ret, id obj))completion;

- (void)groupForURL:(NSURL *)groupURL completion:(void (^)(BOOL ret, id obj))completion;

- (void)getPhotoWithAsset:(ALAsset *)asset
               completion:(void (^)(BOOL ret, UIImage *image))completion;

- (void)getPosterImageForAlbumObj:(id)album
                       completion:(void (^)(BOOL ret, id obj))completion;

@end
