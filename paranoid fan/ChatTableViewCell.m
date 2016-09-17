//
//  ChatTableViewCell.m
//  paranoid fan
//
//  Created by Ferenc Knebl on 02/09/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ChatItem.h"
#import "NSDate+TimeAgo.h"

@implementation ChatTableViewCell

- (void)setChatItem:(id<ChatItem>)chatItem
{
    [super setChatItem:chatItem];
    
    NSString *distance = [chatItem distance];
    NSString *timeAgo = [[chatItem dateCreated] timeAgo];
    self.lblTime.text = [NSString stringWithFormat:@"%@ - %@",distance, timeAgo];

    [self layoutIfNeeded];
    [self setNeedsUpdateConstraints];    
}

@end
