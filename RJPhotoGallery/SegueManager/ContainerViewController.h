//
//  ContainerViewController.h
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SegueIdentifierMoment @"embedMoment"
#define SegueIdentifierAlbum  @"embedAlbum"

@interface ContainerViewController : UIViewController

- (BOOL)swapToViewControllerWithSigueID:(NSString *)ID;

@end
