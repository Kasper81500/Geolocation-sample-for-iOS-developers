//
//  Pin.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "Pin.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"

@implementation Pin

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Pin *pin = [[Pin alloc] init];
    
    pin.pinID = [[json safeObjectForKey:@"map_pin_id"] integerValue];
    pin.userID = [[json safeObjectForKey:@"user_id"] integerValue];
    pin.mapPinPhoto = [json safeObjectForKey:@"map_pin_photo"];
    pin.mapPinCoverPhoto = [json safeObjectForKey:@"map_pin_cover_photo"];
    pin.mapPinTags = [json safeObjectForKey:@"map_pin_tags"];
    pin.mapPinTitle = [json safeObjectForKey:@"map_pin_title"];
    pin.mapPinType = [json safeObjectForKey:@"map_pin_type"];
    pin.mapPinLatitude = [[json safeObjectForKey:@"map_pin_latitude"] doubleValue];
    pin.mapPinLongitude = [[json safeObjectForKey:@"map_pin_longitude"] doubleValue];
    pin.mapAddress = [json safeObjectForKey:@"map_address"];
    pin.dateCreated = [NSDate dateFronJSON:[json safeObjectForKey:@"map_pin_date_created"]];
    pin.rated = [[json safeObjectForKey:@"rated"] boolValue];
    pin.rating = [[json safeObjectForKey:@"map_pin_rating"] integerValue];
    pin.isFavorite = [[json safeObjectForKey:@"favorite"] boolValue];
    pin.isVerified = [json safeObjectForKey:@"map_pin_verified"];
    pin.distance = [json safeObjectForKey:@"distance"];
        
    return pin;
}

#pragma mark - NSSet methods

- (BOOL)isEqual:(id)anObject
{
    Pin *otherPin = (Pin *)anObject;
    
    return self.pinID == otherPin.pinID;
}

- (NSUInteger)hash
{
    return self.pinID;
}

