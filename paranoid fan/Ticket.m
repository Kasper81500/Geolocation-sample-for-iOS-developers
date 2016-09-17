//
//  Ticket.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "Ticket.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"
#import <MapKit/MapKit.h>

@implementation Ticket

+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Ticket *ticket = [[Ticket alloc] init];
    
    ticket.type = [json safeObjectForKey:@"type"];
    ticket.distance = [json safeObjectForKey:@"distance"];
    ticket.fullname = [json safeObjectForKey:@"fullname"];
    ticket.email = [json safeObjectForKey:@"email_address"];
    ticket.profileAvatar = [json safeObjectForKey:@"profile_avatar"];
    ticket.delivery = [json safeObjectForKey:@"ticket_delivery"];
    ticket.detail = [json safeObjectForKey:@"ticket_detail"];
    ticket.tags = [json safeObjectForKey:@"ticket_tags"];
    ticket.title = [json safeObjectForKey:@"ticket_title"];
    ticket.dateCreated = [NSDate dateFronJSON:[json safeObjectForKey:@"ticket_date_created"]];
    ticket.startDate = [json safeObjectForKey:@"start_date"];
    ticket.endDate = [json safeObjectForKey:@"end_date"];
    ticket.eventURL = [json safeObjectForKey:@"event_url"];
    ticket.price = [[json safeObjectForKey:@"ticket_price"] floatValue];
    ticket.latitude = [[json safeObjectForKey:@"ticket_latitude"] doubleValue];
    ticket.longitude = [[json safeObjectForKey:@"ticket_longitude"] doubleValue];
    ticket.ticketId = [[json safeObjectForKey:@"ticket_id"] integerValue];
    ticket.quantity = [[json safeObjectForKey:@"ticket_quantity"] integerValue];
    ticket.section = [[json safeObjectForKey:@"ticket_section"] integerValue];
    ticket.sold = [[json safeObjectForKey:@"ticket_sold"] integerValue];
    ticket.phone = [json safeObjectForKey:@"ticket_phone"];
    
    return ticket;
}

#pragma mark - SearchItem

- (NSString *)getSearchTitle
{
    return self.title;
}

- (NSString *)getSearchTags
{
    return self.tags;
}

- (NSString *)getDistance
{
    return self.distance;
}

- (CLLocation *)getLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    return location;
}

#pragma mark - MapMarkerItem

- (CLLocation *)getMapLocation
{
    return [self getLocation];
}

- (UIImage *)getMarkerIcon
{
    return [UIImage imageNamed:@"withTicket"];
}

- (NSString *)getMarkerIconURL
{
    return nil;
}

#pragma mark - NSSet methods

- (BOOL)isEqual:(id)anObject
{
    return self.ticketId == [anObject ticketId];
}

- (NSUInteger)hash
{
    return self.ticketId;
}

@end
