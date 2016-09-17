//
//  Stadium.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "City.h"
#import "NSDictionary+Safe.h"
#import <MapKit/MapKit.h>

@implementation City

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    City *city = [[City alloc] init];
    
    city.cityId = [[json safeObjectForKey:@"city_id"] integerValue];
    city.latitude = [[json safeObjectForKey:@"latitude"] doubleValue];
    city.longitude = [[json safeObjectForKey:@"longitude"] doubleValue];
    city.city = [json safeObjectForKey:@"city"];
    city.state = [json safeObjectForKey:@"state"];
    
    return city;
}


#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    NSString *customTitle = [NSString stringWithFormat:@"%@, %@",self.city,self.state];
    return customTitle;
}

- (NSString *)getSearchTags
{
    return nil;
}

- (NSString *)getDistance
{
    return nil;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    return location;
}

- (NSString *)getPinType
{
    return @"City";
}

#pragma mark - MapMarkerItem

- (CLLocation *)getMapLocation
{
    return [self getLocation];
}

- (UIImage *)getMarkerIcon
{
    return nil;
}

- (NSString *)getMarkerIconURL
{
    return nil;
}

#pragma mark - NSSet methods

- (BOOL)isEqual:(id)anObject
{
    return self.cityId == [anObject cityId];
}

- (NSUInteger)hash
{
    return self.cityId;
}

@end
