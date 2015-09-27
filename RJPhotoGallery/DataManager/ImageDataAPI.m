//
//  ImageDataAPI.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "ImageDataAPI.h"
#import "AssetSourceManager.h"
#import "PHSourceManager.h"

#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

@interface ImageDataAPI ()

@property (nonatomic, strong) AssetSourceManager *asManager;
@property (nonatomic, strong) PHSourceManager *phManager;

@end

@implementation ImageDataAPI

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.asManager = [[AssetSourceManager alloc] init];
        self.phManager = [[PHSourceManager alloc] init];
    }
    return self;
}

+ (ImageDataAPI *)sharedInstance
{
    static ImageDataAPI *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^
    {
        _sharedInstance = [[ImageDataAPI alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Integrated API
- (void)getMomentsWithBatchReturn:(BOOL)batch
                        ascending:(BOOL)ascending
                       completion:(void (^)(BOOL done, id obj))completion
{
    if (IS_IOS_8)
    {
        [self.phManager getMomentsWithAscending:ascending
                                     completion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
    else
    {
        [self stopEnumeratePhoto:NO];
        [self.asManager getPhotosWithGroupTypes:ALAssetsGroupAll
                                    batchReturn:batch
                                     completion:^(BOOL ret, id obj)
        {
             completion(ret, obj);
        }];
    }
}

- (void)getThumbnailForAssetObj:(id)asset
                       withSize:(CGSize)size
                     completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (IS_IOS_8/*&& !CGSizeEqualToSize(size, CGSizeZero)*/)
    {
        [self.phManager getImageForPHAsset:asset
                                  withSize:size
                                completion:^(BOOL ret, UIImage *image)
        {
            completion(ret, image);
        }];
    }
    else
    {
        if (![asset isKindOfClass:[ALAsset class]])
        {
            completion(NO, nil); return;
        }
        
        ALAsset *ast = (ALAsset *)asset;
        completion(YES, [UIImage imageWithCGImage:ast.thumbnail]);
    }
}

- (void)getURLForAssetObj:(id)asset
                /*usingPH:(BOOL)usingPH*/
               completion:(void (^)(BOOL ret, NSURL *URL))completion
{
    if (IS_IOS_8/* && usingPH*/)
    {
        [self.phManager getURLForPHAsset:asset completion:^(BOOL ret, NSURL *URL)
        {
            completion(ret, URL);
        }];
    }
    else
    {
        if (![asset isKindOfClass:[ALAsset class]])
        {
            completion(NO, nil); return;
        }
        
        ALAsset *ast = (ALAsset *)asset;
        completion(YES, ast.defaultRepresentation.url);
    }
}

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion
{
    if (IS_IOS_8)
    {
        [self.phManager getAlbumsWithCompletion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
    else
    {
        [self.asManager getAlbumsWithCompletion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
}

- (void)getPosterImageForAlbumObj:(id)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
    if (IS_IOS_8)
    {
        [self.phManager getPosterImageForAlbumObj:album
                                       completion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
    else
    {
        [self.asManager getPosterImageForAlbumObj:album
                                       completion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
}

- (void)getPhotosWithGroup:(id)group
                completion:(void (^)(BOOL ret, id obj))completion
{
    if (IS_IOS_8)
    {
        [self.phManager getPhotosWithGroup:group completion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
    else
    {
        [self stopEnumeratePhoto:NO];
        [self.asManager getPhotosWithGroup:group completion:^(BOOL ret, id obj)
        {
            completion(ret, obj);
        }];
    }
}

- (void)getImageForPhotoObj:(id)asset
                   withSize:(CGSize)size
                 completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (IS_IOS_8)
    {
        [self.phManager getImageForPHAsset:asset
                                  withSize:size
                                completion:^(BOOL ret, UIImage *image)
        {
            completion(ret, image);
        }];
    }
    else
    {
        [self.asManager getPhotoWithAsset:asset
                               completion:^(BOOL ret, UIImage *image)
        {
            completion(ret, image);
        }];
    }
}

- (void)stopEnumeratePhoto:(BOOL)res
{
    self.asManager.stopEnumeratePhoto = res;
}

- (BOOL)haveAccessToPhotos
{
    if (IS_IOS_8)
    {
        return [self.phManager haveAccessToPhotos];
    }
    else
    {
        return [self.asManager haveAccessToPhotos];
    }
}

@end