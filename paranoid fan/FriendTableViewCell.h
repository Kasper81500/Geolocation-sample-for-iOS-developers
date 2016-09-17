//
//  FriendTableViewCell.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/29/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface FriendTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *lblFullname;
@property (nonatomic, weak) IBOutlet UILabel *lblPhone;
@property (nonatomic, weak) IBOutlet UIButton *sendInvite;

@property (nonatomic, weak) User *userfriend;

@end
