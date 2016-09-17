//
//  ContactTableViewCell.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ContactTableViewCell.h"
#import <APContact.h>


@implementation ContactTableViewCell

- (void)setContact:(APContact *)contact
{
    _contact = contact;
    
    self.thubnailImageView.image = contact.thumbnail;
    
    
    if (contact.name.firstName && contact.name.lastName) {
        self.userNameLabel.text = [contact.name.firstName stringByAppendingFormat:@" %@", contact.name.lastName];
    } else {
        self.userNameLabel.text = contact.name.firstName;
    }

    self.phoneLabel.text = contact.phones.firstObject.number;
        
}

@end
