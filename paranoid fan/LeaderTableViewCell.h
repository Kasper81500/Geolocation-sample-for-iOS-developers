//
//  LeaderTableViewCell.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/11/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface LeaderTableViewCell : UITableViewCell

@property (nonatomic, weak) User *user;

@end
