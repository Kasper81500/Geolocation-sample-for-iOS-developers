//
//  UIButtonWithImageAspectFit.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/10/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "UIButtonWithImageAspectFit.h"

@implementation UIButtonWithImageAspectFit

- (void) awakeFromNib {
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

@end
