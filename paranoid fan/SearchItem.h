//
//  SearchItem.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/10/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;


@protocol SearchItem <NSObject>

- (NSString *)getSearchTitle;
- (NSString *)getSearchTags;
- (NSString *)getPinType;
- (NSString *)getDistance;
- (CLLocation *)getLocation;

@end
