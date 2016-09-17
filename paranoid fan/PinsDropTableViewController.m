//
//  PinsDropTableViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PinsDropTableViewController.h"
#import "Pin.h"
#import "UIImageView+AFNetworking.h"
#import "SearchTableViewCell.h"
#import "NSArray+JSON.h"
#import "Constants.h"

@interface PinsDropTableViewController ()

@end

@implementation PinsDropTableViewController


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
    [headerView setBackgroundColor:rgbColor(27, 153, 214)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0,tableView.frame.size.width-15,30)];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    
    if (section == 0)
        headerLabel.text = @"Cities";
    else if (section == 1)
        headerLabel.text = @"Venues";
    else if (section == 2)
        headerLabel.text = @"Bars";
    else if (section == 3)
        headerLabel.text = @"Social";
    else
        headerLabel.text = @"Fan Groups";
    
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
    
    
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return 52.0;
    else
        return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SearchItem> selectedPin;
    
    if (indexPath.section == 0)
        selectedPin = self.filteredCitiesItems[indexPath.row];
    else if (indexPath.section == 1)
        selectedPin = self.filteredVenueItems[indexPath.row];
    else if (indexPath.section == 2)
        selectedPin = self.filteredBarsItems[indexPath.row];
    else if (indexPath.section == 3)
        selectedPin = self.filteredSocialItems[indexPath.row];
    else
        selectedPin = self.filteredGroupsItems[indexPath.row];
    
    if (self.pinsDelegate && [self.pinsDelegate respondsToSelector:@selector(pinsTableView:didSelectPin:)]) {
        [self.pinsDelegate pinsTableView:self didSelectPin:selectedPin];
    }
}

#pragma mark - CustomDropDownCell

- (NSInteger) customNumberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return self.filteredCitiesItems.count;
    else if (section == 1)
        return self.filteredVenueItems.count;
    else if (section == 2)
        return self.filteredBarsItems.count;
    else if (section == 3)
        return self.filteredSocialItems.count;
    else
        return self.filteredGroupsItems.count;
}


- (UITableViewCell *)customCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PinCell";
    
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    id<SearchItem> pin;
    
    if (indexPath.section == 0)
        pin = self.filteredCitiesItems[indexPath.row];
    else if (indexPath.section == 1)
        pin = self.filteredVenueItems[indexPath.row];
    else if (indexPath.section == 2)
        pin = self.filteredBarsItems[indexPath.row];
    else if (indexPath.section == 3)
        pin = self.filteredSocialItems[indexPath.row];
    else
        pin = self.filteredSocialItems[indexPath.row];
    
    [cell setPin:pin];
    
    return cell;
}

- (NSArray *)fillteredItemsWithString:(NSString *)filterString
{
    NSString *searchPrefix = [filterString lowercaseString];
    
    if (!filterString || filterString.length == 0) {
        self.tableView.hidden = YES;
        return nil;
    }
    
    self.tableView.hidden = NO;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        id<SearchItem> pin = evaluatedObject;
        
        NSString *title = [[pin getSearchTitle] lowercaseString];
        NSString *tagsString = [pin getSearchTags];
        NSLog(@">>>%@", title);
        BOOL isTitle = [title hasPrefix:searchPrefix];
        
        if (isTitle) {
            return YES;
        } else {
            NSArray *tags = [NSArray arrayFromTags:tagsString];
            for (NSString *tag in tags) {
                BOOL isTag = [[tag lowercaseString] hasPrefix:searchPrefix];
                if (isTag) {
                    return isTag;
                }
            }
        }
        return NO;
    }];
    
    NSArray *filteredArray = [self.items filteredArrayUsingPredicate:predicate];
    return filteredArray;
}

- (NSArray *)fillteredItemsWithString:(NSString *)filterString withArray:(NSMutableArray *)sourceArray {
    
    NSString *searchPrefix = [filterString lowercaseString];
    
    if (!filterString || filterString.length == 0) {
        self.tableView.hidden = YES;
        return nil;
    }
    
    self.tableView.hidden = NO;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        id<SearchItem> pin = evaluatedObject;
        
        NSString *title = [[pin getSearchTitle] lowercaseString];
        NSString *tagsString = [pin getSearchTags];
        NSLog(@">>>%@", title);
        BOOL isTitle = [title containsString:searchPrefix];
        
        if (isTitle) {
            return YES;
        } else {
            NSArray *tags = [NSArray arrayFromTags:tagsString];
            for (NSString *tag in tags) {
                BOOL isTag = [[tag lowercaseString] containsString:searchPrefix];
                if (isTag) {
                    return isTag;
                }
            }
        }
        return NO;
    }];
    
    NSArray *filteredArray = [sourceArray filteredArrayUsingPredicate:predicate];
    return filteredArray;
}

- (void) setSearchString:(NSString *)searchString {
    
    NSLog(@"This is called");
    
    _filteredCitiesItems = [self fillteredItemsWithString:searchString withArray:self.citiesItems];
    _filteredVenueItems = [self fillteredItemsWithString:searchString withArray:self.venueItems];
    _filteredBarsItems = [self fillteredItemsWithString:searchString withArray:self.barsItems];
    _filteredSocialItems = [self fillteredItemsWithString:searchString withArray:self.socialItems];
    //    NSLog(@"<>%lu", (unsigned long)[_filteredItems count]);
    [self.tableView reloadData];
    
}


@end
