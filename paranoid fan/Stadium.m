//
//  Stadium.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "Stadium.h"
#import "NSDictionary+Safe.h"
#import <MapKit/MapKit.h>

@implementation Stadium

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Stadium *stadium = [[Stadium alloc] init];
    
    stadium.stadiumId = [[json safeObjectForKey:@"stadium_id"] integerValue];
    stadium.latitude = [[json safeObjectForKey:@"stadium_latitude"] doubleValue];
    stadium.longitude = [[json safeObjectForKey:@"stadium_longitude"] doubleValue];
    stadium.distance = [json safeObjectForKey:@"distance"];
    stadium.city = [json safeObjectForKey:@"stadium_city"];
    stadium.name = [json safeObjectForKey:@"stadium_name"];
    stadium.state = [json safeObjectForKey:@"stadium_state"];
    stadium.team = [json safeObjectForKey:@"stadium_team"];
      
    return stadium;
}


#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.name;
}

- (NSString *)getSearchTags
{
    NSString *customTags = [NSString stringWithFormat:@"%@,%@,%@",self.city,self.state,self.team];
    return customTags;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    return location;
}

- (NSString *)getPinType
{
    return @"Stadium";
}

- (NSString *)getDistance
{
    return self.distance;
}

#pragma mark - MapMarkerItem

- (CLLocation *)getMapLocation
{
    return [self getLocation];
}

- (UIImage *)getMarkerIcon
{
    return [UIImage imageNamed:@"stadium_map_icon"];
}

- (NSString *)getMarkerIconURL
{
    return nil;
}

#pragma mark - NSSet methods

- (BOOL)isEqual:(id)anObject
{
    return self.stadiumId == [anObject stadiumId];
}

- (NSUInteger)hash
{
    return self.stadiumId;
}

@end
