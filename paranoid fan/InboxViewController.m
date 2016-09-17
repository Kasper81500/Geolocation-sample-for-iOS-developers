//
//  InboxViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/4/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "InboxViewController.h"
#import "Engine.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+Popup.h"
#import "Message.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import "MessageTableViewCell.h"
#import "MessagesViewController.h"
#import "FriendListViewController.h"
#import "GroupChatViewController.h"
//#import "MapViewController.m"


@interface InboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 58.0;
    
    [self getInboxMessages];
}

#pragma mark - IBActions

- (IBAction)clickBackBtn:(id)sender {
    
   // BOOL foundController = FALSE;
    
/*    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[MapViewController class]]) {
            foundController = TRUE;
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
 
    if (!foundController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
        [self.navigationController pushViewController:mapVC animated:YES];
    }*/
    
    [self.navigationController popViewControllerAnimated:YES];
  //  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBtnNew:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendListViewController *friendVC = [storyboard instantiateViewControllerWithIdentifier:@"friendList"];
    friendVC.frindsOnly = TRUE;
    [self.navigationController pushViewController:friendVC animated:NO];
}


#pragma UITableView Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 64.0;
//}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *message = self.messages[indexPath.row];
    
    
    static NSString *identifier1 = @"inboxCellMessage";
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
    
    [cell setChatItem:message];
    
    cell.lblTime.text = [[message dateCreated] timeAgoSimple];
    if ([[Engine sharedEngine] settingManager].userID != message.senderId) {
        
        if (!message.isRead) {
            
            [cell.msgTxt setFont:[UIFont fontWithName:@"Roboto-Bold" size:15]];
        }
        else {
            
            [cell.msgTxt setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
        }
    }
    else {
        
        [cell.msgTxt setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    }
    
    if ([message.message isEqualToString:@"shared photo"] || [message.message isEqualToString:@"posted sticker"])
        [cell.msgTxt setFont:[UIFont fontWithName:@"Roboto-italic" size:15]];
    
    if (message.groupId > 0 || message.userGroupId > 0)
         cell.avatar.image = [UIImage imageNamed:@"Groups"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"I m clicked");
    
    Message *message = self.messages[indexPath.row];
    
    if ([message.message isEqualToString:@"Meetme request"]) {
        [self.inboxDelegate inboxViewController:self withLatitude:message.latitude withLongitude:message.longitude];
        [self clickBackBtn:nil];
    }
    else {
        NSLog(@"Group ID: %ld", message.userGroupId);
        if (message.userGroupId > 0) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MessagesViewController *messagesVC = [storyboard instantiateViewControllerWithIdentifier:@"directMessagesView"];
            messagesVC.receiverName = message.profileName;
            messagesVC.isGroup = YES;
            messagesVC.groupID = message.userGroupId;
            [self.navigationController pushViewController:messagesVC animated:YES];
        }
        else {
           
            if (message.groupId == 0) {
            
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MessagesViewController *messagesVC = [storyboard instantiateViewControllerWithIdentifier:@"directMessagesView"];
                messagesVC.receiverID = message.receiverId;
                messagesVC.receiverName = message.profileName;
                [self.navigationController pushViewController:messagesVC animated:YES];
            
            }
            else {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                GroupChatViewController *groupVC = [storyboard instantiateViewControllerWithIdentifier:@"groupChatView"];
                groupVC.groupID = message.groupId;
                groupVC.groupName = message.profileName;
                [self.navigationController pushViewController:groupVC animated:YES];
            }
        }
    }
    
}

#pragma mark - Loading Methods

- (void) getInboxMessages
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[Engine sharedEngine] dataManager] getInbox:[[[Engine sharedEngine] settingManager] userID] withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (success) {
             NSLog(@"Result %@",result);
             
             NSArray *chats = (NSArray *)result;
             self.messages = [NSMutableArray arrayWithArray:chats];
             [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
           
         }
     }];
}

@end
