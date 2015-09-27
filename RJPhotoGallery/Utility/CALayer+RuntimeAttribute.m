//
//  CALayer+RuntimeAttribute.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "CALayer+RuntimeAttribute.h"

@implementation CALayer (RuntimeAttribute)

- (void)setBorderIBColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

- (UIColor *)borderIBColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
