//
//  MomentCollection.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "MomentCollection.h"
#import <Photos/Photos.h>

#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

@interface MomentCollection ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PHFetchResult  *assets;

@end

@implementation MomentCollection

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)assetObjs
{
    return IS_IOS_8 ? self.assets : self.items;
}

- (void)setAssetObjs:(id)assetObjs
{
    if (IS_IOS_8)
    {
        self.assets = (PHFetchResult *)assetObjs;
    }
    else
    {
        self.items  = (NSMutableArray *)assetObjs;
    }
}

@end
