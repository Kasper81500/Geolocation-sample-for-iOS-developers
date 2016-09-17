//
//  UIViewController+Popup.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "UIViewController+Popup.h"

@implementation UIViewController (Popup)

- (void)showSuccessMessage:(NSString *)message
{
    [self showMessageWithTitle:@"Success" andMessage:message];
}

- (void)showErrorMessage:(NSString *)errorMessage
{
    [self showMessageWithTitle:@"Error" andMessage:errorMessage];
}

- (void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    if (message && [message isKindOfClass:[NSString class]]) {
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}


@end
