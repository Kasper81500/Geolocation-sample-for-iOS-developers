//
//  TicketAnnotaion.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Ticket;

@interface TicketAnnotaion : NSObject<MKAnnotation>

@property (nonatomic, weak) Ticket *ticket;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithTicket:(Ticket *)ticket;


@end
