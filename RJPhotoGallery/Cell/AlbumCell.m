//
//  AlbumCell.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "AlbumCell.h"

@interface AlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation AlbumCell

- (void)configureWithAlbumObj:(AlbumObj *)obj
{
    self.posterView.image = obj.posterImage;
    self.name.text        = obj.name;
    self.count.text       = [NSString stringWithFormat:@"%ld",(long)obj.count];
}

@end
