//
//  MapPoint.m
//  LinkedInMap
//
//  Created by Pradyumna Doddala on 31/08/12.
//  Copyright (c) 2012 Pradyumna Doddala. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate{
    self = [super init];
    if (self) {
        coordinate = aCoordinate;
     }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = coordinate.latitude;
    theCoordinate.longitude = coordinate.longitude;
    return theCoordinate;
}
@end
