//
//  ShareManager.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pin.h"

@class CLLocation;

typedef void (^Callback)(BOOL success, NSString *errorMessage);

@interface ShareManager : NSObject

- (void)requireTwitterPermisionsWithCallBack:(Callback)callback;
- (void)requireFBPermisionsWithCallBack:(Callback)cellback;

- (BOOL)isFacebookConnected;
- (BOOL)isTwitterConnected;

- (void)disconnectFacebook;
- (void)disconnectTwitter;

- (void)postToFacebookWithPin:(Pin *)pin callback:(Callback)callback;
- (void)postToTwitterWithPin:(Pin *)pin callback:(Callback)callback;
- (void)postToTwitterWithMessage:(NSString *)message photoURLString:(NSString *)photoURLString callback:(Callback)callback;
- (void)inviteUsers:(NSArray *)users forPin:(Pin *)pin fromController:(UIViewController *)controller;
- (void)inviteUsers:(NSArray *)users withLocation:(CLLocation *)location customMessage:(NSString *)message fromController:(UIViewController *)controller;
- (void)inviteUsers:(NSArray *)users withText:(NSString *)text andSubject:(NSString *)subject fromController:(UIViewController *)controller;

@end
