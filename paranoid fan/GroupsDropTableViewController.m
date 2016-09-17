//
//  GroupsDropTableViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "GroupsDropTableViewController.h"
#import "Constants.h"

@interface GroupsDropTableViewController ()

@end

@implementation GroupsDropTableViewController

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
    [headerView setBackgroundColor:rgbColor(27, 153, 214)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0,tableView.frame.size.width-15,30)];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    
    headerLabel.text = @"Fan Groups";
    
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
    
    
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedGroup = self.filteredItems[indexPath.row];
    
    if (self.groupDelegate && [self.groupDelegate respondsToSelector:@selector(groupTableView:didSelectGroup:)]) {
        [self.groupDelegate groupTableView:self didSelectGroup:selectedGroup];
    }
    
    [self removeItem:selectedGroup];
}

#pragma mark - CustomDropDownCell

- (NSInteger) customNumberOfRowsInSection:(NSInteger)section {
    
    return self.filteredItems.count;
}

- (UITableViewCell *)customCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"groupCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = self.filteredItems[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:14.0];
    cell.imageView.image = [UIImage imageNamed:@"social_icon"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
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

@end
