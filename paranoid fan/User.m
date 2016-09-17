//
//  User.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "User.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"
#import <MapKit/MapKit.h>

#define kCheckin_social	 @"checkin_social"
#define kCurrent_latitude	 @"current_latitude"
#define kCurrent_longitude	 @"current_longitude"
#define kDate_registered	 @"date_registered"
#define kPhone	 @"phone"
#define kPhoneVerified	 @"phone_verified"
#define kEmail_address	 @"email_address"
#define kFullname	 @"fullname"
#define kMap_avatar	 @"map_avatar"
#define kProfile_avatar	 @"profile_avatar"
#define kProfile_points	 @"profile_points"
#define kShow_location	 @"show_location"
#define kUser_id	 @"user_id"
#define kPassword	 @"password"
#define kTeamTags  @"team_tags"
#define kGroups  @"groups"
#define kBirthday   @"birthday"
#define kCCAdded  @"cc_added"
#define kBankAdded   @"bank_added"
#define kInvited   @"invited"
#define kWallet   @"wallet_balance"

@implementation User

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    User *user = [[User alloc] init];
    
    user.checkinSocial = [[json safeObjectForKey:kCheckin_social] boolValue];
    user.currentLatitude = [[json safeObjectForKey:kCurrent_latitude] doubleValue];
    user.currentLongitude = [[json safeObjectForKey:kCurrent_longitude] doubleValue];
    user.dateRegistered = [NSDate dateFronJSON:[json safeObjectForKey:kDate_registered]];
    user.birthday = [NSDate dateFronJSON:[json safeObjectForKey:kBirthday]];
    user.phone = [json safeObjectForKey:kPhone];
    user.phoneVerified = [json safeObjectForKey:kPhoneVerified];
    user.emailAddress = [json safeObjectForKey:kEmail_address];
    user.fullname = [json safeObjectForKey:kFullname];
    user.mapAvatar = [json safeObjectForKey:kMap_avatar];
    user.profileAvatar = [json safeObjectForKey:kProfile_avatar];
    user.profilePoints = [[json safeObjectForKey:kProfile_points] integerValue];
    user.showLocation = [[json safeObjectForKey:kShow_location] boolValue];
    user.userId = [[json safeObjectForKey:kUser_id] integerValue];
    user.tagsString = [json safeObjectForKey:kTeamTags];
    user.groupsString = [json safeObjectForKey:kGroups];
    user.wallet_balance = [[json safeObjectForKey:kWallet] doubleValue];
    user.ccAdded = [[json safeObjectForKey:kCCAdded] boolValue];
    user.bankAdded = [[json safeObjectForKey:kBankAdded] boolValue];
    user.invited = FALSE;
    
    return user;
}

#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.fullname;
}

- (NSString *)getSearchTags
{
    return self.tagsString;
}

- (NSString *)getDistance
{
    return nil;
}

- (double)getBalance
{
    return self.wallet_balance;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentLatitude longitude:self.currentLongitude];
    return location;
}

#pragma mark - MapMarkerItem

- (CLLocation *)getMapLocation
{
    return [self getLocation];
}

- (UIImage *)getMarkerIcon
{
    return [UIImage imageNamed:@"blue"];
}

- (NSString *)getMarkerIconURL
{
    return self.profileAvatar;
}

#pragma mark - NSSet methods

- (BOOL)isEqual:(id)anObject
{
    return self.userId == [anObject userId];
}

- (NSUInteger)hash
{
    return self.userId;
}


#pragma mark - Coding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:self.checkinSocial forKey:kCheckin_social];
    [encoder encodeDouble:self.currentLatitude forKey:kCurrent_latitude];
    [encoder encodeDouble:self.currentLongitude forKey:kCurrent_longitude];
    [encoder encodeDouble:[self.dateRegistered timeIntervalSince1970] forKey:kDate_registered];
    [encoder encodeDouble:[self.birthday timeIntervalSince1970] forKey:kBirthday];
    
    [encoder encodeObject:self.phone forKey:kPhone];
    [encoder encodeObject:self.phoneVerified forKey:kPhoneVerified];
    [encoder encodeObject:self.emailAddress forKey:kEmail_address];
    [encoder encodeObject:self.fullname forKey:kFullname];
    [encoder encodeObject:self.mapAvatar forKey:kMap_avatar];
    [encoder encodeObject:self.profileAvatar forKey:kProfile_avatar];
    
    [encoder encodeInteger:self.profilePoints forKey:kProfile_points];
    [encoder encodeBool:self.showLocation forKey:kShow_location];
    [encoder encodeInteger:self.userId forKey:kUser_id];
    
    [encoder encodeObject:self.password forKey:kPassword];
    [encoder encodeObject:self.tagsString forKey:kTeamTags];
    [encoder encodeObject:self.groupsString forKey:kGroups];
    
    [encoder encodeDouble:self.wallet_balance forKey:kWallet];
    [encoder encodeBool:self.ccAdded forKey:kCCAdded];
    [encoder encodeBool:self.bankAdded forKey:kBankAdded];
    [encoder encodeBool:self.invited forKey:kInvited];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        self.checkinSocial = [decoder decodeBoolForKey:kCheckin_social];
        self.currentLatitude = [decoder decodeDoubleForKey:kCurrent_latitude];
        self.currentLongitude = [decoder decodeDoubleForKey:kCurrent_longitude];
        self.dateRegistered = [NSDate dateWithTimeIntervalSince1970:[decoder decodeDoubleForKey:kDate_registered]];
        self.birthday = [NSDate dateWithTimeIntervalSince1970:[decoder decodeDoubleForKey:kBirthday]];
        self.phone = [decoder decodeObjectForKey:kPhone];
        self.phoneVerified = [decoder decodeObjectForKey:kPhoneVerified];
        self.emailAddress = [decoder decodeObjectForKey:kEmail_address];
        self.fullname = [decoder decodeObjectForKey:kFullname];
        self.mapAvatar = [decoder decodeObjectForKey:kMap_avatar];
        self.profileAvatar = [decoder decodeObjectForKey:kProfile_avatar];
        self.profilePoints = [decoder decodeIntegerForKey:kProfile_points];
        self.showLocation = [decoder decodeBoolForKey:kShow_location];
        self.userId = [decoder decodeIntegerForKey:kUser_id];
        self.tagsString = [decoder decodeObjectForKey:kTeamTags];
        self.groupsString = [decoder decodeObjectForKey:kGroups];
        self.wallet_balance = [decoder decodeDoubleForKey:kWallet];
        self.ccAdded = [decoder decodeBoolForKey:kCCAdded];
        self.bankAdded = [decoder decodeBoolForKey:kBankAdded];
        self.invited = [decoder decodeBoolForKey:kInvited];
    }
    return self;
}

@end
