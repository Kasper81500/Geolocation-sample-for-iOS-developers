//
//  VerifyViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "VerifyViewController.h"
#import "ConfirmViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>

@interface VerifyViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfNumber;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfNumber.delegate = self;
    [self.tfNumber becomeFirstResponder];
    // Do any additional setup after loading the view.
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
    [self.tfNumber becomeFirstResponder];
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
    NSLog(@"%f", keyboardSize.height);
    self.bottomConstraint.constant = -1*keyboardSize.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - IBActions

- (IBAction)clickVerify:(id)sender {
    
    NSLog(@"Verifying it");
    NSString *number = _tfNumber.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] verifyPhone:number
                                               withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   if (success) {
                                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       ConfirmViewController *confirmVC = [storyboard instantiateViewControllerWithIdentifier:@"verifyNumber"];
                                                       [self.navigationController pushViewController:confirmVC animated:NO];
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
