//
//  Group.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/11/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "Group.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"
#import <MapKit/MapKit.h>

@implementation Group

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Group *group = [[Group alloc] init];
    
 //   NSLog(@"Group ID %@", [json safeObjectForKey:@"group_id"]);
    group.groupID = [[json safeObjectForKey:@"group_id"] integerValue];
    group.userID = [[json safeObjectForKey:@"user_id"] integerValue];
    group.group = [json safeObjectForKey:@"group_name"];
    group.cover = [json safeObjectForKey:@"group_cover_photo"];
    group.team = [json safeObjectForKey:@"team"];
    group.dateCreated = [NSDate dateFronJSON:[json safeObjectForKey:@"date_created"]];
    group.imageWidth = [[json safeObjectForKey:@"image_width"] integerValue];
    group.imageHeight = [[json safeObjectForKey:@"image_height"] integerValue];
    group.type = @"Group";
    group.invited = FALSE;
    
    return group;
}

#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.group;
}

- (NSString *)getSearchTags
{
    return nil;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:0.00 longitude:0.00];
    return location;
}

- (NSString *)getDistance
{
    return nil;
}

- (NSString *)getPinType
{
    return self.type;
}

@end
