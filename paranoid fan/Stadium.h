//
//  Stadium.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"
#import "SearchItem.h"
#import "MapMarkerItem.h"

@class CLLocation;

@interface Stadium : NSObject<ModelParserProtocol,SearchItem>

@property (nonatomic) NSInteger stadiumId;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *team;

@end
