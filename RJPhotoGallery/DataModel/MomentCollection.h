//
//  MomentCollection.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MomentCollection : NSObject

@property (nonatomic, readwrite) NSUInteger     month;
@property (nonatomic, readwrite) NSUInteger     year;
@property (nonatomic, readwrite) NSUInteger     day;

@property (nonatomic, strong) id assetObjs;

@end
