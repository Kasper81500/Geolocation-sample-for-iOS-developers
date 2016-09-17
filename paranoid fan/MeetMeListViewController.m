//
//  MeetMeListViewController.m
//  Paranoid Fan
//
//  Created by Adeel Asim on 5/26/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import "MeetMeListViewController.h"
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
#import "MapViewController.h"
#import "FanGroupViewController.h"
#import "MyGroupsViewController.h"

@interface MeetMeListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) APAddressBook *addressBook;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSArray *pfUsersList;
@property (nonatomic, strong) NSMutableArray *noFriendsList;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *next;
@property (nonatomic) NSInteger PFUserID;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableArray *selectedReceivers;
@property (strong, nonatomic) NSMutableArray *selectedGroups;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintTable;

@end

@implementation MeetMeListViewController

@synthesize meetMeText, isInvite, isShare, isGroupInvite, showGroups, groups, groupname, team, photo, groupID, pinID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 58.0;
    
    self.tblView.hidden = YES;
    
    self.topConstraintTable.constant = -20;
    
    if (isInvite || isShare || isGroupInvite || showGroups) {
        
        self.selectedContacts = [[NSMutableArray alloc] init];
        self.selectedReceivers = [[NSMutableArray alloc] init];
        self.selectedGroups = [[NSMutableArray alloc] init];
    }
    
    if (isInvite) {
        self.lblHeader.text = @"Invite Friends";
        self.back.hidden = YES;
        self.next.hidden = NO;
    }
    else if (isShare) {
        self.lblHeader.text = @"Share with Friends";
        self.back.hidden = NO;
        self.next.hidden = YES;
    }
    else if (isGroupInvite || showGroups) {
        self.lblHeader.text = @"Invite Friends";
        self.back.hidden = NO;
        self.next.hidden = YES;
    }
    
    self.noFriendsList = [[NSMutableArray alloc] init];
    self.friendsList = [[NSArray alloc] init];
    
    [[[Engine sharedEngine] dataManager] getFriendList:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
            self.friendsList = (NSArray *)result;
        }
    }];
    
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
             self.contacts = [contacts mutableCopy];
             [self loadContacts];
         } else {
             
             
         }
     }];
    
}

- (void)loadContacts {
    
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    APContact *contact;
    
    for (int i=0; i<self.contacts.count; i++) {
        
        contact = self.contacts[i];
        [phoneNumbers addObject:contact.phones.firstObject.number];
    }
    
   // [phoneNumbers addObject:@"2149424404"];
    if (phoneNumbers.count > 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *csvString = [phoneNumbers componentsJoinedByString:@","];
        NSLog(@"CSV: %@", csvString);
        [[[Engine sharedEngine] dataManager] getFriendList:csvString withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"i m in the list");
                self.pfUsersList = (NSArray *)result;
                self.noFriendsList = [self.contacts mutableCopy];
                APContact *phoneContact;
                User *friendContact;
                
                for(int i=0; i<self.friendsList.count; i++) {
                    
                    friendContact = (User *) self.friendsList[i];
                    
                    for (int j=0; j<self.contacts.count; j++) {
                        
                        phoneContact = (APContact *) self.contacts[j];
                        NSLog(@"%@ <> %@", [self preparePhone:phoneContact.phones.firstObject.number], friendContact.phone);
                        if ([[self preparePhone:phoneContact.phones.firstObject.number] isEqualToString: friendContact.phone]) {
                            
                            NSLog(@"matched");
                            [self.noFriendsList removeObjectAtIndex:j];
                        }
                        
                    }
                }
                
                [self.tblView reloadData];
                self.tblView.hidden = NO;
            }
            else {

                self.noFriendsList = [self.contacts mutableCopy];
                
                [self.tblView reloadData];
                self.tblView.hidden = NO;
                
            }
        }];
    }
}

