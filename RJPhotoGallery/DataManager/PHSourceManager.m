//
//  PHSourceManager.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "PHSourceManager.h"
#import "AlbumObj.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation PHSourceManager

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.manager = [[PHImageManager alloc] init];
    }
    return self;
}

- (BOOL)haveAccessToPhotos
{
    return ( [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusRestricted &&
             [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied );
}

- (void)getMomentsWithAscending:(BOOL)ascending
                     completion:(void (^)(BOOL ret, id obj))completion
{
    PHFetchOptions *options  = [[PHFetchOptions alloc] init];
    options.sortDescriptors  = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate"
                                                               ascending:ascending]];
    
    PHFetchResult  *momentRes = [PHAssetCollection fetchMomentsWithOptions:options];
    NSMutableArray *momArray  = [[NSMutableArray alloc] init];
    
    for (PHAssetCollection *collection in momentRes)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit   |
                                                                                NSMonthCalendarUnit |
                                                                                NSYearCalendarUnit
                                                                       fromDate:collection.endDate];
        NSUInteger month = [components month];
        NSUInteger year  = [components year];
        NSUInteger day   = [components day];
        
        MomentCollection *moment = [MomentCollection new];
        moment.month = month; moment.year = year; moment.day = day;
        
        PHFetchOptions *option  = [[PHFetchOptions alloc] init];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
        
        moment.assetObjs = [PHAsset fetchAssetsInAssetCollection:collection
                                                         options:option];
        if ([moment.assetObjs count]) [momArray addObject:moment];
    }
    
    completion(YES, momArray);
}

- (void)getImageForPHAsset:(PHAsset *)asset
                  withSize:(CGSize)size
                completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    
    NSInteger r = [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:YES]; // called exactly once
    
    [self.manager requestImageForAsset:asset
                            targetSize:CGSizeMake(size.width*r, size.height*r)
                           contentMode:PHImageContentModeAspectFit
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
    {
        completion(YES, result);
    }];
}

- (void)getURLForPHAsset:(PHAsset *)asset
              completion:(void (^)(BOOL ret, NSURL *URL))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    
    [asset requestContentEditingInputWithOptions:nil
                               completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                   NSDictionary *info)
    {
        NSURL *imageURL = contentEditingInput.fullSizeImageURL;
         
        completion(YES, imageURL);
    }];
}

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion
{
    NSMutableArray *tmpAry   = [[NSMutableArray alloc] init];
    PHFetchOptions *option   = [[PHFetchOptions alloc] init];
    option.predicate         = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    option.sortDescriptors   = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                               ascending:NO]];
    PHFetchResult  *cameraRo = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                        subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                        options:nil];
    PHAssetCollection *colt  = [cameraRo lastObject];
    PHFetchResult *fetchR    = [PHAsset fetchAssetsInAssetCollection:colt
                                                             options:option];
    AlbumObj *obj   = [[AlbumObj alloc] init];
    obj.type        = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    obj.name        = colt.localizedTitle; obj.count = fetchR.count;
    obj.collection  = fetchR; if(obj.count) [tmpAry addObject:obj];
    
    // for iOS 9, we need to show ScreenShot Album
    /*
     if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
     {
     PHFetchResult  *screenShot = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
     subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots
     options:nil];
     PHAssetCollection *sColt   = [screenShot lastObject];
     PHFetchResult *sFetchR     = [PHAsset fetchAssetsInAssetCollection:sColt
     options:option];
     PGAlbumObj *sObj = [[PGAlbumObj alloc] init];
     sObj.type        = PHAssetCollectionSubtypeSmartAlbumScreenshots;
     sObj.name        = sColt.localizedTitle; sObj.count = sFetchR.count;
     sObj.collection  = sFetchR; if(sObj.count) [tmpAry addObject:sObj];
     }
     */
    PHAssetCollectionSubtype tp = PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum;
    PHFetchResult *albums       = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:tp
                                                                           options:nil];
    for (PHAssetCollection *col in albums)
    {
        @autoreleasepool
        {
            PHFetchResult *fRes = [PHAsset fetchAssetsInAssetCollection:col
                                                                options:option];
            
            AlbumObj *obj = [AlbumObj new]; obj.type = col.assetCollectionSubtype;
            obj.name = col.localizedTitle; obj.collection = fRes; obj.count = fRes.count;
            
            if (fRes.count > 0) [tmpAry addObject:obj]; // drop empty album
        }
    }
    
    completion(YES, tmpAry);
}

- (void)getPosterImageForAlbumObj:(AlbumObj *)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
    PHAsset *asset = [album.collection firstObject];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scale = [UIScreen mainScreen].scale; CGFloat dimension = 60.f;
    CGSize  size  = CGSizeMake(dimension * scale, dimension * scale);
    
    [self.manager requestImageForAsset:asset
                            targetSize:size
                           contentMode:PHImageContentModeAspectFill
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
    {
        completion((result != nil), result);
    }];
}

- (void)getPhotosWithGroup:(AlbumObj *)obj
                completion:(void (^)(BOOL ret, id obj))completion
{
    if (![obj.collection isKindOfClass:[PHFetchResult class]])
    {
        completion(NO, nil); return;
    }
    
    completion(YES, (PHFetchResult *)obj.collection);
}

@end

