//
//  LoginViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPassViewController.h"
#import "SocialViewController.h"
#import "VerifyViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "User.h"
#import <Google/Analytics.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    [self.tfEmail becomeFirstResponder];
    
    [self.tfEmail setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfPassword setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];

    self.tfEmail.delegate = self;
    self.tfPassword.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login Controller"];
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
    [self.view layoutIfNeeded];
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}



#pragma mark - IBActions

- (IBAction)clickforgetBtn:(id)sender {
    [self.tfEmail resignFirstResponder];
    [self.tfPassword resignFirstResponder];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ForgetPassViewController *forgetpassVC = [storyboard instantiateViewControllerWithIdentifier:@"forgetpassVC"];
    [self.navigationController pushViewController:forgetpassVC animated:YES];
}

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickLogin:(id)sender {
    
    NSString *email = _tfEmail.text;
    NSString *pass = _tfPassword.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] loginUserWithEmail:email
                                                andPassword:pass
               withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                   if (success) {
                       if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"phone_verified"] isEqualToString:@"Yes"]) {

                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                           UIViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
                           [self.navigationController pushViewController:mapVC animated:NO];
                       }
                       else {
                           
                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                           VerifyViewController *verifyVC = [storyboard instantiateViewControllerWithIdentifier:@"enterNumber"];
                           [self.navigationController pushViewController:verifyVC animated:NO];
                       }
                       
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
