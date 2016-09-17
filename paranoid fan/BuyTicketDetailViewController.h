//
//  BuyTicketDetailViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BaseTicketViewController.h"
#import <PayPal-iOS-SDK/PayPalMobile.h>

@class Ticket;

@interface BuyTicketDetailViewController : BaseTicketViewController <PayPalPaymentDelegate>

@property (nonatomic, strong) Ticket *ticket;

@end
