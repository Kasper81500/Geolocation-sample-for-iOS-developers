//
//  ContactsViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/31/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "ContactsViewController.h"
#import <APAddressBook.h>
#import <APContact.h>
#import "UIViewController+Popup.h"
#import "ContactTableViewCell.h"
#import "MBProgressHUD.h"
#import "CustomizationViewController.h"
#import "Engine.h"
#import "Constants.h"
#import <Google/Analytics.h>


@interface ContactsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic, strong) NSArray *contancts;
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressBook = [[APAddressBook alloc] init];
    self.addressBook.fieldsMask =
    APContactFieldName | APContactFieldPhonesOnly;
    
    self.addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.phones.count > 0;
    };
    
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
             self.tblView.hidden = NO;
             [self.tblView reloadData];
         } else {
            
             self.tblView.hidden = YES;
             
         }
     }];
}

- (IBAction)addFriend:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    NSString *phoneNumber = @"";
    
    APContact *contact = self.contancts[indexPath.row];
    phoneNumber = contact.phones.firstObject.number;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ContactTableViewCell *cell = (ContactTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
    [cell.sendInvite setSelected:YES];
    
    contact.note = @"Yes";
    
    [[[Engine sharedEngine] dataManager] addFriend:phoneNumber withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            NSLog(@"%@", result);
        } else {
            
            [self showErrorMessage:errorInfo];
        }
    }];
    
}


- (IBAction) goNext {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomizationViewController *customVC = [storyboard instantiateViewControllerWithIdentifier:@"customizationVC"];
    customVC.hideBackButton = TRUE;
    customVC.showNextButton = TRUE;
    [self.navigationController pushViewController:customVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.contancts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    APContact *contact = self.contancts[indexPath.row];
    [cell setContact:contact];
    
    if ([contact.note isEqualToString:@"Yes"])
        [cell.sendInvite setSelected:YES];
    else
        [cell.sendInvite setSelected:NO];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


@end
