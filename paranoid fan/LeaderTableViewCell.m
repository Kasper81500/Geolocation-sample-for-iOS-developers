//
//  LeaderTableViewCell.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/11/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "LeaderTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"

@interface LeaderTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImage;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *pointsLabel;

@end

@implementation LeaderTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat radius = CGRectGetWidth(self.avatarImage.bounds) * 0.5;
    self.avatarImage.layer.cornerRadius = radius;
    self.avatarImage.clipsToBounds = YES;
}

- (void)setUser:(User *)user
{
    _user = user;
    
    UIImage *placeholderImage = [UIImage imageNamed:@"your_picture"];
    if (user.profileAvatar) {
        [self.avatarImage setImageWithURL:[NSURL URLWithString:user.profileAvatar] placeholderImage:placeholderImage];
    } else {
        [self.avatarImage setImage:placeholderImage];
    }
    
    self.nameLabel.text = user.fullname;
    self.pointsLabel.text = [NSString stringWithFormat:@"%zd",user.profilePoints];
}

@end
