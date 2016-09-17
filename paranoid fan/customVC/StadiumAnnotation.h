//
//  StadiumAnnotation.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Stadium;

@interface StadiumAnnotation : NSObject<MKAnnotation>

@property (nonatomic, weak) Stadium *stadium;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithStadium:(Stadium *)ticket;

@end
