//
//  DataHandler.m
//  GLE DP
//
//  Created by PJ95 on 5/7/15.
//  Copyright (c) 2015 PJ95. All rights reserved.
//

#import "DataHandler.h"
#import "AFNetworking.h"

@implementation DataHandler

+ (void) runApi:(NSString*)strApiName Params:(NSDictionary*)Params
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
//    manager.responseSerializer = responseSerializer;
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSLog(@"SERVER URL : %@",strApiName);
    NSLog(@"Parameter : %@",Params);
    [manager GET:strApiName parameters:Params success:success failure:failure];
}

@end