- (UIImage *)pinImage
{
    NSString *pinImage;
    
    if ([self.mapPinType isEqualToString:@"Beer"]) {
        
        pinImage = [self.mapPinType stringByAppendingFormat:@"_%@", self.mapPinTags];
        
        if ([UIImage imageNamed:pinImage] == nil)
            pinImage = self.mapPinType;
        
       /* if ([self.mapPinTags containsString:@"American Outlaws"])
            pinImage = [self.mapPinType stringByAppendingString:@"_AO"];
        else if ([self.mapPinTags containsString:@"Bears"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Bears"];
        else if ([self.mapPinTags containsString:@"Bills"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Bills"];
        else if ([self.mapPinTags containsString:@"Colts"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Colts"];
        else if ([self.mapPinTags containsString:@"Jets"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Jets"];
        else if ([self.mapPinTags containsString:@"Lions"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Lions"];
        else if ([self.mapPinTags containsString:@"49ers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_49ers"];
        else if ([self.mapPinTags containsString:@"Bengals"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Bengals"];
        else if ([self.mapPinTags containsString:@"Bronocos"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Bronocos"];
        else if ([self.mapPinTags containsString:@"Browns"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Browns"];
        else if ([self.mapPinTags containsString:@"Buccaneers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Buccaneers"];
        else if ([self.mapPinTags containsString:@"Cardinals"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Cardinals"];
        else if ([self.mapPinTags containsString:@"Chargers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Chargers"];
        else if ([self.mapPinTags containsString:@"Chiefs"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Chiefs"];
        else if ([self.mapPinTags containsString:@"Cowboys"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Cowboys"];
        else if ([self.mapPinTags containsString:@"Dolphins"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Dolphins"];
        else if ([self.mapPinTags containsString:@"Eagles"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Eagles"];
        else if ([self.mapPinTags containsString:@"Falcons"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Falcons"];
        else if ([self.mapPinTags containsString:@"Giants"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Giants"];
        else if ([self.mapPinTags containsString:@"Jaguars"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Jaguars"];
        else if ([self.mapPinTags containsString:@"Packers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Packers"];
        else if ([self.mapPinTags containsString:@"Panthers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Panthers"];
        else if ([self.mapPinTags containsString:@"Patriots"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Patriots"];
        else if ([self.mapPinTags containsString:@"Raiders"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Raiders"];
        else if ([self.mapPinTags containsString:@"Rams"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Rams"];
        else if ([self.mapPinTags containsString:@"Ravens"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Ravens"];
        else if ([self.mapPinTags containsString:@"Redskin"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Redskin"];
        else if ([self.mapPinTags containsString:@"Saints"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Saints"];
        else if ([self.mapPinTags containsString:@"Seahawks"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Seahawks"];
        else if ([self.mapPinTags containsString:@"Steelers"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Steelers"];
        else if ([self.mapPinTags containsString:@"Texans"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Texans"];
        else if ([self.mapPinTags containsString:@"Titans"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Titans"];
        else if ([self.mapPinTags containsString:@"Vikings"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Vikings"];
        else if ([self.mapPinTags containsString:@"Arsenal"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Arsenal"];
        else if ([self.mapPinTags containsString:@"Barcelona"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Barcelona"];
        else if ([self.mapPinTags containsString:@"Chelsea"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Chelsea"];
        else if ([self.mapPinTags containsString:@"Liverpool"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Liverpool"];
        else if ([self.mapPinTags containsString:@"Manchester United"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Manchester United"];
        else if ([self.mapPinTags containsString:@"Florida"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Florida"];
        else if ([self.mapPinTags containsString:@"Ohio"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Ohio"];
        else if ([self.mapPinTags containsString:@"Iowa"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Iowa"];
        else if ([self.mapPinTags containsString:@"LSU"])
            pinImage = [self.mapPinType stringByAppendingString:@"_LSU"];
        else if ([self.mapPinTags containsString:@"Texas"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Texas"];
        else if ([self.mapPinTags containsString:@"USC"])
            pinImage = [self.mapPinType stringByAppendingString:@"_USC"];
        else if ([self.mapPinTags containsString:@"Utah"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Utah"];
        else if ([self.mapPinTags containsString:@"Air Force"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Air Force"];
        else if ([self.mapPinTags containsString:@"Alabama"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Alabama"];
        else if ([self.mapPinTags containsString:@"Arizona"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Arizona"];
        else if ([self.mapPinTags containsString:@"Auburn"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Auburn"];
        else if ([self.mapPinTags containsString:@"Georgia Tech"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Georgia Tech"];
        else if ([self.mapPinTags containsString:@"Georgia"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Georgia"];
        else if ([self.mapPinTags containsString:@"Kentucky"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Kentucky"];
        else if ([self.mapPinTags containsString:@"Louisville"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Louisville"];
        else if ([self.mapPinTags containsString:@"Michigan State"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Michigan State"];
        else if ([self.mapPinTags containsString:@"Michigan"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Michigan"];
        else if ([self.mapPinTags containsString:@"Missouri"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Missouri"];
        else if ([self.mapPinTags containsString:@"Nebraska"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Nebraska"];
        else if ([self.mapPinTags containsString:@"North Carolina"])
            pinImage = [self.mapPinType stringByAppendingString:@"_North Carolina"];
        else if ([self.mapPinTags containsString:@"Notre Dame"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Notre Dame"];
        else if ([self.mapPinTags containsString:@"Oklahoma"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Oklahoma"];
        else if ([self.mapPinTags containsString:@"Oregon"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Oregon"];
        else if ([self.mapPinTags containsString:@"Pittsburgh"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Pittsburgh"];
        else if ([self.mapPinTags containsString:@"Purdue"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Purdue"];
        else if ([self.mapPinTags containsString:@"Syracuse"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Syracuse"];
        else if ([self.mapPinTags containsString:@"Virginia Tech"])
            pinImage = [self.mapPinType stringByAppendingString:@"_Virginia Tech"];
        else
            pinImage = self.mapPinType;
    */
    }
    else
        pinImage = self.mapPinType;
    
    UIImage *image = [UIImage imageNamed:pinImage];
    if (!image) {
        image = [UIImage imageNamed:@"Tailgate"];
        NSLog(@"\n\n\n\nWARNING MISSSING ICON FOR TYPE: %@",self.mapPinType);
    }
    
    return image;
}

- (CLLocationCoordinate2D)getLocationCoordinate
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.mapPinLatitude, self.mapPinLongitude);
    return location;
}

#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.mapPinTitle;
}

- (NSString *)getSearchTags
{
    return self.mapPinTags;
}

- (NSString *)getPinType
{
    return self.mapPinType;
}

- (NSString *)getDistance
{
    return self.distance;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapPinLatitude longitude:self.mapPinLongitude];
    return location;
}

#pragma mark - MapMarkerItem

- (CLLocation *)getMapLocation
{
    return [self getLocation];
}

- (UIImage *)getMarkerIcon
{
    return [self pinImage];
}

- (NSString *)getMarkerIconURL
{
    return nil;
}

- (NSString *)getMarkerType
{
    return [self getPinType];
}

- (NSString *)getMarkerTags
{
    return [self getMarkerTags];
}


@end
