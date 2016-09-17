//
//  ProfileViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/28/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "ProfileViewController.h"
#import "Engine.h"
#import "User.h"
#import "UIViewController+Popup.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "FavoriteListViewController.h"
#import "ReviewListViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *points;
@property (weak, nonatomic) IBOutlet UILabel *balance;

@end

@implementation ProfileViewController

@synthesize profileID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSInteger user_profile_id = 0;
    
    if (profileID == nil)
        user_profile_id = [[[Engine sharedEngine] settingManager] userID];
    else
        user_profile_id = [profileID integerValue];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [currencyFormatter setMaximumFractionDigits:2];
    self.balance.text = [NSString stringWithFormat:@"Current Balance: $%@", [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[[[[Engine sharedEngine] settingManager] user] getBalance]]]];
    
    [[[Engine sharedEngine] dataManager] getUserInfoByID:user_profile_id withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            User *user = (User *)result;
            [_avatar setImageWithURL:[NSURL URLWithString:user.profileAvatar]];
            [_name setText:user.fullname];
            [_points.titleLabel setText:[NSString stringWithFormat:@"%ld", (long)user.profilePoints]];
        } else {
            
            [self showErrorMessage:errorInfo];
        }
    }];
}

- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showFavorites:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoriteListViewController *favoriteVC = [storyboard instantiateViewControllerWithIdentifier:@"favoriteList"];
    favoriteVC.profileID = profileID;
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

- (IBAction)showReviews:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReviewListViewController *reviewVC = [storyboard instantiateViewControllerWithIdentifier:@"reviewList"];
    reviewVC.profileID = profileID;
    [self.navigationController pushViewController:reviewVC animated:YES];
}

@end
