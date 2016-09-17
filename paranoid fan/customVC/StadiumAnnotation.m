//
//  StadiumAnnotation.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "StadiumAnnotation.h"
#import "Stadium.h"

@implementation StadiumAnnotation

- (id)initWithStadium:(Stadium *)stadium
{
    if (self = [super init]) {
        self.stadium = stadium;
        self.coordinate = CLLocationCoordinate2DMake(stadium.latitude,stadium.longitude);
    }
    return self;
}

@end
