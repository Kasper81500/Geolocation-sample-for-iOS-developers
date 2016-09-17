//
//  SettingViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SettingViewController.h"
#import "EditProfileViewController.h"
#import "PrivacyPolicyViewController.h"
#import "ChangePasswordViewController.h"
#import "CustomizationViewController.h"
#import "GroupSelectionViewController.h"
#import "SocialViewController.h"
#import "AvatarViewController.h"
#import "AddCardViewController.h"
#import "Engine.h"
#import <Google/Analytics.h>

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tbView;

@end

@implementation SettingViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewDidLoad{
    [super viewDidLoad];
}
- (IBAction)clickBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark table view datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.row == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    else if (indexPath.row == 1)
        cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
    else if (indexPath.row == 2)
        cell = [tableView dequeueReusableCellWithIdentifier:@"editProfileCell" forIndexPath:indexPath];
    else if (indexPath.row == 3)
        cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
    else if (indexPath.row == 4)
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChangePasswordCell" forIndexPath:indexPath];
    else if (indexPath.row == 5)
        cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    else if (indexPath.row == 6)
        cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
    else if (indexPath.row == 7)
        cell = [tableView dequeueReusableCellWithIdentifier:@"customizationCell" forIndexPath:indexPath];
    else if (indexPath.row == 8)
        cell = [tableView dequeueReusableCellWithIdentifier:@"groupsCell" forIndexPath:indexPath];
    else if (indexPath.row == 9)
        cell = [tableView dequeueReusableCellWithIdentifier:@"facebookCell" forIndexPath:indexPath];
    else if (indexPath.row == 10)
        cell = [tableView dequeueReusableCellWithIdentifier:@"privacyCell" forIndexPath:indexPath];
    else if (indexPath.row == 11)
        cell = [tableView dequeueReusableCellWithIdentifier:@"privacySettingCell" forIndexPath:indexPath];
    else if (indexPath.row == 12)
        cell = [tableView dequeueReusableCellWithIdentifier:@"termsCell" forIndexPath:indexPath];
    else if (indexPath.row == 13)
        cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell" forIndexPath:indexPath];
    else if (indexPath.row == 14)
        cell = [tableView dequeueReusableCellWithIdentifier:@"signoutCell" forIndexPath:indexPath];
    return  cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSInteger row = indexPath.row;
    
    if (row == 1) {
        AddCardViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"cardVC"];
        VC.onBoarding = @"false";
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    else if (row == 2) {
        EditProfileViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
        [self.navigationController pushViewController:VC animated:YES];

    } else if (row == 3) {
        AvatarViewController *avatarVC = [storyboard instantiateViewControllerWithIdentifier:@"avatarVC"];
        [self.navigationController pushViewController:avatarVC animated:YES];
    } else if (row == 4) {
        ChangePasswordViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"changePassVC"];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (row == 9) {
        SocialViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"socialVC"];
        VC.isHideSkipButton = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (row == 11) {
        PrivacyPolicyViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"privacyVC"];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (row == 7) {
        CustomizationViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"customizationVC"];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (row == 8) {
        GroupSelectionViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"groupsSelection"];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (row == 14){
        [[[Engine sharedEngine] dataManager] logout];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kNewSignup"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phone_verified"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if (row == 12) {
        UIViewController *termsVC = [storyboard instantiateViewControllerWithIdentifier:@"termsOfUse"];
        [self.navigationController pushViewController:termsVC animated:YES];
    }
    
    
}
@end
