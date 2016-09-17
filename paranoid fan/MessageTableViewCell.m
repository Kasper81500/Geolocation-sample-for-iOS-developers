//
//  MessageTableViewCell.m
//  paranoid fan
//
//  Created by Adeel Asim on 4/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+TimeAgo.h"

@implementation MessageTableViewCell

- (void)setChatItem:(id<ChatItem>)chatItem {

    _chatItem = chatItem;
    
    self.receiverName.text = self.chatItem.profileName;
    NSString *attrString = self.chatItem.message;
    NSString *dateTime = [[self.chatItem dateCreated] timeAgo];
    
    self.msgTxt.text = attrString;
    self.lblTime.text = dateTime;
    
    if ([self.chatItem.message isEqualToString:@"Meetme request"])
        self.avatar.image = [UIImage imageNamed:@"Meet Me"];
    else
        [self.avatar setImageWithURL:[NSURL URLWithString:self.chatItem.avatar]];
    
    if (self.chatItem.photo.length > 0) {
        [self.photo setImageWithURL:[NSURL URLWithString:self.chatItem.photo]];
    }
    
}

@end
