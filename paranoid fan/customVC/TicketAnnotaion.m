//
//  TicketAnnotaion.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "TicketAnnotaion.h"
#import "Ticket.h"

@implementation TicketAnnotaion

- (id)initWithTicket:(Ticket *)ticket
{
    if (self = [super init]) {
        self.ticket = ticket;
        self.coordinate = CLLocationCoordinate2DMake(ticket.latitude,ticket.longitude);
    }
    return self;
}

@end
