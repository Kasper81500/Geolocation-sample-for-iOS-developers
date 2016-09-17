//
//  HideNotificationVIew.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/20/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "HideNotificationVIew.h"
#import "Constants.h"

@implementation HideNotificationVIew

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [self addGestureRecognizer:tapGR];
    
    self.userInteractionEnabled = YES;
}

- (void)viewTaped:(UITapGestureRecognizer *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHidePopup object:self];
}


@end
