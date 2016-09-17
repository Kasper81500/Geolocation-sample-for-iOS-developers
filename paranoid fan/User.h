//
//  User.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"
#import "SearchItem.h"
#import "MapMarkerItem.h"

@class CLLocation;

@interface User : NSObject<NSCoding,ModelParserProtocol,SearchItem, MapMarkerItem>

@property (nonatomic) BOOL checkinSocial;
@property (nonatomic) double currentLatitude;
@property (nonatomic) double currentLongitude;
@property (nonatomic) NSDate *dateRegistered;
@property (nonatomic) NSDate *birthday;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *phoneVerified;
@property (nonatomic) NSString *emailAddress;
@property (nonatomic) NSString *fullname;
@property (nonatomic) NSString *mapAvatar;
@property (nonatomic) NSString *profileAvatar;
@property (nonatomic) NSInteger profilePoints;
@property (nonatomic) BOOL showLocation;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *tagsString;
@property (nonatomic) NSString *groupsString;
@property (nonatomic) double wallet_balance;
@property (nonatomic) BOOL ccAdded;
@property (nonatomic) BOOL bankAdded;
@property (nonatomic) BOOL invited;

- (CLLocation *)getLocation;
- (NSString *)getSearchTags;
- (double)getBalance;

@end
