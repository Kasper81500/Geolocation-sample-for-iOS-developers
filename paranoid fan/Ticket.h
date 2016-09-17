//
//  Ticket.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelParserProtocol.h"
#import "SearchItem.h"
#import "MapMarkerItem.h"

@interface Ticket : NSObject<ModelParserProtocol,SearchItem>

@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *profileAvatar;
@property (nonatomic, strong) NSString *delivery;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *eventURL;
@property (nonatomic, strong) NSString *type;

@property (nonatomic) CGFloat price;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic) NSInteger ticketId;
@property (nonatomic) NSInteger quantity;
@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger sold; 

@end
