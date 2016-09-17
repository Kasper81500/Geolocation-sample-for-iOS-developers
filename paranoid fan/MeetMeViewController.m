//
//  MeetMeViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/21/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "MeetMeViewController.h"
#import "AddressBookTableViewController.h"
#import "Engine.h"
#import "User.h"
#import <MapKit/MapKit.h>
#import "Constants.h"
#import <Google/Analytics.h>
#import "MeetMeListViewController.h"

#define kSegueAddressBook   @"addressBook"
#define kDefaultText    @"Hi! I'm using the Paranoid Fan app to invite you to meet me at this location:"

@interface MeetMeViewController ()<AddressBookTableViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSArray *usersToInvite;


@end

@implementation MeetMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tagGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTaped:)];
    [self.view addGestureRecognizer:tagGR];
    
    CLLocation *location = [[[Engine sharedEngine] settingManager].user getLocation];
    
    self.placeHolderLabel.hidden = YES;
    self.textView.text = [NSString stringWithFormat:@"%@ http://paranoidfan.com/meetme.php?latittude=%f&longitude=%f", kDefaultText, location.coordinate.latitude,location.coordinate.longitude];;
//    self.textView.layer.borderWidth = 1.0;
//    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Meet me View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Gestures

- (void)backgroundTaped:(UITapGestureRecognizer *)tapGR
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    
    self.textView.text = kDefaultText;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHidePopup object:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.placeHolderLabel.hidden = textView.text.length == 0 ? NO : YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.placeHolderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.textView.text.length == 0) {
        self.placeHolderLabel.hidden = NO;
    }
}

#pragma mark - Notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self updateUIWithKeyboardHeight:keyboardSize.height andDuration:duration];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self updateUIWithKeyboardHeight:0 andDuration:0.25];
}

- (void)updateUIWithKeyboardHeight:(CGFloat)keyboardHeight andDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         self.bottomConstraint.constant = keyboardHeight;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(self.textView.frame) - 50) animated:YES];
                         }
                     }];
}

#pragma mark - AddressBookTableViewControllerDelegate

- (void)addressBookController:(AddressBookTableViewController *)addressBookController didSelectUsers:(NSArray *)users
{
    BOOL hasPeopleToInvite = users.count > 0;
    self.usersToInvite = users;
    
    if (hasPeopleToInvite) {
        
        CLLocation *location = [[[Engine sharedEngine] settingManager].user getLocation];
        
        [[[Engine sharedEngine] shareManager] inviteUsers:users
                                             withLocation:location
                                            customMessage:self.textView.text
                                           fromController:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueAddressBook]) {
        AddressBookTableViewController *nextVC = (AddressBookTableViewController *)[(UINavigationController *)segue.destinationViewController visibleViewController];
        nextVC.addressBookDelegate = self;
        
        [self.textView resignFirstResponder];
    }
}

#pragma mark - Meet Me

- (IBAction)shareLink:(id)sender {
    
    /*
    NSString *shareString = self.textView.text;
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:shareString];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         NSLog(@"completed.");
                     }];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeetMeListViewController *meetMeListVC = [storyboard instantiateViewControllerWithIdentifier:@"meetmelist"];
    meetMeListVC.meetMeText = self.textView.text;
    [self.navigationController pushViewController:meetMeListVC animated:YES];
    
}

@end
