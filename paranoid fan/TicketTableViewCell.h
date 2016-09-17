//
//  TicketTableViewCell.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ticket;
@class TicketTableViewCell;

@protocol TicketTableViewCellDelegate <NSObject>

- (void)ticketCell:(TicketTableViewCell *)cell willBuyTicket:(Ticket *)ticket;

@end


@interface TicketTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *sectionLabel;
@property (nonatomic, weak) IBOutlet UILabel *qtyLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;

@property (nonatomic, weak) Ticket *ticket;

@property (nonatomic, weak) id<TicketTableViewCellDelegate> delegate;

@end
