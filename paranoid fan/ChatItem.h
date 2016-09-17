//
//  ChatItem.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatItem <NSObject>

@property (nonatomic) NSInteger userId;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *videoLink;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSString *distance;

@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) CGFloat imageWidth;

@property (nonatomic) NSInteger likeCount;
@property (nonatomic) BOOL liked;

@end
