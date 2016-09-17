//
//  TeamsDropTableViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "TeamsDropTableViewController.h"
#import "Constants.h"

@interface TeamsDropTableViewController ()

@end

@implementation TeamsDropTableViewController

@synthesize forSelection;
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedTeam = self.filteredItems[indexPath.row];
    
    if (self.teamDelegate && [self.teamDelegate respondsToSelector:@selector(teamTableView:didSelectTeam:)]) {
        [self.teamDelegate teamTableView:self didSelectTeam:selectedTeam];
    }
    
    [self removeItem:selectedTeam];
    
    if (forSelection) {
        NSLog(@"dismissing it");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - CustomDropDownCell

- (NSInteger) customNumberOfRowsInSection:(NSInteger)section {
    
    return self.filteredItems.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,66)];
    [headerView setBackgroundColor:rgbColor(27, 153, 214)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,22,tableView.frame.size.width-10,22)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
    
    headerLabel.text = @"Select Team";
    
    [headerView addSubview:headerLabel];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(10, 23, 19, 20)];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(closeList) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:back];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 66;
}

- (UITableViewCell *)customCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"teamCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    cell.textLabel.text = self.filteredItems[indexPath.row];
    NSLog(@"Team Name: %@", self.filteredItems[indexPath.row]);
    return cell;
}

- (NSArray *)fillteredItemsWithString:(NSString *)filterString
{
    if (!filterString || filterString.length == 0) {
        return self.items;
    }
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", filterString];
    NSArray *filteredArray = [self.items filteredArrayUsingPredicate:predicate];
    return filteredArray;
}

- (void) closeList {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
