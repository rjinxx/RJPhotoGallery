//
//  AlbumObj.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlbumObj : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) UIImage   *posterImage;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) id collection;
@property (nonatomic, strong) NSURL *URL; // for iOS 7 only

@end
