//
//  GalleryViewController.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "GalleryViewController.h"
#import "Utility.h"
#import "ContainerViewController.h"

#define SELECT_BG_COLOR     [Utility getColorWith:@"#9f80c4" corlorAlpha:1.f]
#define DESELECT_BG_COLOR   [Utility getColorWith:@"#f1ecf5" corlorAlpha:1.f]
#define SELECT_TEXT_COLOR   [Utility getColorWith:@"#ffffff" corlorAlpha:1.f]

@interface GalleryViewController ()

@property (nonatomic, weak) IBOutlet UIView   *bottomView;
@property (nonatomic, weak) IBOutlet UIButton *moment;
@property (nonatomic, weak) IBOutlet UIButton *album;

@property (nonatomic, weak) ContainerViewController *containerViewController;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:NSLocalizedString(@"Photos", nil)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.moment setTitle:NSLocalizedString(@"Moment", nil)
                 forState:UIControlStateNormal];
    [self.album setTitle:NSLocalizedString(@"Album", nil)
                forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImagePicker:)
                                                 name:@"ImageDidSelectNotification"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

#pragma mark - Click Action
- (IBAction)momentAction:(id)sender
{
    BOOL ret = [self.containerViewController swapToViewControllerWithSigueID:SegueIdentifierMoment];
    
    if (ret == NO) return; // transition in progress or failed...
    
    [self.moment setBackgroundColor:[UIColor blackColor]];
    [self.moment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.album setBackgroundColor:DESELECT_BG_COLOR];
    [self.album setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (IBAction)albumAction:(id)sender
{
    BOOL ret = [self.containerViewController swapToViewControllerWithSigueID:SegueIdentifierAlbum];
    
    if (ret == NO) return; // transition in progress or failed...
    
    [self.moment setBackgroundColor:DESELECT_BG_COLOR];
    [self.moment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.album setBackgroundColor:[UIColor blackColor]];
    [self.album setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Photo Selection
- (void)didReceiveImagePicker:(NSNotification *)notification
{
    UIImage *image = [notification object];
    
    NSLog(@"%@", NSStringFromCGSize(image.size));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
    }
}

@end
