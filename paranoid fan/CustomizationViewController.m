//
//  CustomizationViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-29.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "CustomizationViewController.h"
#import "Team.h"
#import "Engine.h"
#import "User.h"
#import "MapViewController.h"
#import "NSArray+JSON.h"
#import "SKTagView.h"
#import "Constants.h"
#import "UIViewController+Popup.h"
#import <Masonry/Masonry.h>
#import "TeamsDropTableViewController.h"
#import <Google/Analytics.h>
#import "GroupSelectionViewController.h"

#define kDropDownSegue @"teamDropDownSegue"

@interface CustomizationViewController ()<UITextFieldDelegate, TeamDropDownDelegate>

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

@property (weak, nonatomic) IBOutlet SKTagView *suggestedTagControl;
@property (weak, nonatomic) IBOutlet UILabel *myTeams;
@property (weak, nonatomic) IBOutlet SKTagView *myTagControl;
@property (weak, nonatomic) IBOutlet UIView *dropDownViewContainer;

@property (strong, nonatomic) NSMutableArray *usersTags;
@property (strong, nonatomic) NSMutableArray *suggestedTags;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LabelHeightConstratint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavbarHeightConstratint;

@property (weak, nonatomic) TeamsDropTableViewController *teamDropDownController;





@end

@implementation CustomizationViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Cusotmization View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_hideBackButton)
        _backButton.hidden = YES;
    else
        _backButton.hidden = NO;
    
    if (_showNextButton)
        _nextButton.hidden = NO;
    else
        _nextButton.hidden = YES;
    
    [self.searchBar addTarget:self action:@selector(searchValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.searchBar.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnify_glass"]];
    [self.searchBar setLeftViewMode:UITextFieldViewModeAlways];
    
    [self setupTagView];
    [self setupMyTagsView];
    
    [self loadMyTags];
    [self loadAllTeams];
    [self loadSuggestedTeams];
    
    self.dropDownViewContainer.hidden = YES;
    
    
}


- (IBAction)clickBackBtn:(id)sender {
    
    if ([self saveTagsForUser])
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickNextBtn:(id)sender {
    
    if ([self saveTagsForUser]) {
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GroupSelectionViewController *gsVC = [storyboard instantiateViewControllerWithIdentifier:@"groupsSelection"];
        gsVC.hideBackButton = YES;
        gsVC.showNextButton = YES;
        [self.navigationController pushViewController:gsVC animated:NO];
        
    }

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchBarDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.scrollView scrollRectToVisible:CGRectZero animated:YES];
    self.scrollView.scrollEnabled = NO;
    
    self.myTeams.hidden = YES;
    self.myTagControl.hidden = YES;
    
    self.dropDownViewContainer.hidden = NO;
    
    self.LabelHeightConstratint.constant = 0;
    self.NavbarHeightConstratint.constant = 10;
    
    UIImageView *magnify_glass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_grey"]];
    [magnify_glass setFrame:CGRectMake(0, 0, 15, 15)];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 15)];
    [leftView addSubview:magnify_glass];
    
    self.searchBar.leftView = leftView;
    
    self.searchBar.textAlignment = NSTextAlignmentLeft;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.scrollView.scrollEnabled = YES;
    self.dropDownViewContainer.hidden = YES;
    
    self.myTeams.hidden = NO;
    self.myTagControl.hidden = NO;
    
    self.view.backgroundColor = rgbColor(27, 153, 214);
    
    self.NavbarHeightConstratint.constant = 54;
    self.LabelHeightConstratint.constant = 50;
    
    self.searchBar.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnify_glass"]];
    
    self.searchBar.textAlignment = NSTextAlignmentCenter;

    
    self.teamDropDownController.searchString = nil;
    [textField resignFirstResponder];
}

