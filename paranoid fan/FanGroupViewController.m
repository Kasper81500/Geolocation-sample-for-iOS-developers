//
//  FanGroupViewController.m
//  Paranoid Fan
//
//  Created by Adeel Asim on 6/20/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import "FanGroupViewController.h"
#import "UIViewController+Popup.h"
#import "MBProgressHUD.h"
#import "AvatarViewController.h"
#import "Engine.h"
#import "Constants.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "GroupChatViewController.h"
#import "MeetMeListViewController.h"
#import <Google/Analytics.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>


@interface FanGroupViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *eventList;
@property (nonatomic, strong) NSMutableArray *groupMembers;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *groupname;
@property (weak, nonatomic) IBOutlet UILabel *membersCount;
@property (weak, nonatomic) IBOutlet UIButton *join;
@property (weak, nonatomic) IBOutlet UIButton *leave;
@property (weak, nonatomic) IBOutlet UIScrollView *members;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *message;
@property (weak, nonatomic) IBOutlet UIButton *invite;
@property (weak, nonatomic) IBOutlet UIButton *transfer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstraint;

@end

@implementation FanGroupViewController

@synthesize group;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 45.0;
    self.tblView.hidden = YES;
    
    [self.cover setImageWithURL:[NSURL URLWithString:group.cover]];
    self.groupname.text = group.group;
    
    CGFloat currentWidth = 414;
    if ([UIScreen mainScreen].bounds.size.width == 375)
        currentWidth = 375;
    else if ([UIScreen mainScreen].bounds.size.width == 320)
        currentWidth = 320;
    
    float newImageHeight = 0;
    float newImageWidth = 0;
    float imageWidth = 0;
    float imageHeight = 0;
    float ratio = 0;
    
    imageWidth = group.imageWidth;
    imageHeight = group.imageHeight;
    
    ratio = currentWidth / imageWidth;
    newImageHeight = ratio * imageHeight;
    newImageWidth = currentWidth;
    
    self.coverHeightConstraint.constant = newImageHeight;
    
    [[[Engine sharedEngine] dataManager] getGroupMembersWithCallBack:group.groupID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            
            self.groupMembers = [result mutableCopy];
            
            if ([self.groupMembers containsObject:[[[Engine sharedEngine] settingManager] user]]) {
                [self.join setHidden:YES];
                [self.leave setHidden:NO];
            }
            else {
                [self.join setHidden:NO];
                [self.leave setHidden:YES];
            }
            
            self.membersCount.text = [NSString stringWithFormat:@"%ld Member(s)", self.groupMembers.count];
            float padding = 10;
            float avatarWidth = 30;
            float avatarX = 0;
            
            for (int i=0; i<self.groupMembers.count; i++) {
                
                avatarX += padding;
                
                User *member = [self.groupMembers objectAtIndex:i];
                
                UIImageView *avatar = [[UIImageView alloc] init];
                [avatar setImageWithURL:[NSURL URLWithString:member.profileAvatar]];
                [avatar setFrame:CGRectMake(avatarX, 5, avatarWidth, avatarWidth)];
                [self.members addSubview:avatar];
                
                UILabel *name = [[UILabel alloc] init];
                name.text = member.fullname;
                [name setFrame:CGRectMake(avatarX, avatarWidth+5, avatarWidth, 10)];
                [name setFont:[UIFont fontWithName:@"Roboto-Regular" size:8.0]];
                [name setTextColor:[UIColor lightGrayColor]];
                [self.members addSubview:name];
                
                avatarX += avatarWidth;
            }
            
        }
    }];
    
}

- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) joinGroup {
 
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *membership = @"Join";
 
    
    [[[Engine sharedEngine] dataManager] groupMembership:membership forGroupID:group.groupID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
        [self.join setHidden:YES];
        [self.leave setHidden:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // [self showErrorMessage:errorInfo];
        }
    }];
}

- (IBAction)askToLeave:(id)sender {
    
    NSString *yes = @"Yes";
    
    NSMutableArray *buttonSources = [NSMutableArray arrayWithCapacity:2];
    [buttonSources addObject:yes];
    
    [UIAlertView showWithTitle:@"Leaving Group?"
                       message:@"Are you sure you want to leave this group?"
             cancelButtonTitle:@"No"
             otherButtonTitles:buttonSources
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //self.completition(nil);
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:yes]) {
                              [self leaveGroup];
                          }
                      }];
}

- (void) leaveGroup {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *membership = @"Leave";
    
    [[[Engine sharedEngine] dataManager] groupMembership:membership forGroupID:group.groupID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
            [self.join setHidden:NO];
            [self.leave setHidden:YES];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // [self showErrorMessage:errorInfo];
        }
    }];
}

- (IBAction) inviteContacts {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeetMeListViewController *meetMeListVC = [storyboard instantiateViewControllerWithIdentifier:@"meetmelist"];
    meetMeListVC.isGroupInvite = YES;
    meetMeListVC.groupID = group.groupID;
    meetMeListVC.meetMeText = [NSString stringWithFormat:@"inviting you join %@ fan group.", group.group];
    [self.navigationController pushViewController:meetMeListVC animated:NO];
}

- (IBAction) showMessages {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupChatViewController *groupVC = [storyboard instantiateViewControllerWithIdentifier:@"groupChatView"];
    groupVC.groupID = group.groupID;
    groupVC.groupName = group.group;
    [self.navigationController pushViewController:groupVC animated:YES];
}


#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
