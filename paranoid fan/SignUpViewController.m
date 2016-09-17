//
//  SignUpViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SignUpViewController.h"
#import "VerifyViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "PhotoManager.h"
#import <Google/Analytics.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPass;
@property (weak, nonatomic) IBOutlet UITextField *tfBirthday;

@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) MBProgressHUD *hub;

@property (strong, nonatomic) PhotoManager *photoManager;


@end

@implementation SignUpViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tfName setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfEmail setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfBirthday setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfPass setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(birthdayValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.tfBirthday.inputView = datePicker;
    
    self.btnAvatar.imageView.layer.cornerRadius = 0.5 * CGRectGetWidth(self.btnAvatar.imageView.bounds);
    
    self.tfName.delegate = self;
    self.tfEmail.delegate = self;
    self.tfBirthday.delegate = self;
    self.tfPass.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SignUp Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.tfName becomeFirstResponder];
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

- (void)keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = keyboardSize.height;
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}



#pragma mark - IBACtions

- (IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSignup:(id)sender
{
    
    NSString *name = self.tfName.text;
    NSString *email = self.tfEmail.text;
    NSString *pass = self.tfPass.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[Engine sharedEngine] dataManager] signupUserWithEmail:email
                                                        name:name
                                                 andPassword:pass
                                                   birdthday:self.selectedDate
                                                withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                                                    if (success) {
                                                        NSInteger userID = [result integerValue];
                                                        
                                                        if (self.selectedPhoto) {
                                                            [self postUserAvatarForUser:userID];
                                                        } else {
                                                            [self openNextScreen];
                                                        }
                                                    } else if (errorInfo) {
                                                        [self showErrorMessage:errorInfo];
                                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    }
                                                }];
}

- (IBAction)clickAvatar:(id)sender
{
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    
    [self.photoManager selectPhotoFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedPhoto = image;
            [self.btnAvatar setImage:self.selectedPhoto forState:UIControlStateNormal];
        } else {
            [self setDefaultAvatar];
        }
    }];
}

- (void)birthdayValueChanged:(UIDatePicker *)picker
{
    [self setBirthDayDate:picker.date];
}

#pragma mark - Helpers

- (void)setDefaultAvatar
{
    [self.btnAvatar setImage:[UIImage imageNamed:@"your_picture"] forState:UIControlStateNormal];
}

- (void)setBirthDayDate:(NSDate *)date
{
    self.selectedDate = date;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *theDate = [dateFormat stringFromDate:date];
    
    self.tfBirthday.text = theDate;
}

- (void)postUserAvatarForUser:(NSInteger)userID
{
        [[[Engine sharedEngine] dataManager] updateUserMapAvatar:self.selectedPhoto
                                                      withUserID:userID
                                                    withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                                                        if (success) {
                                                            [[[[Engine sharedEngine] settingManager] user] setMapAvatar:result];
                                                            [[[Engine sharedEngine] settingManager] saveUser];
                                                        }
                                                        [self openNextScreen];
                                                    }];
}

- (void)openNextScreen
{
    [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"kNewSignup"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VerifyViewController *verifyVC = [storyboard instantiateViewControllerWithIdentifier:@"enterNumber"];
    [self.navigationController pushViewController:verifyVC animated:NO];
}

#pragma mark - UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
