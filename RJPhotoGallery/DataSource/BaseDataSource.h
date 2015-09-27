//
//  BaseDataSource.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CellConfigureBlock)(id cell, id item);

@interface BaseDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy)   NSString *cellIdentifier;
@property (nonatomic, copy)   CellConfigureBlock block;

- (id)initWithCellIdentifier:(NSString *)cellID
          configureCellBlock:(CellConfigureBlock)block;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
