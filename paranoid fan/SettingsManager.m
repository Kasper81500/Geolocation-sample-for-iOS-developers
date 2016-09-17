//
//  SettingsManager.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SettingsManager.h"
#import "User.h"

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

#define kCurrentUser @"kCurrentUser"

@implementation SettingsManager

- (instancetype)init {
    if (self = [super init]) {
        _user = [self loadUser];
    }
    return self;
}



- (NSInteger)userID
{
    if (self.user) {
        return self.user.userId;
    }
    return 0;
}

- (void)setUser:(User *)user
{
    _user = user;
    if (user) {
        [self saveCurrentUser:user];
    } else {
        [self removeCurrentUser];
    }
}

- (void)saveUser
{
    [self saveCurrentUser:self.user];
}

-(void)saveCurrentUser:(User *)user
{
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [USER_DEFAULTS setObject:encodedUser forKey:kCurrentUser];
}

- (void)removeCurrentUser
{
    [USER_DEFAULTS removeObjectForKey:kCurrentUser];
}

-(User *)loadUser
{
    NSData *userData = [USER_DEFAULTS objectForKey:kCurrentUser];
    if (userData) {
        User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:userData];
        return user;
    }
    
    return nil;
}

@end
