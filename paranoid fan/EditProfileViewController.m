//
//  EditProfileViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Engine.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import <UIImageView+AFNetworking.h>
#import "UIViewController+Popup.h"
#import "PhotoManager.h"
#import <Google/Analytics.h>

@interface EditProfileViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfBirthday;

@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) MBProgressHUD *hub;

@property (strong, nonatomic) PhotoManager *photoManager;

@end

@implementation EditProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tfName.delegate = self;
    self.tfEmail.delegate = self;
    self.tfBirthday.delegate = self;
        
    [self.tfName setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfEmail setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    [self.tfBirthday setValue:kPlaceholderBlue forKeyPath:@"_placeholderLabel.textColor"];
    
    self.btnAvatar.clipsToBounds = YES;
    self.btnAvatar.imageView.layer.cornerRadius = 0.5 * CGRectGetWidth(self.btnAvatar.imageView.bounds);
    
    User *user = [Engine sharedEngine].settingManager.user;
    
    self.tfName.text = user.fullname;
    self.tfEmail.text = user.emailAddress;
    [self setBirthDayDate:user.birthday];
    
    if (user.mapAvatar) {
//        [self.btnAvatar setImageWithURL:[NSURL URLWithString:user.mapAvatar] placeholderImage:[UIImage imageNamed:@"your_picture"]];
    } else {
        [self setDefaultAvatar];
    }
    
    

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(birthdayValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.tfBirthday.inputView = datePicker;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Edit Profile View Controller"];
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
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = keyboardSize.height;
}

- (void)keyboardWasHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}


#pragma mark - Actions

- (IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] updateUserProfileWithName:self.tfName.text
                                                             email:self.tfEmail.text
                                                            andDob:self.selectedDate
                                                      withCallBack:
     ^(BOOL success, id result, NSString *errorInfo) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (success) {
             User *user = [Engine sharedEngine].settingManager.user;
             
             user.fullname = self.tfName.text;
             user.emailAddress = self.tfEmail.text;
             user.birthday = self.selectedDate;
             
             [[Engine sharedEngine].settingManager setUser:user];
             
             [self showSuccessMessage:result];
         }
     }];
    
    if (self.selectedPhoto) {
        [[[Engine sharedEngine] dataManager] updateUserMapAvatar:self.selectedPhoto
                                                    withCallBack:
         ^(BOOL success, id result, NSString *errorInfo) {
             if (success) {
                 User *user = [Engine sharedEngine].settingManager.user;
                 
                 user.mapAvatar = result;
                 
                 [[Engine sharedEngine].settingManager setUser:user];
                 
                 [self showSuccessMessage:errorInfo];
             }
         }];
    }
}


#pragma mark UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
            self.selectedPhoto = nil;
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
                                                }];
    
}


@end
