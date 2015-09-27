//
//  PhotoCell.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@end

@implementation PhotoCell

- (void)configureForImage:(UIImage *)image
{
    self.thumbnailView.image = image;
}

- (void)layoutSubviews
{
    // fix size error - .5 pixel in iOS 7
    self.contentView.frame = self.bounds;
    
    [super layoutSubviews];
}

@end
