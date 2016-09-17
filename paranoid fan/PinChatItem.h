//
//  PinChatItem.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"
#import "ChatItem.h"

@interface PinChatItem : NSObject<ModelParserProtocol,ChatItem>

@property (nonatomic) NSInteger pinChatId;
//@property (nonatomic, strong) NSDate *pinChatDateCreated;
//@property (nonatomic, strong) NSString *pinChatMessage;
//@property (nonatomic, strong) NSString *pinChatPhoto;
//@property (nonatomic, strong) NSString *profileAvatar;
//@property (nonatomic, strong) NSString *profileName;

@end
