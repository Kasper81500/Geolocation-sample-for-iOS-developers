//
//  GroupsDropTableViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 5/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "DropTableViewController.h"

@class GroupsDropTableViewController;

@protocol GroupDropDownDelegate <NSObject>

- (void)groupTableView:(GroupsDropTableViewController *)groupTableView didSelectGroup:(NSString *)group;

@end

@interface GroupsDropTableViewController : DropTableViewController

@property (nonatomic, weak) id<GroupDropDownDelegate> groupDelegate;

@end
