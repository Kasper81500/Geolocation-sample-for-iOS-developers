//
//  PinsDropTableViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "DropTableViewController.h"
#import "SearchItem.h"

@class PinsDropTableViewController;

@protocol PinsDropDownDelegate <NSObject>

- (void)pinsTableView:(PinsDropTableViewController *)pinsTableVIew didSelectPin:(id<SearchItem>)pin;

@end

@interface PinsDropTableViewController : DropTableViewController

@property (nonatomic, strong) NSMutableArray *citiesItems;
@property (nonatomic, strong) NSMutableArray *venueItems;
@property (nonatomic, strong) NSMutableArray *barsItems;
@property (nonatomic, strong) NSMutableArray *socialItems;
@property (nonatomic, strong) NSMutableArray *groupsItems;
@property (nonatomic, strong) NSArray *filteredCitiesItems;
@property (nonatomic, strong) NSArray *filteredVenueItems;
@property (nonatomic, strong) NSArray *filteredBarsItems;
@property (nonatomic, strong) NSArray *filteredSocialItems;
@property (nonatomic, strong) NSArray *filteredGroupsItems;
@property (nonatomic, weak) id<PinsDropDownDelegate> pinsDelegate;

@end
