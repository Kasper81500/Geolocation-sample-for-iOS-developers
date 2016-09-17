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

@interface City : NSObject<ModelParserProtocol,SearchItem>

@property (nonatomic) NSInteger cityId;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

@end
