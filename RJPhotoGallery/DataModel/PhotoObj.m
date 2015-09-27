//
//  PhotoObj.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "PhotoObj.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

@interface PhotoObj ()

@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, strong) PHAsset *phAsset;

@end

@implementation PhotoObj

- (id)photoObj
{
    return IS_IOS_8 ? self.phAsset : self.alAsset;
}

- (void)setPhotoObj:(id)photoObj
{
    if (IS_IOS_8)
    {
        self.phAsset = (PHAsset *)photoObj;
    }
    else
    {
        self.alAsset = (ALAsset *)photoObj;
    }
}

@end
