//
//  PinAnnotation.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PinAnnotation.h"
#import "Pin.h"

@implementation PinAnnotation

- (id)initWithPin:(Pin *)pin
{
    if (self = [super init]) {
        self.pin = pin;
        self.coordinate = CLLocationCoordinate2DMake(pin.mapPinLatitude,pin.mapPinLongitude);
    }
    return self;
}

@end
