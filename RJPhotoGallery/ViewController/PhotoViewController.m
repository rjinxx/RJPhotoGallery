//
//  PhotoViewController.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoDataSource.h"
#import "PhotoCell.h"

@interface PhotoViewController () <UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectView;
@property (nonatomic, strong) PhotoDataSource *dataSource;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:self.albumObj.name];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.collectView collectionViewLayout];
    [layout setItemSize:PHOTO_LIST_SIZE];
    
    CellConfigureBlock configureCell = ^(PhotoCell *cell, id asset)
    {
        NSInteger cTag = cell.tag; // to determin if cell is reused
        
        [[ImageDataAPI sharedInstance] getThumbnailForAssetObj:asset
                                                      withSize:PHOTO_LIST_SIZE
                                                    completion:^(BOOL ret, UIImage *image)
        {
            if (cell.tag == cTag) [cell configureForImage:image];
        }];
    };
    
    PhotoDataSource *pDataSource = [[PhotoDataSource alloc] initWithCellIdentifier:@"PhotoCell"
                                                                configureCellBlock:configureCell];
    self.collectView.dataSource = pDataSource; [self setDataSource:pDataSource];
    
    if ([[ImageDataAPI sharedInstance] haveAccessToPhotos]) [self loadPhotos];
}

- (void)loadPhotos
{
    [[ImageDataAPI sharedInstance] getPhotosWithGroup:self.albumObj completion:^(BOOL ret, id obj)
    {
        self.dataSource.items = (NSMutableArray *)obj;
        // dispatch_async(dispatch_get_main_queue(), ^
        // {
        [self.collectView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.collectView setContentInset:UIEdgeInsetsMake(0, 0, 65/**SIZE_FACTOR*/, 0)];
        [self.collectView reloadData];
        // dispatch_async(dispatch_get_main_queue(), ^
        // {
        if ([self.dataSource.items count] == 0)
        {
            if ([self.navigationController.visibleViewController isKindOfClass:[self class]])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            return; // empty album, return and do not need count label.
        }
        /*
        [self.collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource.items count]-1
                                        inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionBottom
                                         animated:NO];
        */
        // add photo count tips
        int rowNum = (int)([self.dataSource.items count] + 4 - 1) / 4;
        CGFloat yOffset = 17/3.f + rowNum*78.5*SIZE_FACTOR + (rowNum-1)*2;
        UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, PSCREEN_WIDTH, 65)];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[self.dataSource.items count],
                                                  NSLocalizedString(@"Photos", nil)]];
        [self.collectView addSubview:label]; [label setHidden:([self.dataSource.items count] < 2)];
        // });
        // });
    }];
}

#pragma mark - CollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id asset = [self.dataSource itemAtIndexPath:indexPath];
    
    if (asset == nil) return;
    
    [[ImageDataAPI sharedInstance] getImageForPhotoObj:asset
                                              withSize:CGSizeMake(600, 600)
                                            completion:^(BOOL ret, UIImage *image)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDidSelectNotification"
                                                            object:image];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[ImageDataAPI sharedInstance] stopEnumeratePhoto:YES];
}

@end
