//
//  CreatePinViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "CreatePinViewController.h"
#import "SKTagView.h"
#import "Engine.h"
#import "User.h"
#import <APContact.h>
#import "NSArray+JSON.h"
#import "SKTagView.h"
#import "Constants.h"
#import "Engine.h"
#import "AddressBookTableViewController.h"
#import "PhotoManager.h"
#import "TagsViewController.h"
#import "UIViewController+Popup.h"
#import "MeetMeListViewController.h"

#define kSegueAddressBook   @"addressBook"
#define kSegueTags          @"tagsView"


#define kDefaultHeightForTag        40
#define kDefaultScrollHeight    344
#define kBottonSpace            56
#define kTopInset               0

@import GoogleMaps;

@interface CreatePinViewController ()<UITextFieldDelegate,AddressBookTableViewControllerDelegate, TagsViewControllerDelegate, GMSAutocompleteViewControllerDelegate, UIGestureRecognizerDelegate, MeetMeListViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *pinTitle;
@property (nonatomic, weak) IBOutlet UITextField *titleTF;
@property (nonatomic, weak) IBOutlet UITextField *detailTF;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *meetmeButton;
@property (nonatomic, weak) IBOutlet UIImageView *iconIV;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *tagsContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomScrollConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagsContainerHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *iconWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagsViewHeightConstraint;

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableArray *selectedReceivers;
@property (strong, nonatomic) NSMutableArray *selectedGroups;

@property (strong, nonatomic) NSArray *tagItems;
@property (strong, nonatomic) NSArray *usersToInvite;
@property (strong, nonatomic) UIImage *selectedImage;

@property (strong, nonatomic) PhotoManager *photoManager;
@property (nonatomic, weak) NSDate* selectedDate;

@property (nonatomic) CGFloat tagViewMinHeight;
@property (nonatomic) BOOL isKeyboardVisible;
@property (nonatomic) NSInteger rating;

@property (nonatomic, weak) IBOutlet UILabel *pinLocation;
@property (nonatomic, weak) IBOutlet UILabel *pinDateTime;
@property (strong, nonatomic) GMSPlace *selectedPlace;
@property (strong, nonatomic) NSString *selectedPlaceAddress;

@end

@implementation CreatePinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"menu_v2_%@", self.pinType]];
    
    self.iconIV.image = img;
    
    _iconWidthConstraint.constant = img.size.width;
    
    _pinTitle.text = self.pinType;
    
    [self setSelectedMeetmeButton:NO];
    
    self.tagViewMinHeight = kDefaultHeightForTag;
    
    if ([_menuType isEqualToString:@"venusMenu"])
        self.tagsContainerView.hidden = YES;
    else
        self.tagsContainerView.hidden = NO;

    UITapGestureRecognizer *tapLocationGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlaces)];
    tapLocationGestureRecognizer.delegate = self;
    tapLocationGestureRecognizer.numberOfTouchesRequired = 1;
    [self.pinLocation addGestureRecognizer:tapLocationGestureRecognizer];
    
    UITapGestureRecognizer *tapDateTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDateTimePicker)];
    tapDateTimeGestureRecognizer.delegate = self;
    tapDateTimeGestureRecognizer.numberOfTouchesRequired = 1;
    [self.pinDateTime addGestureRecognizer:tapDateTimeGestureRecognizer];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 20)];
    self.titleTF.leftView = paddingView;
    self.titleTF.leftViewMode = UITextFieldViewModeAlways;
    
    self.rating = 0;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[Engine sharedEngine].settingManager.user getLocation] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             
             self.selectedPlaceAddress = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
             
             NSLog(@"Current Address: %@", self.selectedPlaceAddress);
         }
         
     }];
    
    self.groups = [[NSMutableArray alloc] init];
    self.selectedContacts = [[NSMutableArray alloc] init];
    self.selectedReceivers = [[NSMutableArray alloc] init];
    self.selectedGroups = [[NSMutableArray alloc] init];
    
    [[[Engine sharedEngine] dataManager] getMyGroupsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            
            self.groups = [result mutableCopy];
            
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self updateUIWithKeyboardHeight:(keyboardSize.height - kBottonSpace) andDuration:0.0];
}

