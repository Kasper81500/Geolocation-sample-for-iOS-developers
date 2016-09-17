//
//  Engine.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIManager.h"
#import "DataManager.h"
#import "SettingsManager.h"
#import "ShareManager.h"

@interface Engine : NSObject

@property (nonatomic, strong) APIManager *apiManager;
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) SettingsManager *settingManager;
@property (nonatomic, strong) ShareManager *shareManager;

+ (instancetype)sharedEngine;

@end
