//
//  PinAnnotation.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Pin;

@interface PinAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) Pin *pin;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithPin:(Pin *)pin;

@end
