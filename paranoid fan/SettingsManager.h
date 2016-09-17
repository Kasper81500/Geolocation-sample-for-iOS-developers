//
//  SettingsManager.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SettingsManager : NSObject

@property (nonatomic, readonly) NSInteger userID;
@property (nonatomic) User *user;


- (void)saveUser;

@end
