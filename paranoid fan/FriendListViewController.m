//
//  FriendListViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/27/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "FriendListViewController.h"
#import <APAddressBook.h>
#import <APContact.h>
#import "UIViewController+Popup.h"
#import "ContactTableViewCell.h"
#import "FriendTableViewCell.h"
#import "MBProgressHUD.h"
#import "AvatarViewController.h"
#import "Engine.h"
#import "Constants.h"
#import <Google/Analytics.h>
#import "MessagesViewController.h"

@interface FriendListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic, strong) NSMutableArray *contancts;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSArray *pfUsersList;
@property (nonatomic, strong) NSMutableArray *noFriendsList;
@property (nonatomic, strong) NSArray *addedme;
@property (nonatomic, strong) NSMutableArray *group_users;
@property (nonatomic, strong) NSMutableArray *group_usersnames;
@property (weak, nonatomic) UITableView *tblCurrent;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITableView *tblContactsView;
@property (weak, nonatomic) IBOutlet UITableView *tblFriendsView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *lblContacts;
@property (weak, nonatomic) IBOutlet UIButton *lblFriends;
@property (weak, nonatomic) IBOutlet UIButton *lblAddedme;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblContactsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblFriendsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBackWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSkipWidthConstraint;

@end

@implementation FriendListViewController

@synthesize onBoarding, frindsOnly;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([onBoarding isEqualToString:@"true"]) {
        
        _btnBack.hidden = YES;
        _btnSkip.hidden = NO;
        
        self.btnBackWidthConstraint.constant = 0;
        self.btnSkipWidthConstraint.constant = 45;
    }
    else {
        
        _btnSkip.hidden = YES;
        _btnBack.hidden = NO;
        
        self.btnBackWidthConstraint.constant = 48;
        self.btnSkipWidthConstraint.constant = 0;
    }
    
    self.tblContactsView.hidden = YES;
    self.tblFriendsView.hidden = YES;
    self.tblView.hidden = YES;
    
    self.noFriendsList = [[NSMutableArray alloc] init];
    self.friendsList = [[NSArray alloc] init];
    self.addedme = [[NSArray alloc] init];
    self.group_usersnames = [[NSMutableArray alloc] init];
    self.group_users = [[NSMutableArray alloc] init];
/*
    [[[Engine sharedEngine] dataManager] getFriendList:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
            self.friendsList = (NSArray *)result;
        }
    }];

  */
    
    [self loadFriends];
    
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

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (frindsOnly) {
        
        [self.lblContacts setHidden:YES];
        [self.lblFriends setHidden:NO];
        [self.lblAddedme setHidden:YES];
        
        [[self.view viewWithTag:75] setHidden:YES];
        [[self.view viewWithTag:85] setHidden:YES];
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
             self.contancts = [contacts mutableCopy];
            // [self loadContacts];
         } else {

             
         }
     }];
    
}

