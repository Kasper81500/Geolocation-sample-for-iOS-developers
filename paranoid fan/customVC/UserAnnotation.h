//
//  UserAnnotation.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class User;

@interface UserAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) User *user;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

@property (nonatomic) BOOL isForCurrentUser;

- (id)initWithUser:(User *)user;

@end
