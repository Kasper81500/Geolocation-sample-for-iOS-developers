//
//  Pin.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ModelParserProtocol.h"
#import "SearchItem.h"
#import "MapMarkerItem.h"

@interface Pin : NSObject<ModelParserProtocol, SearchItem, MapMarkerItem>

@property (nonatomic) NSInteger pinID;
@property (nonatomic) NSInteger userID;
@property (nonatomic, strong) NSString *mapPinPhoto;
@property (nonatomic, strong) NSString *mapPinCoverPhoto;
@property (nonatomic, strong) NSString *mapPinTags;
@property (nonatomic, strong) NSString *mapPinTitle;
@property (nonatomic, strong) NSString *mapPinType;
@property (nonatomic, strong) NSString *mapAddress;
@property (nonatomic) double mapPinLatitude;
@property (nonatomic) double mapPinLongitude;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic) BOOL rated;
@property (nonatomic) NSInteger rating;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic,strong) NSString *isVerified;

- (UIImage *)pinImage;
- (CLLocationCoordinate2D)getLocationCoordinate;

@end
