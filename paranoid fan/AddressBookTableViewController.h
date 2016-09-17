//
//  AddressBookTableViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressBookTableViewController;

@protocol AddressBookTableViewControllerDelegate <NSObject>

- (void)addressBookController:(AddressBookTableViewController *)addressBookController didSelectUsers:(NSArray *)users;

@end

@interface AddressBookTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *selectedUsers;
@property (nonatomic, weak) id<AddressBookTableViewControllerDelegate> addressBookDelegate;

@end
