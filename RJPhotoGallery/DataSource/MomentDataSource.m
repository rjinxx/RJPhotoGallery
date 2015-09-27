//
//  MomentDataSource.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "MomentDataSource.h"
#import "MomentCollection.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#define PSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation MomentDataSource

- (id)initWithCellIdentifier:(NSString *)cellID
            headerIdentifier:(NSString *)headerID
          configureCellBlock:(CellConfigureBlock)block
{
    self.headerIdentifier = headerID;
    
    return [self initWithCellIdentifier:cellID configureCellBlock:block];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.items count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MomentCollection *group = [self.items objectAtIndex:section];
    
    return [group.assetObjs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                           forIndexPath:indexPath];
    
    MomentCollection *group = [self.items objectAtIndex:indexPath.section];
    
    // set tag for reuse determination
    cell.tag = indexPath.section * 10 + indexPath.row;
    
    id item = group.assetObjs[indexPath.row];
    
    self.block(cell, item); return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.headerIdentifier forIndexPath:indexPath];
        
        while ([headerView.subviews lastObject] != nil)
        {
            [(UIView*)[headerView.subviews lastObject] removeFromSuperview];
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PSCREEN_WIDTH, 48)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, PSCREEN_WIDTH-8, 48)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        
        MomentCollection *group = (MomentCollection *)[self.items objectAtIndex:indexPath.section];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%lu-%lu-%lu",
                                                      (unsigned long)group.year,
                                                      (unsigned long)group.month,
                                                      (unsigned long)group.day]];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit   |
                                                                                NSMonthCalendarUnit |
                                                                                NSYearCalendarUnit
                                                                       fromDate:[NSDate date]];
        NSUInteger month = [components month];
        NSUInteger year  = [components year];
        NSUInteger day   = [components day];
        
        NSString *localization = [NSBundle mainBundle].preferredLocalizations.firstObject;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
        
        dateFormatter.locale    = locale;
        dateFormatter.dateStyle = kCFDateFormatterLongStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        
        if (year == group.year)
        {
            NSString *longFormatWithoutYear = [NSDateFormatter dateFormatFromTemplate:@"MMMM d"
                                                                              options:0
                                                                               locale:locale];
            [dateFormatter setDateFormat:longFormatWithoutYear];
        }
        
        NSString *resultString = [dateFormatter stringFromDate:date];
        
        if (year == group.year && month == group.month)
        {
            if (day == group.day)
            {
                resultString = NSLocalizedString(@"Today", nil);
            }
            else if (day - 1 == group.day)
            {
                resultString = NSLocalizedString(@"Yesterday", nil);
            }
        }
        
        [label setText:resultString]; [view addSubview:label];
        [headerView addSubview:view]; reusableview = headerView;
    }
    
    return reusableview;
}

@end