- (void)keyboardDidShown:(NSNotification *)notification
{
    self.isKeyboardVisible = YES;
    [self updateTagsViewHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.isKeyboardVisible = NO;
    [self updateUIWithKeyboardHeight:0 andDuration:0.0];
    [self updateTagsViewHeight];
}

- (void)updateUIWithKeyboardHeight:(CGFloat)keyboardHeight andDuration:(CGFloat)duration
{

    [UIView animateWithDuration:duration animations:^{
      /*  self.bottomScrollConstraint.constant = keyboardHeight;
        
        CGFloat leftHeight = CGRectGetHeight(self.view.bounds) - self.bottomScrollConstraint.constant - kTopInset;
        
        if (leftHeight < kDefaultScrollHeight) {
            self.scrollHeightConstraint.constant = leftHeight;
        } else {
            self.scrollHeightConstraint.constant = kDefaultScrollHeight;
        }
        
        [self.view layoutIfNeeded];
       */
        
        CGRect newFrame = [self.view frame];
        
        if (keyboardHeight > 0 && newFrame.origin.y == 0)
            newFrame.origin.y -= keyboardHeight; 
        else if (keyboardHeight == 0 && newFrame.origin.y < 0)
            newFrame.origin.y = 0;
        
        [self.view setFrame:newFrame];
    }];
}



#pragma mark - IBAction

- (IBAction)fbClicked:(id)sender
{
    self.facebookButton.selected = !self.facebookButton.selected;
}

- (IBAction)twitterClicked:(id)sender
{
    self.twitterButton.selected = !self.twitterButton.selected;
}


- (IBAction)cameraClicked:(id)sender
{
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    [self.photoManager selectPhotoFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedImage = image;
        } else {
            self.selectedImage = nil;
        }
    }];
}

- (IBAction)submitClicked:(id)sender
{
    NSString *title = self.titleTF.text;
    NSString *detail = self.detailTF.text;
    double latitude = 0.0;
    double longitude = 0.0;

    if ([title isEqualToString:@""]) {
        [self showErrorMessage:@"Title for the pin is required."];
        return;
    }
    
    if ([self.pinLocation.text isEqualToString:@"Current Location"]) {
        latitude = [[Engine sharedEngine].settingManager.user getLocation].coordinate.latitude;
        longitude = [[Engine sharedEngine].settingManager.user getLocation].coordinate.longitude;
    }
    else {
        latitude = self.selectedPlace.coordinate.latitude;
        longitude = self.selectedPlace.coordinate.longitude;
    }
    
    [[[Engine sharedEngine] dataManager] addPinWithRatingPinType:self.pinType
                                                     title:title
                                                    rating:self.rating
                                                    detail:detail
                                                     photo:self.selectedImage
                                                      tags:self.tagItems
                                                     latitude:latitude
                                                    longitude:longitude
                                                 address:self.selectedPlaceAddress
                                                 dateTime:self.pinDateTime.text
                                                  groups:[self.selectedGroups componentsJoinedByString:@","]
                                               receivers:[self.selectedReceivers componentsJoinedByString:@","]
                                                       twittedID:@""
                                                      fbID:@""
                                              withCallBack:
     ^(BOOL success, id result, NSString *errorInfo) {
         if (success) {
             if (self.delegate) {
                 
                 Pin *pin = result;
                /*
                 if ([title isEqualToString:@""])
                     pin.mapPinTitle = self.pinType;
                 else*/
                 NSLog(@"%@:", title);
                     pin.mapPinTitle = title;
                 
                 if ([self.delegate respondsToSelector:@selector(createPinViewController:didAddPin:)]) {
                     [self.delegate createPinViewController:self didAddPin:pin];
                 }
                 
                 if ([self.delegate respondsToSelector:@selector(createPinViewController:wantShareViaFB:viaTwitter:withPin:)]) {
                     [self.delegate createPinViewController:self wantShareViaFB:self.facebookButton.selected viaTwitter:self.twitterButton.selected withPin:pin];
                 }
                 
                 if (self.selectedContacts.count) {
                     
                   
                     NSString *meetMeURL = [@"http://paranoidfan.com/meetme.php?" stringByAppendingFormat:@"latittude=%f&longitude=%f&type=%@&pid=%ld", pin.mapPinLatitude, pin.mapPinLongitude, [pin.mapPinType stringByReplacingOccurrencesOfString:@" " withString:@"_"], (long)pin.pinID];
                     
                     NSString *inviteMessage = [NSString stringWithFormat:@"Your friend, %@, ", [[[Engine sharedEngine] settingManager] user].fullname];
                     
                     if ([pin.mapPinType isEqualToString:@"Tailgate"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"has invited you to a tailgate via the Paranoid Fan app. Grab your stuff and get there now. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Partying"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"has just dropped a party pin on the Paranoid Fan map and wants you to come hang out! Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Game Showing"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"says they are showing a game at their location and wants you to come watch it. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Watch Party"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"has invited you to a game watching party using the Paranoid Fan app. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Celebrity"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"just saw a celebrity at his location using the Paranoid Fan app. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Playing"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"is playing a game and has invited you to come hang out. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Music"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"wants you to come listen to music. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Meetup"]) {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"has invited you to a meetup via the Paranoid Fan app. Details here: "];
                     }
                     else if ([pin.mapPinType isEqualToString:@"Treasure"]) {
                         
                         inviteMessage = [@"Surprises are in order! Your friend, " stringByAppendingFormat:@"%@ just dropped a treasure chest on the Paranoid Fan map. Find out where it’s at. Details here: ", [[[Engine sharedEngine]settingManager] user].fullname];
                     }
                     else {
                         
                         inviteMessage = [inviteMessage stringByAppendingFormat:@"just dropped a %@ pin on the Paranoid Fan map. Details here: ", pin.mapPinType];
                     }
                     
                     for (APContact *contact in self.selectedContacts) {
                         NSString *detailURL = meetMeURL;
                         
                         detailURL = [detailURL stringByAppendingFormat:@"&un=%@&up=%@", contact.name.firstName, contact.phones.firstObject.number];
                         
                         [[[Engine sharedEngine] dataManager] sendTextMessage:contact.phones.firstObject.number withMessage:[NSString stringWithFormat:@"%@ %@ ", inviteMessage, detailURL] withCallBack:nil];
                     }
                 }
                 
                 /*if ([self.delegate respondsToSelector:@selector(createPinViewController:wantInviteFriends:withPin:)]) {
                     [self.delegate createPinViewController:self wantInviteFriends:self.usersToInvite withPin:pin];
                 }*/
             }
             
         } else {
             if (self.delegate && [self.delegate respondsToSelector:@selector(createPinViewControllerFailureToAddPin:)]) {
                 [self.delegate createPinViewControllerFailureToAddPin:self];
             }
         }
     }];    
}

