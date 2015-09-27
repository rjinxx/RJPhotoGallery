//
//  MomentDataSource.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "BaseDataSource.h"

@interface MomentDataSource : BaseDataSource

@property (nonatomic, copy) NSString *headerIdentifier;

- (id)initWithCellIdentifier:(NSString *)cellID
            headerIdentifier:(NSString *)headerID
          configureCellBlock:(CellConfigureBlock)block;

@end
