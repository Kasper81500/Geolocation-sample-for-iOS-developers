//
//  FriendTableViewCell.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/29/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "FriendTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation FriendTableViewCell

- (void)setUserfriend:(User *)userfriend {
    
    [self.avatar setImageWithURL:[NSURL URLWithString:userfriend.profileAvatar]];
    self.lblFullname.text = userfriend.fullname;
    self.lblPhone.text = userfriend.phone;
}

@end