- (void) showPlaces {
    
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteFilter = nil;

    [self presentViewController:acController animated:YES completion:nil];
}

- (void) showDateTimePicker {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                          style:UIBarButtonItemStyleDone
                                         target:self
                                         action:@selector(closePickerView)];
    toolBar.items = @[flex, barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height, screenWidth, 356)];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    if (self.selectedDate != nil)
        [datePicker setDate:self.selectedDate];
    
    [datePicker addTarget:self action:@selector(selectedDateTime:) forControlEvents:UIControlEventValueChanged];
    
    UIView *datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-400, screenWidth, 400)];
    datePickerView.backgroundColor = [UIColor whiteColor];
    datePickerView.tag = 666;
    
    [datePickerView addSubview:toolBar];
    [datePickerView addSubview:datePicker];
    
    [self.view addSubview:datePickerView];
}

- (void) selectedDateTime:(UIDatePicker *)picker {
    
    self.selectedDate = picker.date;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, hh:mm a"];
    NSString *theDate = [dateFormat stringFromDate:picker.date];
    
    [self.pinDateTime setText:theDate];
}

- (void) closePickerView {
    
    [[self.view viewWithTag:666] removeFromSuperview];
}

#pragma mark - Google Places API Delegate

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    _selectedPlace = place;
    self.pinLocation.text = place.name;
    self.selectedPlaceAddress = [NSString stringWithFormat:@"%@, %@", place.name, place.formattedAddress];
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self updateTagsViewHeight];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateTagsViewHeight];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - AddressBookTableViewControllerDelegate

- (void)addressBookController:(AddressBookTableViewController *)addressBookController didSelectUsers:(NSArray *)users
{
    BOOL hasPeopleToInvite = users.count > 0;
   [self setSelectedMeetmeButton:hasPeopleToInvite];

    self.usersToInvite = users;
}

#pragma mark - TagsViewControllerDelegate

- (void)tagsViewController:(TagsViewController *)tagsVC didEndSelectingWithSize:(CGSize)tagsViewSize
{
     NSLog(@"End Selecting Tag View Height: %f", tagsViewSize.height);
    self.tagViewMinHeight = tagsViewSize.height;
    self.tagsContainerHeightConstraint.constant = tagsViewSize.height;
    
    CGFloat deltaHeight = tagsViewSize.height - kDefaultHeightForTag;
    self.scrollHeightConstraint.constant = kDefaultScrollHeight + deltaHeight;
    
    [self.view layoutIfNeeded];
}

