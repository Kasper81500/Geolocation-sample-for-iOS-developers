//
//  MyGroupsViewController.m
//  Paranoid Fan
//
//  Created by Adeel Asim on 6/22/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import "MyGroupsViewController.h"
#import "FavoriteTableViewCell.h"
#import "Group.h"
#import "Engine.h"
#import "User.h"
#import "Constants.h"
#import <Google/Analytics.h>
#import "FanGroupViewController.h"
#import "GroupChatViewController.h"
#import "GroupSelectionViewController.h"
#import "MapViewController.h"

@interface MyGroupsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSMutableArray *myGroups;

@end

@implementation MyGroupsViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 45.0;
    self.tblView.hidden = YES;
    [[[Engine sharedEngine] dataManager] getMyGroupsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            
            self.myGroups = [result mutableCopy];
            self.tblView.hidden = NO;
            [self.tblView reloadData];
            
        }
    }];
}

- (IBAction) goBack {
    
    BOOL foundController = FALSE;
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[MapViewController class]]) {
            foundController = TRUE;
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
    
    if (!foundController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myGroups.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
    [headerView setBackgroundColor:rgbColor(27, 153, 214)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,tableView.frame.size.width-10,22)];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
    
    headerLabel.text = @"My Groups";
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"groupCell";
    
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    Group *group = self.myGroups[indexPath.row];
    
    cell.titleLabel.text = group.group;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
     Group *group = self.myGroups[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FanGroupViewController *fgVC = [storyboard instantiateViewControllerWithIdentifier:@"fangroupVC"];
    fgVC.group = group;
    [self.navigationController pushViewController:fgVC animated:YES];
    
}

- (IBAction)showMessages:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    Group *group = self.myGroups[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupChatViewController *groupVC = [storyboard instantiateViewControllerWithIdentifier:@"groupChatView"];
    groupVC.groupID = group.groupID;
    groupVC.groupName = group.group;
    [self.navigationController pushViewController:groupVC animated:YES];
}

- (IBAction)createNew:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupSelectionViewController *groupVC = [storyboard instantiateViewControllerWithIdentifier:@"groupsSelection"];
    [self.navigationController pushViewController:groupVC animated:YES];
}


@end
