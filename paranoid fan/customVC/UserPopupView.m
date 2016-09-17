//
//  UserPopupView.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/14/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "UserPopupView.h"
#import "User.h"
#import <UIImageView+AFNetworking.h>

@interface UserPopupView()

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userPointsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageVIew;

@end

@implementation UserPopupView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageVIew.clipsToBounds = YES;
    self.avatarImageVIew.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5;
//    
//    self.layer.borderWidth = 5.0;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.cornerRadius = 2.0;
//    
//    self.layer.shadowOffset = CGSizeMake(-1, 1);
}

- (void)setUser:(User *)user
{
    _user = user;
    if (self.user.mapAvatar) {
        [self.avatarImageVIew setImageWithURL:[NSURL URLWithString:self.user.mapAvatar]];
    }
         
    self.userNameLabel.text = self.user.fullname;
    self.userPointsLabel.text = [NSString stringWithFormat:@"%zd",self.user.profilePoints];
}

@end
