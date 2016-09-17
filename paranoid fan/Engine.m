//
//  Engine.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "Engine.h"

@implementation Engine

+ (instancetype)sharedEngine
{
    static Engine *singleton  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[Engine alloc] init];
    });
    return singleton;
}

- (APIManager *)apiManager {
    if (!_apiManager) {
        _apiManager = [[APIManager alloc] init];
    }
    return _apiManager;
}

- (DataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    return _dataManager;
}

- (SettingsManager *)settingManager {
    if (!_settingManager) {
        _settingManager = [[SettingsManager alloc] init];
    }
    return _settingManager;
}

- (ShareManager *)shareManager
{
    if (!_shareManager) {
        _shareManager = [[ShareManager alloc] init];
    }
    return _shareManager;
}

@end
