//
//  TicketTableViewCell.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "TicketTableViewCell.h"
#import "Ticket.h"

@implementation TicketTableViewCell

- (void)setTicket:(Ticket *)ticket
{
    _ticket = ticket;
    
    self.titleLabel.text = ticket.title;
    
    if ([ticket.type isEqualToString:@"TICKETMASTER"]) {
        
        self.sectionLabel.text = ticket.startDate;
        self.qtyLabel.text = ticket.endDate;
        self.priceLabel.text = ticket.detail;
    }
    else {
        
        self.sectionLabel.text = [NSString stringWithFormat:@"Section %d",ticket.section];
        self.qtyLabel.text = [NSString stringWithFormat:@"%d",ticket.quantity];
        self.priceLabel.text = [NSString stringWithFormat:@"$%.2f",ticket.price];
        
    }
    self.distLabel.text = ticket.distance;
}

- (IBAction)buyTicket:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ticketCell:willBuyTicket:)]) {
        [self.delegate ticketCell:self willBuyTicket:self.ticket];
    }
}

@end
