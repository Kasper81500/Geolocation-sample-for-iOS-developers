//
//  ConfirmViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "ConfirmViewController.h"
#import "AvatarViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>
#import "ContactsViewController.h"

@interface ConfirmViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfCode;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tfCode.delegate = self;
    [self.tfCode becomeFirstResponder];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [self.tfCode becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = -1*keyboardSize.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - IBActions

- (IBAction)clickConfirm:(id)sender {
    NSLog(@"Confirming it");
    NSString *code = _tfCode.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] confirmPhone:code
        withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                /*
                AvatarViewController *avatarVC = [storyboard instantiateViewControllerWithIdentifier:@"avatarVC"];
                avatarVC.hideBackButton = TRUE;
                avatarVC.showNextButton = TRUE;
                [self.navigationController pushViewController:avatarVC animated:YES];
                 */
                
                ContactsViewController *contactsVC = [storyboard instantiateViewControllerWithIdentifier:@"contactsView"];
                [self.navigationController pushViewController:contactsVC animated:YES];
                
            } else {
                if (errorInfo) {
                    [self showErrorMessage:errorInfo];
                }
            }
        }];
    
}

- (IBAction)clickResend:(id)sender {
    NSLog(@"Resending it");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] verifyResend:^(BOOL success, id result, NSString *errorInfo) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                 [self showSuccessMessage:@"Verification code has been sent again."];
             } else {
                 if (errorInfo) {
                     [self showErrorMessage:errorInfo];
                 }
             }
         }];
}

#pragma mark - UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
