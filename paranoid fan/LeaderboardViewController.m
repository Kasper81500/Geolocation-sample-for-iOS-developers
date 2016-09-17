//
//  LeaderboardViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/11/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "LeaderTableViewCell.h"
#import "User.h"
#import "Engine.h"
#import <Google/Analytics.h>
#import "FavoriteListViewController.h"
#import "ReviewListViewController.h"

@interface LeaderboardViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *sortedUsers;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSMutableSet *allUsers;


@end

@implementation LeaderboardViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Leader Board Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[Engine sharedEngine] dataManager] getLeaderboardWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
           // NSSet *newUsers = [NSSet setWithArray:result];
            //self.allUsers = [NSMutableSet setWithSet:newUsers];
            self.users = (NSArray *)result;
            
         /*   NSArray *sortedArray = [self.users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                User *user1 = obj1;
                User *user2 = obj2;
                
                if (user1.profilePoints > user2.profilePoints) {
                    return NSOrderedAscending;
                } else if (user1.profilePoints < user2.profilePoints) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            */
            //self.sortedUsers = self.users;
            
            [self.tblView reloadData];

        }
    }];    
//    [self setNeedsStatusBarAppearanceUpdate];
    
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showFavorites:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    User *user_leader = self.users[indexPath.row];
    NSLog(@"user id: %ld", (long)user_leader.userId);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoriteListViewController *favoriteVC = [storyboard instantiateViewControllerWithIdentifier:@"favoriteList"];
    favoriteVC.profileID = [ NSString stringWithFormat:@"%ld", (long)user_leader.userId];
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

- (IBAction)showReviews:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    User *user_leader = self.users[indexPath.row];
       NSLog(@"user id: %ld", (long)user_leader.userId);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReviewListViewController *reviewVC = [storyboard instantiateViewControllerWithIdentifier:@"reviewList"];
    reviewVC.profileID = [ NSString stringWithFormat:@"%ld", (long)user_leader.userId];
    [self.navigationController pushViewController:reviewVC animated:YES];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"leaderCell";
    
    LeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    User *user = self.users[indexPath.row];
    cell.user = user;
    
    return cell;
}

@end
