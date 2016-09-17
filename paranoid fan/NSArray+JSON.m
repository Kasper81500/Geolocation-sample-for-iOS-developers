//
//  NSArray+JSON.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)

- (NSString *)tagsString
{
    NSMutableString *string = [NSMutableString string];
    BOOL isFirstItem = YES;
    for (NSString *listItem in self) {
        if (isFirstItem) {
            [string appendString:listItem];
            isFirstItem = NO;
        } else {
            [string appendFormat:@",%@",listItem];
        }
    }
    return string;
}


+ (NSArray *)arrayFromTags:(NSString *)tags
{
    NSArray *array = [tags componentsSeparatedByString:@","];
    return array;
}

@end
