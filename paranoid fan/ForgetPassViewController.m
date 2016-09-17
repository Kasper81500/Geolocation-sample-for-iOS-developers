//
//  ForgetPassViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ForgetPassViewController.h"
#import "Engine.h"
#import "Constants.h"
#import "UIViewController+Popup.h"
#import <Google/Analytics.h>

@interface ForgetPassViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ForgetPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tfEmail setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Forget Password Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
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
    [self.tfEmail becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = keyboardSize.height;
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
}

#pragma mark - IBActions

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSend:(id)sender
{   
    [[[Engine sharedEngine] dataManager] forgotPasswordWithEmail:self.tfEmail.text withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            [self showSuccessMessage:result];
        } else {
            [self showErrorMessage:errorInfo];
        }
    }];
}

@end
