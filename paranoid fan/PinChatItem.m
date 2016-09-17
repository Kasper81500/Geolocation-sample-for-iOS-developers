//
//  PinChatItem.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/3/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PinChatItem.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"

@implementation PinChatItem

@synthesize userId;
@synthesize dateCreated;
@synthesize message;
@synthesize photo;
@synthesize videoLink;
@synthesize avatar;
@synthesize profileName;
@synthesize distance;
@synthesize liked;
@synthesize likeCount;
@synthesize imageHeight;
@synthesize imageWidth;


+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    PinChatItem *chatItem = [[PinChatItem alloc] init];
    
    chatItem.userId = [[json safeObjectForKey:@"user_id"] integerValue];
    chatItem.pinChatId = [[json safeObjectForKey:@"pin_chat_id"] integerValue];
    chatItem.dateCreated =  [NSDate dateFronJSON:[json safeObjectForKey:@"pin_chat_date_created"]];
    chatItem.message = [json safeObjectForKey:@"pin_chat_message"];
    chatItem.photo = [json safeObjectForKey:@"pin_chat_photo"];
    chatItem.videoLink = [json safeObjectForKey:@"pin_chat_video_link"];
    
    chatItem.avatar = [json safeObjectForKey:@"profile_avatar"];
    chatItem.profileName = [json safeObjectForKey:@"fullname"];
    chatItem.distance = [json safeObjectForKey:@"distance"];
    
    chatItem.liked = [[json safeObjectForKey:@"liked"] boolValue];
    chatItem.likeCount = [[json safeObjectForKey:@"pin_chat_like_count"] integerValue];
    
    chatItem.imageWidth = [[json safeObjectForKey:@"image_width"] integerValue];
    chatItem.imageHeight = [[json safeObjectForKey:@"image_height"] integerValue];
    
    return chatItem;
}

@end
