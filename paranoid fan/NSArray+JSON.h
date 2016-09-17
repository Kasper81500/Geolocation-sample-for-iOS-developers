//
//  NSArray+JSON.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSON)

- (NSString *)tagsString;
+ (NSArray *)arrayFromTags:(NSString *)tags;

@end
