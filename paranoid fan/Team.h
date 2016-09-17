//
//  Team.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"

@interface Team : NSObject<ModelParserProtocol>

@property (nonatomic) NSInteger teamID;
@property (nonatomic, strong) NSString *sport;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *type;

@end
