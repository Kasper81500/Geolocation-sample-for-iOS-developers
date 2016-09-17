//
//  GroupSelectionViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "GroupSelectionViewController.h"
#import "Engine.h"
#import "User.h"
#import "MeetMeListViewController.h"
#import "NSArray+JSON.h"
#import "SKTagView.h"
#import "Constants.h"
#import "UIViewController+Popup.h"
#import <Google/Analytics.h>
#import "MBProgressHUD.h"
#import "PhotoManager.h"
#import "TeamsDropTableViewController.h"
#import "MapViewController.h"

@interface GroupSelectionViewController ()<UITextFieldDelegate, TeamDropDownDelegate>

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UIButton *selectTeam;
@property (weak, nonatomic) IBOutlet UITextField *groupname;
@property (weak, nonatomic) IBOutlet UILabel *lblAlready;

@property (strong, nonatomic) UIImage *selectedPhoto;
@property (nonatomic, strong) NSString *selectedTeam;
@property (nonatomic, strong) NSMutableArray *teams;
@property (strong, nonatomic) PhotoManager *photoManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectTeamBtnHeightConstraint;


@end

@implementation GroupSelectionViewController

@synthesize hideBackButton, showNextButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (hideBackButton)
        _backButton.hidden = YES;
    else
        _backButton.hidden = NO;
  
    if (showNextButton)
        _nextButton.hidden = NO;
    else
        _nextButton.hidden = YES;
    
    self.groupname.delegate = self;
    self.selectTeam.hidden = YES;
    self.selectTeamBtnHeightConstraint.constant = 0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(selectCover)];
    
    self.cover.userInteractionEnabled = YES;
    [self.cover addGestureRecognizer:tapGesture];
    
    [self loadAllTeams];
    
}


- (void)loadAllTeams
{
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"ALL Teams teams %@",result);
            
            NSArray *teams = (NSArray *)result;
            NSArray *teamSport = [teams valueForKey:@"team"];
            
            self.teams = [NSMutableArray arrayWithArray:teamSport];
        }
    }];
}

- (IBAction)clickBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickNextBtn:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[Engine sharedEngine] dataManager] checkGroupName:self.groupname.text withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MeetMeListViewController *meetMeListVC = [storyboard instantiateViewControllerWithIdentifier:@"meetmelist"];
            meetMeListVC.team = self.selectedTeam;
            meetMeListVC.photo = self.selectedPhoto;
            meetMeListVC.groupname = self.groupname.text;
            meetMeListVC.isInvite = YES;
            [self.navigationController pushViewController:meetMeListVC animated:NO];
       
        } else {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showErrorMessage:errorInfo];
        }
    }];
    
}

- (IBAction)showTeams:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TeamsDropTableViewController *teamsVC = [storyboard instantiateViewControllerWithIdentifier:@"teamslist"];
    teamsVC.forSelection = YES;
    teamsVC.items = _teams;
    teamsVC.teamDelegate = self;
    [self.navigationController presentViewController:teamsVC animated:YES completion:nil];
}

- (IBAction)skip:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
    [self.navigationController pushViewController:mapVC animated:NO];
}

- (void) selectCover {
 
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    [self.photoManager selectAlbumFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedPhoto = image;
            self.cover.image = image;
            [[self.view viewWithTag:28] setHidden:YES];
        } else {
            self.selectedPhoto = nil;
        }
        
    }];
}

#pragma mark - TeamDropDownDelegate

- (void)teamTableView:(TeamsDropTableViewController *)teamTableView didSelectTeam:(NSString *)team
{
    NSLog(@"Selected team: %@", team);
    self.selectedTeam = team;
    self.lblAlready.text = team;
    self.lblAlready.hidden = NO;
}

#pragma mark - UISearchBarDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
 
    self.selectTeamBtnHeightConstraint.constant = 20;
    self.selectTeam.hidden = NO;
    self.lblAlready.hidden = YES;
    [textField becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = nil;
    [textField resignFirstResponder];
    return YES;
}



@end
