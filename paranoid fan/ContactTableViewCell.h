//
//  ContactTableViewCell.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APContact;

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thubnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *sendInvite;

@property (nonatomic, weak) APContact *contact;

@end
