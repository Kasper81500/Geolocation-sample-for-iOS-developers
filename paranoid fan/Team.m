//
//  Team.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "Team.h"
#import "NSDictionary+Safe.h"
#import <MapKit/MapKit.h>

@implementation Team

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Team *team = [[Team alloc] init];
    
    team.teamID = [[json safeObjectForKey:@"team_id"] integerValue];
    team.sport = [json safeObjectForKey:@"sport"];
    team.team = [json safeObjectForKey:@"team"];
    team.type = @"Fan";
    
    return team;
}

#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.team;
}

- (NSString *)getSearchTags
{
    return self.sport;
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
