//
//  UIViewController+Popup.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Popup)

- (void)showSuccessMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)errorMessage;

@end
