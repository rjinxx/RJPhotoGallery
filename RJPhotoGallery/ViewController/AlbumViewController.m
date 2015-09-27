//
//  AlbumViewController.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "AlbumViewController.h"
#import "PhotoViewController.h"
#import "AlbumDataSource.h"
#import "AlbumCell.h"

@interface AlbumViewController () <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *albumView;
@property (nonatomic, strong) AlbumDataSource *dataSource;
@property (nonatomic, strong) AlbumObj *sampleObj;

@end

@implementation AlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CellConfigureBlock configCell = ^(AlbumCell *cell, AlbumObj *group)
    {
        if (nil == group.posterImage)
        {
            NSInteger cTag = cell.tag; // to determin if cell is reused
            
            [[ImageDataAPI sharedInstance] getPosterImageForAlbumObj:group
                                                          completion:^(BOOL ret, id obj)
            {
                group.posterImage = (UIImage *)obj;
                 
                if (cell.tag == cTag) [cell configureWithAlbumObj:group];
            }];
        }
        else
        {
            [cell configureWithAlbumObj:group];
        }
    };
    
    AlbumDataSource *aDataSource = [[AlbumDataSource alloc] initWithCellIdentifier:@"AlbumCell"
                                                                configureCellBlock:configCell];
    self.albumView.dataSource = aDataSource; [self setDataSource:aDataSource];
    
    if ([[ImageDataAPI sharedInstance] haveAccessToPhotos]) [self loadAlbums];
}

- (void)loadAlbums
{
    [self showIndicatorView];
    
    dispatch_async(serialPGQueue, ^
    {
        [[ImageDataAPI sharedInstance] getAlbumsWithCompletion:^(BOOL ret, id obj)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.dataSource.items = (NSMutableArray *)obj;
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self hideIndicatorView];
                    
                    if (ret) [self.albumView reloadData];
                });
            });
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AlbumCell *cell        = (AlbumCell *)sender;
    NSIndexPath *indexPath = [self.albumView indexPathForCell:cell];
    PhotoViewController *photoVC = segue.destinationViewController;
    photoVC.albumObj  = [self.dataSource itemAtIndexPath:indexPath];
}

@end
