//
//  ALAsset+Date.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "ALAsset+Date.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation ALAsset (Date)

- (NSDate *)date
{
    return [self valueForProperty:ALAssetPropertyDate];
}

@end
