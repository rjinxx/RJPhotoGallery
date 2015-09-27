//
//  MomentViewController.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "MomentViewController.h"
#import "MomentCell.h"
#import "MomentDataSource.h"
#import "MomentFlowLayout.h"
#import "MomentCollection.h"

@interface MomentViewController () <UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *momentView;
@property (nonatomic, strong) MomentDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray   *backupArr;

@end

@implementation MomentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    MomentFlowLayout *layout = (MomentFlowLayout *)[self.momentView collectionViewLayout];
    [layout setItemSize:PHOTO_LIST_SIZE];
    [layout setHeaderReferenceSize:CGSizeMake(PSCREEN_WIDTH, 48)];
    
    CellConfigureBlock configureCell = ^(MomentCell *cell, id asset)
    {
        NSInteger cTag = cell.tag; // to determin if cell is reused
        
        [[ImageDataAPI sharedInstance] getThumbnailForAssetObj:asset
                                                      withSize:PHOTO_LIST_SIZE
                                                    completion:^(BOOL ret, UIImage *image)
        {
            if (cell.tag == cTag) [cell configureForImage:image];
        }];
    };
    
    MomentDataSource *pDataSource = [[MomentDataSource alloc] initWithCellIdentifier:@"MomentCell"
                                                                    headerIdentifier:@"MomentHeader"
                                                                  configureCellBlock:configureCell];
    self.momentView.dataSource = pDataSource; [self setDataSource:pDataSource];
    
    if ([[ImageDataAPI sharedInstance] haveAccessToPhotos]) [self loadMomentElements];
}

- (void)loadMomentElements
{
    [self showIndicatorView];
    
    dispatch_async(serialPGQueue, ^
    {
        [[ImageDataAPI sharedInstance] getMomentsWithBatchReturn:YES
                                                       ascending:NO
                                                      completion:^(BOOL done, id obj)
        {
            NSMutableArray *dArr = (NSMutableArray *)obj;
            
            if (dArr != nil && [dArr count])
            {
                if (!self.momentView.dragging && !self.momentView.decelerating)
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        if (done) {[self hideIndicatorView];}
                                                       
                        [self reloadWithData:dArr];
                    });
                }
                else
                {
                    if (done) {self.backupArr = dArr; [self hideIndicatorView];}
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (done) {[self hideIndicatorView];}
                });
            }
        }];
    });
}

#pragma mark - Reload CollectView
- (void)reloadWithData:(NSMutableArray *)data
{
    [self.dataSource.items removeAllObjects];
    [self.dataSource.items addObjectsFromArray:data];
    [self.momentView reloadData]; [data removeAllObjects];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && self.backupArr)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadWithData:self.backupArr];
            self.backupArr = nil; // done refresh
        });
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.backupArr)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadWithData:self.backupArr];
            self.backupArr = nil; // done refresh
        });
    }
}

#pragma mark - CollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MomentCollection *group  = [self.dataSource.items objectAtIndex:indexPath.section];
    
    id asset = group.assetObjs[indexPath.row]; if (!asset) return;
    
    [[ImageDataAPI sharedInstance] getImageForPhotoObj:asset
                                              withSize:CGSizeMake(600, 600)
                                            completion:^(BOOL ret, UIImage *image)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDidSelectNotification"
                                                            object:image];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