- (void)loadContacts {
    
    [self.lblContacts setSelected:YES];
    [self.lblFriends setSelected:NO];
    [self.lblAddedme setSelected:NO];
    self.tblContactsView.hidden = NO;
    self.tblFriendsView.hidden = YES;
    self.tblView.hidden = YES;
    
    if (frindsOnly) {
        
        [self.lblFriends setSelected:YES];
        
        self.tblContactsView.hidden = YES;
    }
    
    self.tblViewHeightConstraint.constant = 0;
    self.tblFriendsHeightConstraint.constant = 0;
    self.tblContactsHeightConstraint.constant = self.view.frame.size.height-20;
    
    self.tblCurrent = self.tblContactsView;
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    APContact *contact;
    
    for (int i=0; i<self.contancts.count; i++) {
    
        contact = self.contancts[i];
        [phoneNumbers addObject:contact.phones.firstObject.number];
    }
    
    if (phoneNumbers.count > 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *csvString = [phoneNumbers componentsJoinedByString:@","];
        NSLog(@"CSV: %@", csvString);
        [[[Engine sharedEngine] dataManager] getFriendList:csvString withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"i m in the list");
                self.pfUsersList = (NSArray *)result;
                self.noFriendsList = [self.contancts mutableCopy];
                APContact *phoneContact;
                User *friendContact;
                
                NSLog(@"Friend Count: %d", self.friendsList.count);
                for(int i=0; i<self.friendsList.count; i++) {
                    
                    friendContact = (User *) self.friendsList[i];
                    
                    for (int j=0; j<self.contancts.count; j++) {
                        
                        phoneContact = (APContact *) self.contancts[j];
                        NSLog(@"%@ <> %@", [self preparePhone:phoneContact.phones.firstObject.number], friendContact.phone);
                        if ([[self preparePhone:phoneContact.phones.firstObject.number] isEqualToString: friendContact.phone]) {
                            
                            NSLog(@"matched");
                            [self.noFriendsList removeObjectAtIndex:j];
                        }
                        
                    }
                }
                
                if (frindsOnly)
                    [self loadFriends];
                else
                    [self.tblContactsView reloadData];
                
            }
            else {
                NSLog(@"i m out the list");
                self.noFriendsList = [self.contancts mutableCopy];
                
                if (frindsOnly)
                    [self loadFriends];
                else
                    [self.tblContactsView reloadData];
            }
        }];
    }
    else {
        
       self.tblContactsView.hidden = YES;
    }
}

- (void)loadFriends {
 
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.lblFriends setSelected:YES];
    [self.lblAddedme setSelected:NO];
    [self.lblContacts setSelected:NO];
    self.tblContactsView.hidden = YES;
    self.tblFriendsView.hidden = NO;
    self.tblView.hidden = YES;
    
    self.tblViewHeightConstraint.constant = 0;
    self.tblContactsHeightConstraint.constant = 0;
    self.tblFriendsHeightConstraint.constant = self.view.frame.size.height-20;
    
    self.tblCurrent = self.tblFriendsView;
    
    [[[Engine sharedEngine] dataManager] getFriendList:^(BOOL success, id result, NSString *errorInfo) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            
            self.friendsList = (NSArray *)result;
            [self.tblFriendsView reloadData];
            
        }
        else {
            
            self.tblFriendsView.hidden = YES;
        }
    }];
}

- (void)loadAddedMe {
    
    [self.lblAddedme setSelected:YES];
    [self.lblFriends setSelected:NO];
    [self.lblContacts setSelected:NO];
    self.tblContactsView.hidden = YES;
    self.tblFriendsView.hidden = YES;
    self.tblView.hidden = NO;

    self.tblContactsHeightConstraint.constant = 0;
    self.tblFriendsHeightConstraint.constant = 0;
    self.tblViewHeightConstraint.constant = self.view.frame.size.height-20;
    
    self.tblCurrent = self.tblView;
  
    NSString *userPhone = [[[Engine sharedEngine] settingManager] user].phone;
    
    if ([userPhone length] > 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [[[Engine sharedEngine] dataManager] getAddedList:userPhone withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {

                self.addedme = (NSArray *)result;
                [self.tblView reloadData];
                
            }
            else {
                self.tblView.hidden = YES;

            }
        }];
    }
    else
        self.tblView.hidden = YES;

}

