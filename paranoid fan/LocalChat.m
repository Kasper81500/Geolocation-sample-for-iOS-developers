//
//  LocalChat.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/4/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "LocalChat.h"
#import "NSDictionary+Safe.h"
#import "NSDate+JSON.h"

@implementation LocalChat

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
    LocalChat *localChat = [[LocalChat alloc] init];
    
    localChat.userId = [[json safeObjectForKey:@"user_id"] integerValue];
    localChat.chatId = [[json safeObjectForKey:@"local_chat_id"] integerValue];
    localChat.dateCreated =  [NSDate dateFronJSON:[json safeObjectForKey:@"chat_date_created"]];
    localChat.message = [json safeObjectForKey:@"chat_message"];
    localChat.photo = [json safeObjectForKey:@"chat_photo"];
    localChat.videoLink = [json safeObjectForKey:@"chat_video_link"];
    
    localChat.avatar = [json safeObjectForKey:@"profile_avatar"];
    localChat.profileName = [json safeObjectForKey:@"fullname"];
    localChat.distance = [json safeObjectForKey:@"distance"];
    
    localChat.likeCount = [[json safeObjectForKey:@"chat_like_count"] integerValue];
    localChat.liked = [[json safeObjectForKey:@"liked"] boolValue];
    
    localChat.imageWidth = [[json safeObjectForKey:@"image_width"] floatValue];
    localChat.imageHeight = [[json safeObjectForKey:@"image_height"] floatValue];
    
    return localChat;
}

@end
