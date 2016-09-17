//
//  DropTableViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDropDownCell.h"

@interface DropTableViewController : UITableViewController<CustomDropDownCell>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, readonly) NSArray *filteredItems;

@property (nonatomic, strong) NSString *searchString;

- (void)removeItem:(id)item;

@end