- (IBAction)addFriend:(id)sender {
 
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblCurrent];
    NSIndexPath *indexPath = [self.tblCurrent indexPathForRowAtPoint:buttonPosition];
    
    NSString *phoneNumber = @"";
    
    if (self.tblCurrent == self.tblContactsView) {
        
        if (indexPath.section == 0) {
            
            User *contact = self.pfUsersList[indexPath.row];
            phoneNumber = contact.phone;
            
            FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblContactsView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.invited = TRUE;
        }
        else {
            APContact *contact = self.noFriendsList[indexPath.row];
            phoneNumber = contact.phones.firstObject.number;
            
            ContactTableViewCell *cell = (ContactTableViewCell *) [self.tblContactsView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.note = @"Yes";
        }
    }
    else if (self.tblCurrent == self.tblFriendsView) {
        /*
        User *contact = self.friendsList[indexPath.row];
        phoneNumber = contact.phone;
        
        FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblContactsView cellForRowAtIndexPath:indexPath];
        [cell.sendInvite setSelected:YES];
        
        contact.invited = TRUE;
         */
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MessagesViewController *messagesVC = [storyboard instantiateViewControllerWithIdentifier:@"directMessagesView"];
        User *receiver = self.friendsList[indexPath.row];
        messagesVC.receiverID = receiver.userId;
        messagesVC.receiverName = receiver.fullname;
        [self.navigationController pushViewController:messagesVC animated:YES];
    }
    else {
        
        User *contact = self.addedme[indexPath.row];
        phoneNumber = contact.phone;
        
        FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
        [cell.sendInvite setSelected:YES];
        
        contact.invited = TRUE;
    }
    
   
    if (self.tblCurrent != self.tblFriendsView) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[Engine sharedEngine] dataManager] addFriend:phoneNumber withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"%@", result);
            } else {
                
               // [self showErrorMessage:errorInfo];
            }
        }];
    }
}

- (IBAction)listTapped:(id)sender
{
    NSLog(@"its Tapped");
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 11)
        [self loadContacts];
    else if (btn.tag == 12)
        [self loadFriends];
    else if (btn.tag == 13)
        [self loadAddedMe];
}

- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) goNext {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MessagesViewController *messagesVC = [storyboard instantiateViewControllerWithIdentifier:@"directMessagesView"];
    
    if (self.group_users.count > 1) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[Engine sharedEngine] dataManager] addUserGroup:[self.group_users componentsJoinedByString:@","] withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                
                NSString *receivers = [self.group_usersnames componentsJoinedByString:@", "];
                NSLog(@"Group ID & Receovers : %@ %@", result, receivers);
                
                messagesVC.receiverName = receivers;
                messagesVC.isGroup = YES;
                messagesVC.groupID = [result integerValue];
                
                [self.navigationController pushViewController:messagesVC animated:YES];
            } else {
                
                // [self showErrorMessage:errorInfo];
            }
        }];
        
    }
    else {
        
        messagesVC.receiverName = self.group_usersnames[0];
        messagesVC.isGroup = NO;
        messagesVC.receiverID = [self.group_users[0] integerValue];
        
        [self.navigationController pushViewController:messagesVC animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.tblContactsView)
        return 2 ;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tblContactsView) {
        if (section == 0)
            return self.pfUsersList.count;
        else
            return self.noFriendsList.count;
    }
    else if (tableView == self.tblFriendsView)
        return self.friendsList.count;
    else
        return self.addedme.count;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.tblContactsView) {
        if (section == 0)
            return @"Paranoid Fans in my Address Book";
        else
            return @"Invite to Paranoid Fan";
    }
    else
        return @"";
}
*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    if (tableView == self.tblContactsView) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        [headerView setBackgroundColor:rgbColor(27, 153, 214)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,tableView.frame.size.width-10,22)];
        
        headerLabel.textAlignment = NSTextAlignmentLeft;
        [headerLabel setTextColor:[UIColor whiteColor]];
        
        [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
        
        if (section == 0 && self.pfUsersList.count > 0)
            headerLabel.text = @"Paranoid Fans in my Address Book";
        else if (section == 0 && self.pfUsersList.count == 0) {
            
            [headerView setFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            [headerView setBackgroundColor:[UIColor clearColor]];
             headerLabel.text = @"";
        }
        else
            headerLabel.text = @"Invite to Paranoid Fan";
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    else if (tableView == self.tblFriendsView) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        [headerView setBackgroundColor:rgbColor(27, 153, 214)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,tableView.frame.size.width-10,22)];
        
        headerLabel.textAlignment = NSTextAlignmentLeft;
        [headerLabel setTextColor:[UIColor whiteColor]];
        
        [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
        
        headerLabel.text = @"My Friends";
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    else {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        [headerView setBackgroundColor:rgbColor(27, 153, 214)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,tableView.frame.size.width-10,22)];
        
        headerLabel.textAlignment = NSTextAlignmentLeft;
        [headerLabel setTextColor:[UIColor whiteColor]];
        
        [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
        
        headerLabel.text = @"Who's Added Me";
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tblContactsView) {
        
        if (indexPath.section == 0) {
            
            FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactFriendCell" forIndexPath:indexPath];
            
            User *friend = self.pfUsersList[indexPath.row];
            [cell setUserfriend:friend];
            
            if (friend.invited)
                [cell.sendInvite setSelected:YES];
            else
                [cell.sendInvite setSelected:NO];
            
            return  cell;
        }
        else if (indexPath.section == 1) {
            
            ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
            
            APContact *contact = self.noFriendsList[indexPath.row];
            [cell setContact:contact];
            
            if ([contact.note isEqualToString:@"Yes"])
                [cell.sendInvite setSelected:YES];
            else
                [cell.sendInvite setSelected:NO];
            
            return  cell;
        }
    }
    else if (tableView == self.tblFriendsView) {
        
        FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
        
        User *friend = self.friendsList[indexPath.row];
        [cell setUserfriend:friend];
        
        if (friend.invited)
            [cell.sendInvite setSelected:YES];
        else
            [cell.sendInvite setSelected:NO];
        
        if (self.fromFriendList)
            [[cell.contentView viewWithTag:30] setHidden:FALSE];
        
        return  cell;
    }
    else {
        
        FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"addMeCell" forIndexPath:indexPath];
        
        User *friend = self.addedme[indexPath.row];
        [cell setUserfriend:friend];
        
        if (friend.invited)
            [cell.sendInvite setSelected:YES];
        else
            [cell.sendInvite setSelected:NO];
        
        return  cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tblCurrent == self.tblFriendsView) {
        
        if (self.fromFriendList) {
            
            User *friend = self.friendsList[indexPath.row];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MessagesViewController *messagesVC = [storyboard instantiateViewControllerWithIdentifier:@"directMessagesView"];
            messagesVC.receiverName = friend.fullname;
            messagesVC.isGroup = NO;
            messagesVC.receiverID = friend.userId;
            
            [self.navigationController pushViewController:messagesVC animated:YES];
        }
        else {
            
            User *friend = self.friendsList[indexPath.row];
            if ([self.group_usersnames containsObject:friend.fullname]) {
                [self removeCellSelection:indexPath];
            }
            else {
                
                FriendTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                [self.group_usersnames addObject:friend.fullname];
                [self.group_users addObject:[NSString stringWithFormat:@"%ld", friend.userId]];

                self.btnSkip.hidden = NO;
                self.btnSkipWidthConstraint.constant = 45;
            }
        }
        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}

# pragma mark - Helper

- (void) removeCellSelection:(NSIndexPath *)indexPath {
    
    if (self.tblCurrent == self.tblFriendsView) {
        
        FriendTableViewCell *cell = [self.tblFriendsView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        User *friend = self.friendsList[indexPath.row];
        [self.group_usersnames removeObject:friend.fullname];
        [self.group_users removeObject:[NSString stringWithFormat:@"%ld", friend.userId]];
        
        if (self.group_users.count == 0) {
            self.btnSkip.hidden = YES;
            self.btnSkipWidthConstraint.constant = 45;
        }
        
        NSLog(@"its deselecting it");
    }
}

- (NSString *)preparePhone:(NSString *)phone {
    
    phone = [phone stringByReplacingOccurrencesOfString:@"+1" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [@"+1" stringByAppendingFormat:@"%@", phone];
    
    return phone;
}


@end
