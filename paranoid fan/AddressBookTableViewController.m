//
//  AddressBookTableViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "AddressBookTableViewController.h"
#import <APAddressBook.h>
#import <APContact.h>
#import "ContactTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <Google/Analytics.h>



@interface AddressBookTableViewController ()

@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic, strong) NSArray *contancts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;

@end

@implementation AddressBookTableViewController

@synthesize  selectedUsers;

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Address Book Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedContacts = [NSMutableArray array];
    
    NSLog(@"Count users %ld", self.selectedUsers.count);

    self.addressBook = [[APAddressBook alloc] init];
    self.addressBook.fieldsMask =
    APContactFieldName | APContactFieldPhonesOnly | APContactFieldEmailsOnly |APContactFieldThumbnail;
    
    self.addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.phones.count > 0;
    };
    
 /*   self.addressBook.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    ];
   */
    switch([APAddressBook access])
    {
        case APAddressBookAccessUnknown:
        case APAddressBookAccessDenied:
            [self requestAccess];
            break;
            
        case APAddressBookAccessGranted:
            [self loadAllContacts];
            break;
    }
}


- (void)requestAccess
{
    [APAddressBook requestAccess:^(BOOL granted, NSError *error) {
        if (granted) {
            [self loadAllContacts];
        }
    }];
}

- (void)loadAllContacts
{
    [self.addressBook loadContacts:^(NSArray *contacts, NSError *error)
     {
         if (!error) {
             self.contancts = contacts;
             [self.tableView reloadData];
             
             for (int i=0; i<self.selectedUsers.count; i++) {
                 
                     APContact *selectedContact = (APContact *) self.selectedUsers[i];
                     for (int j=0; j<self.contancts.count; j++) {
                         
                         APContact *contact = (APContact *) self.contancts[j];
                         
                         if ([contact.phones.firstObject.number isEqualToString:selectedContact.phones.firstObject.number])
                             contact.note = @"Selected";
                     }
             }
             
         } else {
             [self hide];
         }
     }];
    
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self hide];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    if (self.selectedContacts.count > 0) {
        [self.addressBookDelegate addressBookController:self didSelectUsers:self.selectedContacts];
    }
    
    [self hide];
}

- (void)hide
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contancts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    
    APContact *contact = self.contancts[indexPath.row];
    [cell setContact:contact];
    
    if ([contact.note isEqualToString:@"Selected"])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    APContact *contact = self.contancts[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedContacts containsObject:contact]) {
        [self.selectedContacts removeObject:contact];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        contact.note = @"Selected";
        [self.selectedContacts addObject:contact];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


@end