- (void)searchValueChanged:(UITextField *)searchTextField
{
    if (searchTextField.text.length > 0)
        self.dropDownViewContainer.hidden = NO;
    else
        self.dropDownViewContainer.hidden = YES;
    
    self.teamDropDownController.searchString = searchTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = nil;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = nil;
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - SetupTagView

- (void)setupTagView
{
    [self commonSetupForTagView:self.suggestedTagControl];
    
    __weak SKTagView *weakView = self.suggestedTagControl;

    self.suggestedTagControl.didClickTagAtIndex = ^(NSUInteger index){
        
        NSString *willRemoveTag = [self.suggestedTags objectAtIndex:index];
        [self.usersTags addObject:willRemoveTag];
        
        [self.suggestedTags removeObjectAtIndex:index];
        [weakView removeTagAtIndex:index];
        [self addTag:willRemoveTag forView:self.myTagControl];
    };
}

- (void)setupMyTagsView
{
    [self commonSetupForTagView:self.myTagControl];
    
    __weak SKTagView *weakView = self.myTagControl;
    self.myTagControl.didClickTagAtIndex = ^(NSUInteger index){

        [self.usersTags removeObjectAtIndex:index];
        [weakView removeTagAtIndex:index];
    };
}

- (void)commonSetupForTagView:(SKTagView *)tagView
{
    tagView.backgroundColor = [UIColor clearColor];
    tagView.padding    = UIEdgeInsetsMake(5, 10, 5, 10);
    tagView.insets    = 5;
    tagView.lineSpace = 4;
}

#pragma mark - Team Data

- (void)loadMyTags
{
    NSArray *myTags = [NSArray arrayFromTags:[Engine sharedEngine].settingManager.user.tagsString];
    self.usersTags = [NSMutableArray arrayWithArray:myTags];
    
    [self addTags:myTags forView:self.myTagControl];
}

- (void)loadAllTeams
{
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"ALL Teams teams %@",result);
            
            NSArray *teams = (NSArray *)result;
            NSArray *teamSport = [teams valueForKey:@"team"];
            
            self.teamDropDownController.items = [NSMutableArray arrayWithArray:teamSport];
        }
    }];
}

- (void)loadSuggestedTeams
{
    [[[Engine sharedEngine] dataManager] getSuggestedTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"SUGESTED teams %@",result);
            
            NSArray *teams = (NSArray *)result;
            NSArray *teamSport = [teams valueForKey:@"team"];
            self.suggestedTags = [NSMutableArray arrayWithArray:teamSport];
            
            [self addTags:teamSport forView:self.suggestedTagControl];
        }
    }];
}

- (BOOL) saveTagsForUser
{
    if ([self.usersTags count] > 2) {
        
        [[[Engine sharedEngine] dataManager] updateUserTags:self.usersTags withCallBack:nil];
        
        [Engine sharedEngine].settingManager.user.tagsString = [self.usersTags tagsString];
        [[Engine sharedEngine].settingManager saveUser];
        
        return TRUE;
    }
    else {
        [self showErrorMessage:@"You must select atleast 3 teams."];
        
    }
    
    return FALSE;
}

#pragma mark - Tags Manager

- (void)addTags:(NSArray *)tags forView:(SKTagView *)tagView
{
    for (NSString *tagString in tags) {
        [self addTag:tagString forView:tagView];
    }
}

- (void)addTag:(NSString *)tagString forView:(SKTagView *)tagView
{
//    UIColor *blueBackgroundColor = rgbColor(25.0, 139.0, 185.0);
    
    SKTag *tag = [SKTag tagWithText:tagString];
    tag.textColor = rgbColor(27, 153, 214);
    tag.bgColor = [UIColor whiteColor];
    tag.cornerRadius = 0;
    tag.fontSize = 15;
    tag.font = [UIFont fontWithName:@"Roboto-Regular" size:15.0];
    tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
    
    [tagView addTag:tag];
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kDropDownSegue]) {
        self.teamDropDownController = segue.destinationViewController;
        self.teamDropDownController.teamDelegate = self;
    }
}

#pragma mark - TeamDropDownDelegate

- (void)teamTableView:(TeamsDropTableViewController *)teamTableView didSelectTeam:(NSString *)team
{
    [self.searchBar setText:nil];
    [self.searchBar resignFirstResponder];
    [self.usersTags addObject:team];
    [self addTag:team forView:self.myTagControl];
}

@end
