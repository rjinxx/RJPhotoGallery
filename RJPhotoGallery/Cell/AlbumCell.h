//
//  AlbumCell.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumObj.h"

@interface AlbumCell : UITableViewCell

- (void)configureWithAlbumObj:(AlbumObj *)obj;

@end
