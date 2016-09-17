//
//  SellTicketViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SellTicketViewController.h"
#import "Constants.h"
#import "ReviewOfferViewController.h"
#import "Engine.h"
#import "User.h"
#import "NSArray+JSON.h"
#import "UIViewController+Popup.h"
#import "TagsViewController.h"

#define kSegueReviewOffer   @"reviewOffer"
#define kSegueTags          @"tagsView"

#define kDefaultScrollHeight    446
#define kBottonSpace            56
#define kTopInset               66
#define kDefaultHeightForTag        40

@interface SellTicketViewController ()<UITextFieldDelegate, TagsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UITextField *titleTF;
@property (nonatomic, weak) IBOutlet UITextField *sectionTF;
@property (nonatomic, weak) IBOutlet UITextField *numberOfTicketsTF;
@property (nonatomic, weak) IBOutlet UITextField *priceTF;
@property (nonatomic, weak) IBOutlet UITextField *detailTF;
@property (nonatomic, weak) IBOutlet UITextField *phoneTF;

@property (nonatomic, weak) IBOutlet UIButton *inPersonButton;
@property (nonatomic, weak) IBOutlet UIButton *electronicButton;

@property (nonatomic, strong) NSArray *teamsTags;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomScrollConstraint;

@property (nonatomic, weak) IBOutlet UIView *tagsContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagsContainerHeightConstraint;
@property (nonatomic, weak) TagsViewController *tagsViewController;

@property (nonatomic) CGFloat tagViewMinHeight;
@property (nonatomic) BOOL isKeyboardVisible;

@end

@implementation SellTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.sectionTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.priceTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.detailTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.numberOfTicketsTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
    [self setSelectedButton:self.inPersonButton isSelected:YES];
    [self setSelectedButton:self.electronicButton isSelected:NO];
    
    self.tagViewMinHeight = kDefaultHeightForTag;
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
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self updateUIWithKeyboardHeight:keyboardSize.height andDuration:duration];
}

- (void)keyboardDidShown:(NSNotification *)notification
{
    self.isKeyboardVisible = YES;
    [self updateTagsViewHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.isKeyboardVisible = NO;
    [self updateUIWithKeyboardHeight:kBottonSpace andDuration:0.25];
    [self updateTagsViewHeight];
}

- (void)updateUIWithKeyboardHeight:(CGFloat)keyboardHeight andDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.bottomScrollConstraint.constant = keyboardHeight;
        
        CGFloat leftHeight = CGRectGetHeight(self.view.bounds) - self.bottomScrollConstraint.constant - kTopInset;
        
        if (leftHeight < kDefaultScrollHeight) {
            self.scrollHeightConstraint.constant = leftHeight;
        } else {
            self.scrollHeightConstraint.constant = kDefaultScrollHeight;
        }
        
        
        [self.view layoutIfNeeded];
    }];
}


- (BOOL)isShouldHideOnTap
{
    return NO;
}

#pragma mark - IBAction

- (IBAction)personTaped:(UIButton *)sender
{
    [self setSelectedButton:self.inPersonButton isSelected:YES];
    [self setSelectedButton:self.electronicButton isSelected:NO];
}

- (IBAction)electronicTaped:(UIButton *)sender
{
    [self setSelectedButton:self.inPersonButton isSelected:NO];
    [self setSelectedButton:self.electronicButton isSelected:YES];
}

- (IBAction)reviewOfferTaped:(UIButton *)sender
{
    NSString *errorMessage = @"";
    
    if ([self checkIfAllFieldsFilled:&errorMessage]) {
        [self performSegueWithIdentifier:kSegueReviewOffer sender:self];
    } else {
        [self showErrorMessage:errorMessage];
    }
}

- (IBAction)cancelTaped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideTicketController object:self];
}

- (IBAction)doneButtonTaped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TagsViewControllerDelegate

