//
//  MessageTableViewCell.h
//  paranoid fan
//
//  Created by Adeel Asim on 4/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *receiverName;
@property (nonatomic, weak) IBOutlet UILabel *msgTxt;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UIImageView *sticker;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *photoHeightConstraint;

@property (weak, nonatomic) id<ChatItem> chatItem;


@end
