//
//  ChangePasswordViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Constants.h"
#import "UIViewController+Popup.h"
#import "Engine.h"
#import <Google/Analytics.h>

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfOldPass;
@property (weak, nonatomic) IBOutlet UITextField *tfNewPass;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPass;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tfOldPass.delegate = self;
    self.tfNewPass.delegate =self;
    self.tfConfirmPass.delegate =self;
    
    [self.tfOldPass becomeFirstResponder];
    [self.tfOldPass setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfNewPass setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfConfirmPass setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Change Password Controller"];
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



#pragma mark - Actions

- (IBAction)clickBtnSave:(id)sender {
    NSString *oldPass = self.tfOldPass.text;
    NSString *newPass = self.tfNewPass.text;
    NSString *confirmPass = self.tfConfirmPass.text;
    
    if (![newPass isEqualToString:confirmPass]) {
        [self showErrorMessage:@"Please confirm your new password"];
        return;
    }
    
    [[[Engine sharedEngine] dataManager] updateUserPassword:oldPass
                                                 toPassword:newPass
                                               withCallBack:^(BOOL success, id result, NSString *errorInfo)
    {
        if (success) {
            [self showSuccessMessage:result];
        } else {
            [self showErrorMessage:errorInfo];
        }
        
        self.tfOldPass.text = nil;
        self.tfNewPass.text = nil;
        self.tfConfirmPass.text = nil;
    }];
}

- (IBAction)clickBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
