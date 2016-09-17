//
//  Message.h
//  paranoid fan
//
//  Created by Adeel Asim on 4/25/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelParserProtocol.h"
#import "ChatItem.h"


@interface Message : NSObject<ModelParserProtocol,ChatItem>

@property (nonatomic) NSInteger messageId;
@property (nonatomic) NSInteger senderId;
@property (nonatomic) NSInteger receiverId;
@property (nonatomic) NSInteger groupId;
@property (nonatomic) NSInteger userGroupId;
@property (nonatomic, strong) NSString *sticker;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) CGFloat imageWidth;
@property (nonatomic) BOOL isRead;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