- (void)tagsViewController:(TagsViewController *)tagsVC didSelectedTags:(NSArray *)tags
{
    self.tagItems = tags;
}

- (void)tagsViewController:(TagsViewController *)tagsVC didResize:(CGSize)tagsViewSize
{
    
    NSLog(@"did Resize Tag View Height: %f", tagsViewSize.height);
    self.tagViewMinHeight = tagsViewSize.height;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Calling Segue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:kSegueAddressBook]) {
        [self setSelectedMeetmeButton:NO];
        AddressBookTableViewController *nextVC = (AddressBookTableViewController *)[(UINavigationController *)segue.destinationViewController visibleViewController];
        nextVC.addressBookDelegate = self;
        nextVC.selectedUsers = self.usersToInvite;
    } else if ([segue.identifier isEqualToString:kSegueTags]) {
        TagsViewController *tagsVC = segue.destinationViewController;
        tagsVC.delegate = self;
    }
}

#pragma mark - Helpers

- (void)setSelectedMeetmeButton:(BOOL)isSelected
{
    if (isSelected) {
     /*   self.meetmeButton.clipsToBounds = YES;
        self.meetmeButton.layer.cornerRadius = 2.0;
        self.meetmeButton.layer.borderWidth = 2.0;
        self.meetmeButton.layer.borderColor = [UIColor whiteColor].CGColor;*/
        self.meetmeButton.selected = YES;
    } else {
        self.meetmeButton.selected = NO;
/*        self.meetmeButton.layer.cornerRadius = 0.0;
        self.meetmeButton.layer.borderWidth = 0.0;
        self.meetmeButton.layer.borderColor = nil;*/
    }
}


- (void)updateTagsViewHeight
{
    NSArray *allTF = @[self.titleTF, self.detailTF];
    
    for (UITextField *tf in allTF) {
        if ([tf isFirstResponder]) {
            self.tagsContainerHeightConstraint.constant = self.tagViewMinHeight;
            self.tagsViewHeightConstraint.constant = 0;
            [self.view layoutIfNeeded];
            return;
        }
    }
    
    if (!self.isKeyboardVisible) {
        self.tagsContainerHeightConstraint.constant = self.tagViewMinHeight;
        self.tagsViewHeightConstraint.constant = 0;
    } else {
        CGFloat containerHeight = CGRectGetHeight(self.scrollView.bounds) -
        CGRectGetMinY(self.tagsContainerView.frame);
        NSLog(@"%f>>%f>>>%f>>%f", self.tagsContainerView.frame.origin.x, self.tagsContainerView.frame.origin.y, self.tagsContainerView.frame.size.width, self.tagsContainerView.frame.size.height);
        
        NSLog(@"Contant: %f", containerHeight);
        self.tagsContainerHeightConstraint.constant = containerHeight;
        
   /*     NSLog(@">>>>>>>>>%f", self.tagsContainerView.frame.origin.y);
        CGRect newFrame = self.tagsContainerView.frame;
       
        newFrame.origin.y += 100;
        
        [self.tagsContainerView setFrame:newFrame];
        NSLog(@"<<<<<<<<<%f", self.tagsContainerView.frame.origin.y);*/

    }
    
    [self.view layoutIfNeeded];
}

- (IBAction) addRating:(id)sender
{
    
    for (int i=101; i <= 105; i++) {
        
        UIButton* btn_highlighted = (UIButton *)[self.view viewWithTag:i];
        [btn_highlighted setSelected:NO];
    }
    
    UIButton* btn = (UIButton *)sender;
    
    for (int i=101; i <= btn.tag; i++) {
        
        UIButton* btn_highlighted = (UIButton *)[self.view viewWithTag:i];
        [btn_highlighted setSelected:YES];
    }
    
    self.rating = btn.tag - 100;
    
}

- (IBAction)selectInvites:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeetMeListViewController *meetMeListVC = [storyboard instantiateViewControllerWithIdentifier:@"meetmelist"];
    meetMeListVC.showGroups = YES;
    meetMeListVC.groups = self.groups;
    meetMeListVC.delegate = self;
    [self.navigationController pushViewController:meetMeListVC animated:NO];
}

#pragma mark - MeetMeListControllerDelegate

- (void) confirmInvites:(MeetMeListViewController *)meetMeListVC withContacts:(NSMutableArray *)contacts withReceivers:(NSMutableArray *)receivers withGroups:(NSMutableArray *)groups {
    
    self.selectedGroups = groups;
    self.selectedContacts = contacts;
    self.selectedReceivers = receivers;
}

@end