- (IBAction)sendMeetMe:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    CGPoint boundsCenter = CGRectOffset(btn.bounds, btn.frame.size.width/2, btn.frame.size.height/2).origin;
    CGPoint buttonPosition = [sender convertPoint:boundsCenter
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    NSString *phoneNumber = @"";
    
    if (isShare || showGroups) {
        
        if (indexPath.section == 0) {
            
            Group *group = self.groups[indexPath.row];
            self.PFUserID = group.groupID;
            groupID = group.groupID;
            phoneNumber = @"Group";
            
            FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            group.invited = TRUE;
            
            if (showGroups) {
                [self.selectedGroups addObject:[NSString stringWithFormat:@"%ld", group.groupID]];
                NSLog(@"Groups count: %ld", self.selectedGroups.count);
            }
        }
        else if (indexPath.section == 1) {
            
            User *contact = self.pfUsersList[indexPath.row];
            self.PFUserID = contact.userId;
            phoneNumber = contact.phone;
            
            FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.invited = TRUE;
            
            if (showGroups) {
                [self.selectedReceivers addObject:[NSString stringWithFormat:@"%ld", contact.userId]];
                NSLog(@"Receivers count: %ld", self.selectedReceivers.count);
            }
        }
        else {
            APContact *contact = self.noFriendsList[indexPath.row];
            phoneNumber = contact.phones.firstObject.number;
            self.PFUserID = 0;
            
            ContactTableViewCell *cell = (ContactTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.note = @"Yes";
            
            if (showGroups) {
                [self.selectedContacts addObject:contact];
                NSLog(@"Contacts count: %ld", self.selectedContacts.count);
            }
        }
    }
    else {
        
        if (indexPath.section == 0) {
            
            User *contact = self.pfUsersList[indexPath.row];
            self.PFUserID = contact.userId;
            phoneNumber = contact.phone;
            
            FriendTableViewCell *cell = (FriendTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.invited = TRUE;
            
            if (isInvite) {
                [self.selectedReceivers addObject:[NSString stringWithFormat:@"%ld", contact.userId]];
                NSLog(@"Receivers count: %ld", self.selectedReceivers.count);
            }
        }
        else {
            APContact *contact = self.noFriendsList[indexPath.row];
            phoneNumber = contact.phones.firstObject.number;
            self.PFUserID = 0;
            
            ContactTableViewCell *cell = (ContactTableViewCell *) [self.tblView cellForRowAtIndexPath:indexPath];
            [cell.sendInvite setSelected:YES];
            
            contact.note = @"Yes";
            
            if (isInvite) {
                [self.selectedContacts addObject:phoneNumber];
                NSLog(@"Contacts count: %ld", self.selectedContacts.count);
            }
        }
    }
    
    if (!isInvite && !isShare && !isGroupInvite && !showGroups) {
   
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[Engine sharedEngine] dataManager] sendMeetMeRequest:phoneNumber withPFID:self.PFUserID meetMeText:meetMeText withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"%@", result);
            } else {
                
                //[self showErrorMessage:errorInfo];
            }
        }];
    }
    else if (isShare) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[Engine sharedEngine] dataManager] sharePin:phoneNumber withGroupID:groupID withPFID:self.PFUserID withPin:pinID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"%@", result);
            } else {
                
                //[self showErrorMessage:errorInfo];
            }
        }];
    }
    else if (isGroupInvite) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[Engine sharedEngine] dataManager] sendGroupInvite:groupID withPhone:phoneNumber withPFID:self.PFUserID shareText:meetMeText withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"%@", result);
            } else {
                
                //[self showErrorMessage:errorInfo];
            }
        }];
    }
}

- (IBAction) closeList {
    
    if (showGroups) {
        
        [self.delegate confirmInvites:self withContacts:self.selectedContacts withReceivers:self.selectedReceivers withGroups:self.selectedGroups];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createGroup:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[Engine sharedEngine] dataManager] addFanGroup:self.groupname withTeam:self.team withContacts:[self.selectedContacts componentsJoinedByString:@","] withReceivers:[self.selectedReceivers componentsJoinedByString:@","] andPhoto:self.photo withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        
        if (success) {
            
            [self showSuccessMessage:[NSString stringWithFormat:@"Your group, %@, has been created. And your invites have been sent.", self.groupname]];
            
            BOOL foundController = FALSE;
            
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[MapViewController class]]) {
                     foundController = TRUE;
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    MyGroupsViewController *mygroupsVC = [storyboard instantiateViewControllerWithIdentifier:@"mygroupsVC"];
                    [self.navigationController pushViewController:mygroupsVC animated:YES];
                }
            }
             
             if (!foundController) {
             
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
                 [self.navigationController pushViewController:mapVC animated:YES];
             }
        
             [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // [self showErrorMessage:errorInfo];
        }
    }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (isShare || showGroups)
        return 3;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isShare || showGroups) {
     
        if (section == 0)
            return self.groups.count;
        else if (section == 1)
            return self.pfUsersList.count;
        else
            return self.noFriendsList.count;
    }
    else {
        
        if (section == 0)
            return self.pfUsersList.count;
        else
            return self.noFriendsList.count;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
    [headerView setBackgroundColor:rgbColor(27, 153, 214)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,tableView.frame.size.width-10,22)];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:14.0]];
    
    if (isShare || showGroups) {
        
        if (section == 0 && self.groups.count > 0)
            headerLabel.text = @"My Groups";
        else if (section == 0 && self.groups.count == 0) {
            
            [headerView setFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            headerLabel.text = @"";
        }
        else if (section == 1 && self.pfUsersList.count > 0)
            headerLabel.text = @"Paranoid Fans in my address book";
        else if (section == 1 && self.pfUsersList.count == 0) {
            
            [headerView setFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            headerLabel.text = @"";
        }
        else
            headerLabel.text = @"Contacts";
    }
    else {
        
        if (section == 0 && self.pfUsersList.count > 0)
            headerLabel.text = @"Paranoid Fans in my address book";
        else if (section == 0 && self.pfUsersList.count == 0) {
            
            [headerView setFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            headerLabel.text = @"";
        }
        else
            headerLabel.text = @"Contacts";
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isShare || showGroups) {
        
        if (indexPath.section == 0) {
            
            FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactPFCell" forIndexPath:indexPath];
            
            Group *group = self.groups[indexPath.row];
            
            cell.lblFullname.text = group.group;
            cell.lblPhone.text = @"";
            cell.avatar.image = [UIImage imageNamed:@"Groups"];
            
            if (group.invited)
                [cell.sendInvite setSelected:YES];
            else
                [cell.sendInvite setSelected:NO];
            
            return  cell;
        }
        else if (indexPath.section == 1) {
            
            FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactPFCell" forIndexPath:indexPath];
            
            User *friend = self.pfUsersList[indexPath.row];
            [cell setUserfriend:friend];
            
            if (friend.invited)
                [cell.sendInvite setSelected:YES];
            else
                [cell.sendInvite setSelected:NO];
            
            return  cell;
        }
        else if (indexPath.section == 2) {
            
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
    else {
       
        if (indexPath.section == 0) {
            
            FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contactPFCell" forIndexPath:indexPath];
            
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
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Helper

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
