//
//  ButtonWithBottomText.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 3/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "ButtonWithBottomText.h"

@implementation ButtonWithBottomText

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    CGRect frame = self.titleLabel.frame;
    frame.size.height = 20;
    self.titleLabel.frame = frame;
    [self.imageView setContentMode:UIViewContentModeBottom];
    
    if (self.bottomTexhHeight == 0) {
        self.bottomTexhHeight = 20;
    }
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect rect = contentRect;
    rect.size.height -= self.bottomTexhHeight;
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect rect = contentRect;
    rect.origin.y = contentRect.size.height - self.bottomTexhHeight;
    rect.size.height = self.bottomTexhHeight;
    return rect;
}

@end
