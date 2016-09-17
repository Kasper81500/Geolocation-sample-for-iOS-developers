//
//  ModelParserProtocol.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelParserProtocol <NSObject>

+ (instancetype)objectFromJSON:(NSDictionary *)json;

@end
