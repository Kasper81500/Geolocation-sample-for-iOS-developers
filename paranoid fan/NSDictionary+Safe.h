//
//  NSDictionary+Safe.h
//  paranoid fan
//
//  Created by Stas on 08.07.15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)

- (id)safeObjectForKey:(NSString *)key;

@end
