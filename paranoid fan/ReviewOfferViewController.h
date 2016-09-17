//
//  ReviewOfferViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BaseTicketViewController.h"

@interface ReviewOfferViewController : BaseTicketViewController

@property (nonatomic, strong) NSString *ticketTitle;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic) NSInteger quantity;
@property (nonatomic) NSInteger section;
@property (nonatomic) CGFloat price;
@property (nonatomic) BOOL delivery;

@end
