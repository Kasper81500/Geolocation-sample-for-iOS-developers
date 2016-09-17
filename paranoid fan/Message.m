//
//  Message.m
//  paranoid fan
//
//  Created by Adeel Asim on 4/25/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "Message.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"

@implementation Message

@synthesize userId;
@synthesize videoLink;
@synthesize dateCreated;
@synthesize message;
@synthesize photo;
@synthesize avatar;
@synthesize profileName;
@synthesize distance;
@synthesize liked;
@synthesize likeCount;
@synthesize imageHeight;
@synthesize imageWidth;


+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    Message *message = [[Message alloc] init];
    
    message.senderId = [[json safeObjectForKey:@"sender_id"] integerValue];
    message.receiverId = [[json safeObjectForKey:@"receiver_id"] integerValue];
    message.messageId = [[json safeObjectForKey:@"message_id"] integerValue];
    message.groupId = [[json safeObjectForKey:@"group_id"] integerValue];
    message.userGroupId = [[json safeObjectForKey:@"user_group_id"] integerValue];
    message.dateCreated =  [NSDate dateFronJSON:[json safeObjectForKey:@"date_created"]];
    message.message = [json safeObjectForKey:@"message"];
    message.isRead =  [[json safeObjectForKey:@"is_read"] boolValue];
    message.profileName = [json safeObjectForKey:@"fullname"];
    message.avatar = [json safeObjectForKey:@"profile_avatar"];
    message.photo = [json safeObjectForKey:@"photo"];
    message.sticker = [json safeObjectForKey:@"sticker"];
    message.imageWidth = [[json safeObjectForKey:@"image_width"] integerValue];
    message.imageHeight = [[json safeObjectForKey:@"image_height"] integerValue];
    message.latitude = [[json safeObjectForKey:@"latitude"] doubleValue];
    message.longitude = [[json safeObjectForKey:@"longitude"] doubleValue];
    
    return message;
}

@end
