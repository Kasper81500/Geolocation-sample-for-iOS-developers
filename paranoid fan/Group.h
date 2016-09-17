//
//  Group.h
//  paranoid fan
//
//  Created by Adeel Asim on 5/11/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelParserProtocol.h"

@interface Group : NSObject<ModelParserProtocol>

@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger userID;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) CGFloat imageWidth;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL invited;

@end