- (void)tagsViewController:(TagsViewController *)tagsVC didEndSelectingWithSize:(CGSize)tagsViewSize
{
    self.tagViewMinHeight = tagsViewSize.height;
    self.tagsContainerHeightConstraint.constant = tagsViewSize.height;
    
    CGFloat deltaHeight = tagsViewSize.height - kDefaultHeightForTag;
    self.scrollHeightConstraint.constant = kDefaultScrollHeight + deltaHeight;
    
    [self.view layoutIfNeeded];
}

- (void)tagsViewController:(TagsViewController *)tagsVC didSelectedTags:(NSArray *)tags
{
    self.teamsTags = tags;
}

- (void)tagsViewController:(TagsViewController *)tagsVC didResize:(CGSize)tagsViewSize
{
    self.tagViewMinHeight = tagsViewSize.height;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueReviewOffer]) {
        ReviewOfferViewController *nextVC = segue.destinationViewController;
        
        nextVC.ticketTitle = self.titleTF.text;
        nextVC.detail = self.detailTF.text;
        nextVC.tags = self.teamsTags;
        nextVC.quantity = [self.numberOfTicketsTF.text integerValue];
        nextVC.section = [self.sectionTF.text integerValue];
        nextVC.price = [self.priceTF.text floatValue];
        nextVC.delivery = self.inPersonButton.selected;
        nextVC.phone = self.phoneTF.text;
    } else if ([segue.identifier isEqualToString:kSegueTags]) {
        TagsViewController *tagsVC = segue.destinationViewController;
        tagsVC.delegate = self;
        tagsVC.placeHolderColor = [UIColor whiteColor];
        
        self.tagsViewController = tagsVC;
    }
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

#pragma mark - Helpers

- (BOOL)checkIfAllFieldsFilled:(NSString **)errorMessage
{
    BOOL isTitle = self.titleTF.text.length > 0;
    BOOL isSection = self.sectionTF.text.length > 0;
    BOOL isNumberOfTickets = self.numberOfTicketsTF.text.length > 0;
    BOOL isPrice = self.priceTF.text.length > 0;
    BOOL isDetail = self.detailTF.text.length > 0;
    BOOL isPhone = self.phoneTF.text.length > 0;
    
    BOOL isTeams = self.teamsTags.count == 2;
    
    if (isTitle && isSection && isNumberOfTickets && isPrice && isDetail && isPhone) {
        if (isTeams) {
            return YES;
        } else {
            *errorMessage = @"Should be only 2 teams selected";
        }
    } else {
        *errorMessage = @"Please fill all fields";
    }
    
    return NO;
}

- (void)setSelectedButton:(UIButton *)button isSelected:(BOOL)isSelected
{
    button.selected = isSelected;
    
    UIColor *normalColor = UIColorFromHEX(0x318ABC);
    UIColor *selectedColor = UIColorFromHEX(0x697FEE);
    
    button.backgroundColor = isSelected ? selectedColor : normalColor;
    
    button.layer.cornerRadius = 2.0;
    button.layer.borderWidth = isSelected ? 2.0 : 0.0;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)updateTagsViewHeight
{
    NSArray *allTF = @[self.titleTF, self.sectionTF, self.numberOfTicketsTF, self.priceTF, self.detailTF, self.phoneTF];
    
    for (UITextField *tf in allTF) {
        if ([tf isFirstResponder]) {
            self.tagsContainerHeightConstraint.constant = self.tagViewMinHeight;
            [self.view layoutIfNeeded];
            return;
        }
    }
    
    if (!self.isKeyboardVisible) {
        self.tagsContainerHeightConstraint.constant = self.tagViewMinHeight;
    } else {
        CGFloat containerHeight = CGRectGetHeight(self.scrollView.bounds) -
        CGRectGetMinY(self.tagsContainerView.frame);
        
        self.tagsContainerHeightConstraint.constant = containerHeight;
    }
    
    [self.view layoutIfNeeded];
}


@end
