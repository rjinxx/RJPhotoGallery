//
//  AlbumObj.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "AlbumObj.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

@interface AlbumObj ()

@property (nonatomic, strong) PHFetchResult *fetRes;
@property (nonatomic, strong) ALAssetsGroup *group;

@end

@implementation AlbumObj

- (id)collection
{
    return IS_IOS_8 ? self.fetRes : self.group;
}

- (void)setCollection:(id)collection
{
    if (IS_IOS_8)
    {
        self.fetRes = (PHFetchResult *)collection;
    }
    else
    {
        self.group = (ALAssetsGroup *)collection;
    }
}

- (NSURL *)URL
{
    if (IS_IOS_8) return nil;
    
    NSURL *gURL         = [self.group valueForProperty:ALAssetsGroupPropertyURL];
    NSArray *components = [gURL.absoluteString componentsSeparatedByString:@"&"];
    
    return [NSURL URLWithString:[components firstObject]];
}

@end
