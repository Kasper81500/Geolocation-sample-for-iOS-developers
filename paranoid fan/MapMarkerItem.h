//
//  MapMarkerItem.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/20/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;

@protocol MapMarkerItem <NSObject>

- (CLLocation *)getMapLocation;
- (UIImage *)getMarkerIcon;
- (NSString *)getMarkerIconURL;
- (NSString *)getMarkerType;
- (NSString *)getMarkerTags;

@end
