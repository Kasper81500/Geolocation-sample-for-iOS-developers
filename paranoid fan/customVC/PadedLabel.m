//
//  PadedLabel.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/1/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#define PADDINGHORIZENTAL 8.0
#define PADDINGVERITCAL 6.0
#define CORNER_RADIUS 3.0

#import "PadedLabel.h"

@implementation PadedLabel

//- (id)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.edgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
//    }
//    return self;
//}
//
//- (void)drawTextInRect:(CGRect)rect {
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
//}

/*
- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 3.0;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [super drawRect:rect];
}

- (void) drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {5,5,5,5};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
 */

- (void)drawRect:(CGRect)rect {

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CORNER_RADIUS;
    UIEdgeInsets insets = {PADDINGVERITCAL, PADDINGHORIZENTAL, PADDINGVERITCAL, PADDINGHORIZENTAL};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize) intrinsicContentSize {
    
    CGSize intrinsicSuperViewContentSize = [super intrinsicContentSize] ;
    intrinsicSuperViewContentSize.width += PADDINGHORIZENTAL * 2 ;
    intrinsicSuperViewContentSize.height += PADDINGVERITCAL * 2 ;
  //  NSLog(@"Height of: %f", intrinsicSuperViewContentSize.height);
    return intrinsicSuperViewContentSize ;
}


/*
- (void)setBounds:(CGRect)bounds {
    if (bounds.size.width != self.bounds.size.width) {
        [self setNeedsUpdateConstraints];
    }
    [super setBounds:bounds];
}

- (void)updateConstraints {
    if (self.preferredMaxLayoutWidth != self.bounds.size.width) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
    }
    [super updateConstraints];
}
 */

@end
