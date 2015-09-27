//
//  BaseViewController.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    serialPGQueue = dispatch_queue_create("com.rylan", DISPATCH_QUEUE_SERIAL);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    // prevent user action before viewDidApperar
    [self.navigationController.view setUserInteractionEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // restore interaction. Cannt respond back action before viewDidAppear
    [self.navigationController.view setUserInteractionEnabled:YES];
}

#pragma mark - UIActivityIndicatorView
- (void)showIndicatorView
{
    [self.idView setHidden:NO]; [self.idView startAnimating];
}

- (void)hideIndicatorView
{
    [self.idView stopAnimating]; [self.idView setHidden:YES];
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
