//
//  AssetSourceManager.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "AssetSourceManager.h"
#import "MomentCollection.h"
#import "ALAsset+Date.h"
#import "AlbumObj.h"

typedef void (^MomentBatchBlock)(BOOL ret, id obj);

@interface AssetSourceManager ()

@property (nonatomic, strong) NSMutableArray   *assetGroups;
@property (nonatomic, strong) ALAssetsLibrary  *assetLibary;
@property (nonatomic, strong) NSOperationQueue *operQueue;
@property (nonatomic, copy)   MomentBatchBlock batchBlock;

@end

@implementation AssetSourceManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.stopEnumeratePhoto = NO;
        self.assetGroups = [[NSMutableArray  alloc] init];
        self.assetLibary = [[ALAssetsLibrary alloc] init];
        
        self.operQueue = [[NSOperationQueue alloc] init];
        [self.operQueue setName:@"EnumerateQueue"];
        [self.operQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (BOOL)haveAccessToPhotos
{
    return ( [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusRestricted &&
             [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied );
}

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion
{
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    // {
    @autoreleasepool
    {
        NSMutableArray *tmpAry = [[NSMutableArray alloc] init];
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (group == nil)
            {
                self.assetGroups = tmpAry;
                completion(YES, self.assetGroups); return;
            }
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            if ([group numberOfAssets])
            {
                AlbumObj *obj   = [[AlbumObj alloc] init]; obj.collection = group;
                obj.name        = [group valueForProperty:ALAssetsGroupPropertyName];
                obj.posterImage = [UIImage imageWithCGImage:group.posterImage];
                obj.count = group.numberOfAssets; [tmpAry insertObject:obj atIndex:0];
            }
        };
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error)
        {
            if (error.code == ALAssetsLibraryAccessUserDeniedError ||
                error.code == ALAssetsLibraryAccessGloballyDeniedError)
            {
                completion(NO, nil);
            }
        };
        // Enumerate Albums
        [self.assetLibary enumerateGroupsWithTypes:ALAssetsGroupAll
                                        usingBlock:assetGroupEnumerator
                                      failureBlock:assetGroupEnumberatorFailure];
    }
    // });
}

- (void)getPhotosWithGroup:(AlbumObj *)obj
                completion:(void (^)(BOOL ret, id obj))completion
{
    if (![obj.collection isKindOfClass:[ALAssetsGroup class]])
    {
        completion(NO, nil); return;
    }
    ALAssetsGroup *group = (ALAssetsGroup *)obj.collection;
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    // {
    @autoreleasepool
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[group numberOfAssets]];
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
        {
            if (self.stopEnumeratePhoto)
            {
                *stop = YES; return;
            }
            if (nil == result) // enum end, and reload data
            {
                completion(YES, tmpArray); return;
            }
            [tmpArray addObject:result];
        }];
    }
    // });
}

- (void)groupForURL:(NSURL *)groupURL completion:(void (^)(BOOL ret, id obj))completion
{
    [self.assetLibary groupForURL:groupURL resultBlock:^(ALAssetsGroup *group)
    {
        completion((nil != group), group);
    }
    failureBlock:^(NSError *error)
    {
        completion(NO, nil);
    }];
}

- (void)getPhotoWithAsset:(ALAsset *)asset
               completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (![asset isKindOfClass:[ALAsset class]])
    {
        completion(NO, nil); return;
    }
    
    ALAssetRepresentation* assetRep = [asset defaultRepresentation];
    
    CGImageRef currentImageRef = [assetRep fullResolutionImage];
    
    UIImage *image = [UIImage imageWithCGImage:currentImageRef
                                         scale:1.0
                                   orientation:(UIImageOrientation)[assetRep orientation]];
    completion((image == nil), image);
}

- (void)getPosterImageForAlbumObj:(AlbumObj *)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
    ALAssetsGroup *group = (ALAssetsGroup *)album.collection;
    UIImage *image       = [UIImage imageWithCGImage:group.posterImage];
    
    completion((image != nil), image);
}

#pragma mark - Moment Action
- (void)getPhotosWithGroupTypes:(ALAssetsGroupType)types
                    batchReturn:(BOOL)batch
                     completion:(void (^)(BOOL ret, id obj))completion
{
    self.batchBlock        = completion;
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    
    [self.assetLibary enumerateGroupsWithTypes:types
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
        if (self.stopEnumeratePhoto) {*stop = YES; return;}
         
        NSInteger gType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
         
        if (group && (gType != ALAssetsGroupPhotoStream))
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             
            [group enumerateAssetsWithOptions:NSEnumerationReverse
                                   usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
            {
                if (self.stopEnumeratePhoto) {*stop = YES; return;}
                  
                if (result) [tmpArr addObject:result];
                  
                if (batch && !([tmpArr count]%50)) [self addQueueWithData:tmpArr final:NO];
            }];
            /*
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
            {
            if (self.stopEnumeratePhoto) {*stop = YES; return;}
              
            if (result) [tmpArray addObject:result];
              
            if (batch && !([tmpArray count]%50)) completion(NO, tmpArray);
            }];
            */
        }
        else if (nil == group)
        {
            [self addQueueWithData:tmpArr final:YES];
        }
    }
    failureBlock:^(NSError *error)
    {
        completion(NO, nil); // permission required...
    }];
}

- (void)addQueueWithData:(NSMutableArray *)data final:(BOOL)final
{
    NSMutableArray *rawData = [NSMutableArray arrayWithArray:data];
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^
    {
        [self sortMomentWithDate:rawData final:final];
    }];
    
    [self.operQueue addOperation:op];
}

- (void)sortMomentWithDate:(NSMutableArray *)objects final:(BOOL)final
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    
    [objects sortUsingDescriptors:@[sort]];
    
    MomentCollection *lastGroup = nil; NSMutableArray *ds = [[NSMutableArray alloc] init];
    
    for (ALAsset *asset in objects)
    {
        @autoreleasepool
        {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit   |
                                                                                    NSMonthCalendarUnit |
                                                                                    NSYearCalendarUnit
                                                                           fromDate:[asset date]];
            NSUInteger month = [components month];
            NSUInteger year  = [components year];
            NSUInteger day   = [components day];
            
            if (!lastGroup || lastGroup.year!=year || lastGroup.month!=month || lastGroup.day!=day)
            {
                lastGroup = [MomentCollection new]; [ds addObject:lastGroup];
                
                lastGroup.month = month; lastGroup.year = year; lastGroup.day = day;
            }
            
            ALAsset *lPhoto    = [lastGroup.assetObjs lastObject];
            NSURL   *lPhotoURL = [lPhoto valueForProperty:ALAssetPropertyAssetURL];
            NSURL   *photoURL  = [asset  valueForProperty:ALAssetPropertyAssetURL];
            
            if (![lPhotoURL isEqual:photoURL])
            {
                [lastGroup.assetObjs addObject:asset];
            }
        }
    }
    
    [self cleanQueueAfterRoundOperation];
    
    if (self.batchBlock) self.batchBlock(final, ds);
}

- (void)cleanQueueAfterRoundOperation
{
    if (self.operQueue == nil) return;
    
    if (self.operQueue.operationCount > 1)
    {
        NSArray *queueArr = self.operQueue.operations;
        NSMutableArray *opArr = [NSMutableArray arrayWithArray:queueArr];
        
        [opArr removeLastObject]; [opArr removeLastObject];
        [opArr makeObjectsPerformSelector:@selector(cancel)];
    }
}

@end