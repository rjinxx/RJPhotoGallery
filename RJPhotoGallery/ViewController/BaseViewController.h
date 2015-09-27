//
//  BaseViewController.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDataAPI.h"

#define PSCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SIZE_FACTOR     [UIScreen mainScreen].bounds.size.width / 320.f
#define PHOTO_LIST_SIZE CGSizeMake(78.5 * SIZE_FACTOR, 78.5 * SIZE_FACTOR)

@interface BaseViewController : UIViewController
{
    dispatch_queue_t serialPGQueue;
}

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *idView;

- (void)showIndicatorView;
- (void)hideIndicatorView;

@end
