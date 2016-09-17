//
//  DataHandler.h
//  GLE DP
//
//  Created by PJ95 on 5/7/15.
//  Copyright (c) 2015 PJ95. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define API_ROOT @"https://maps.googleapis.com/maps/api/geocode/json"//?address=%@&sensor=true




@interface DataHandler : NSObject
+ (void) runApi:(NSString*)strApiName Params:(NSDictionary*)Params
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
