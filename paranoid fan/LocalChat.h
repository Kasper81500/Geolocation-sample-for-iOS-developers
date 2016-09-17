//
//  LocalChat.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"
#import "ChatItem.h"

@interface LocalChat : NSObject<ModelParserProtocol,ChatItem>

@property (nonatomic) NSInteger chatId;
//@property (nonatomic, strong) NSDate *chatDateCreated;
//@property (nonatomic, strong) NSString *chatMessage;
//@property (nonatomic, strong) NSString *chatPhoto;
//@property (nonatomic, strong) NSString *profileAvatar;
//@property (nonatomic, strong) NSString *profileName;
//@property (nonatomic, strong) NSString *distance;

@end
