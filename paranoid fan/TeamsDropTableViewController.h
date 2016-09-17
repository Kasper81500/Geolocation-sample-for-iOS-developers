//
//  TeamsDropTableViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "DropTableViewController.h"

@class TeamsDropTableViewController;

@protocol TeamDropDownDelegate <NSObject>

- (void)teamTableView:(TeamsDropTableViewController *)teamTableView didSelectTeam:(NSString *)team;

@end

@interface TeamsDropTableViewController : DropTableViewController

@property (nonatomic) BOOL forSelection;
@property (nonatomic, weak) id<TeamDropDownDelegate> teamDelegate;

@end
