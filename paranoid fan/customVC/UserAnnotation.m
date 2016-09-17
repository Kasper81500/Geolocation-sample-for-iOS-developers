//
//  UserAnnotation.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "UserAnnotation.h"
#import "User.h"

@implementation UserAnnotation

- (id)initWithUser:(User *)user
{
    if (self = [super init]) {
        self.user = user;
        self.coordinate = CLLocationCoordinate2DMake(user.currentLatitude, user.currentLongitude);
        _title = user.fullname;
        _isForCurrentUser = NO;
    }
    return self;
}

@end
