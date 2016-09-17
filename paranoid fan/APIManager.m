//
//  APIManager.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "APIManager.h"
#import "AFNetworking.h"
#import "UIImage+Base64.h"
#import "NSArray+JSON.h"

#define BASE_URL    @"http://54.67.44.136"
#define kAuthKey    @"Authkey"
#define HTTP_HEADER_AUTH_KEY    @"SCta}*XTV1R6SCta}*XTV1R6"

@implementation APIManager

#pragma mark - Users

- (void)signupWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password dob:(NSString *)dob completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/signup";
    NSDictionary *params = @{@"name": userName,
                             @"email": email,
                             @"password": password,
                             @"dob": dob}; //yyyy-mm-dd
    
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/login";
    NSDictionary *params = @{@"email": email,
                             @"password": password};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)verifyPhone:(NSString *)phone forUserID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/verifyphone";
    NSDictionary *params = @{@"userid": @(userID),
                             @"phone": phone};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)confirmPhone:(NSString *)code forUserID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/confirmphone";
    NSDictionary *params = @{@"userid": @(userID),
                             @"code": code};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)verifyResend:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/verifyresend";
    NSDictionary *params = @{@"userid": @(userID)};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateProfilePhoto:(UIImage *)photo forUser:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updateprofilephoto";
    NSString *photoString = photo ? [photo base64String] : @"";
    NSDictionary *params = @{@"userid": @(userID),
                             @"photo": photoString};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateLocationForUser:(NSInteger)userID latitude:(double)latitude longitude:(double)longitude completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatelocation";
    NSDictionary *params = @{@"userid": @(userID),
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateMapPhoto:(UIImage *)photo forUser:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatemapphoto";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"photo": photoString};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateFacebookForUser:(NSInteger)userID facebookID:(NSString *)facebookID access_token:(NSString *)access_token completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatefacebook";
    NSDictionary *params = @{@"userid": @(userID),
                             @"facebook_id": facebookID,
                             @"access_token": access_token};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateTwitterForUser:(NSInteger)userID twitterUser:(NSString *)twitterUser access_token:(NSString *)access_token completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatetwitter";
    NSDictionary *params = @{@"userid": @(userID),
                             @"twitter_user": twitterUser,
                             @"access_token": access_token};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateProfileForUser:(NSInteger)userID newName:(NSString *)newName email:(NSString *)email dob:(NSString *)dob completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updateprofile";
    NSDictionary *params = @{@"userid": @(userID),
                             @"name": newName ? newName : @"",
                             @"email": email ? email : @"",
                             @"dob": dob ? dob : @""};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)updateUserTagsForUser:(NSInteger)userID tags:(NSArray *)tags completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatetags";
    NSDictionary *params = @{@"userid": @(userID),
                             @"tags": tags ? [tags tagsString] : @""};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)addDevice:(NSString *)device_token forUser:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/adddevice";
    NSDictionary *params = @{@"userid": @(userID),
                             @"device_token": device_token};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getAllUsersForUser:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getallusers/%zd",userID];
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getUserInfoByID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getuserbyid/%zd",userID];
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)forgotPasswordWithEmail:(NSString *)email completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/forgotpassword";
    
    NSDictionary *params = @{@"email": email ? email : @""};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)changeUserPasswordWithUserID:(NSInteger)userID oldPassword:(NSString *)oldPassword toPassword:(NSString *)newPassword completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatepassword";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"oldpassword": oldPassword ? oldPassword : @"",
                             @"password": newPassword ? newPassword : @""};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];

}

- (void)getLeaderboard:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getleaderboard"];
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Settings

- (void)getAllTeams:(CompletitionBlock)completition
{
    NSString *apiCall = @"settings/getallteams";
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getSuggestedTeams:(CompletitionBlock)completition
{
    NSString *apiCall = @"settings/suggestedteams";
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Maps

// map
- (void)addPinForUser:(NSInteger)userid
                  pin:(NSString *)pin
                title:(NSString *)title
               detail:(NSString *)detail
                photo:(UIImage *)photo
                 tags:(NSArray *)tags
             latitude:(double)latitude
            longitude:(double)longitude
        twitterPostId:(NSString *)twitterPostId
             fbPostId:(NSString *)fbPostId
completition:(CompletitionBlock)completition
{
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSString *apiCall = @"map/addpin";
    NSDictionary *params = @{@"userid": @(userid),
                             @"pin": pin,
                             @"title": title,
                             @"detail": detail,
                             @"photo": photoString,
                             @"tags": tags ? [tags tagsString] : @"",
                             @"latitude": @(latitude),
                             @"longitude": @(longitude),
                             @"twitter_post_id": twitterPostId,
                             @"fb_post_id": fbPostId,};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)addPinWithRatingForUser:(NSInteger)userid
                  pin:(NSString *)pin
                rating:(NSInteger)rating
                title:(NSString *)title
               detail:(NSString *)detail
                photo:(UIImage *)photo
                 tags:(NSArray *)tags
             latitude:(double)latitude
            longitude:(double)longitude
            address:(NSString *)address
            dateTime:(NSString *)dateTime
             groups:(NSString *)groups
          receivers:(NSString *)receivers
        twitterPostId:(NSString *)twitterPostId
             fbPostId:(NSString *)fbPostId
         completition:(CompletitionBlock)completition
{
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSString *apiCall = @"map/addpin";
    NSDictionary *params = @{@"userid": @(userid),
                             @"pin": pin,
                             @"title": title,
                             @"rating": @(rating),
                             @"detail": detail,
                             @"photo": photoString,
                             @"groups": groups,
                             @"receivers": receivers,
                             @"tags": tags ? [tags tagsString] : @"",
                             @"latitude": @(latitude),
                             @"longitude": @(longitude),
                             @"address": address,
                             @"date_time": dateTime,
                             @"twitter_post_id": twitterPostId,
                             @"fb_post_id": fbPostId,};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)pinchatNewForUser:(NSInteger)userid
                    pinID:(NSInteger)pinID
                  message:(NSString *)message
                    photo:(UIImage *)photo
                 latitude:(double)latitude
                longitude:(double)longitude
             completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/pinchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"pin_id": @(pinID),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)pinchatReplyForUser:(NSInteger)userid
                    replyID:(NSInteger)replyID
                      pinID:(NSInteger)pinID
                  message:(NSString *)message
                    photo:(UIImage *)photo
                 latitude:(double)latitude
                longitude:(double)longitude
             completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/pinchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"reply_id": @(replyID),
                             @"pin_id": @(pinID),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)pinchatReplyForUser:(NSInteger)userid
                    replyID:(NSInteger)replyID
                      pinID:(NSInteger)pinID
                    message:(NSString *)message
                      photo:(UIImage *)photo
                    video:(NSData *)video
                   latitude:(double)latitude
                  longitude:(double)longitude
               completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/pinchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"reply_id": @(replyID),
                             @"pin_id": @(pinID),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTMultipartRequestWithApiCall:apiCall params:params video:video callBack:completition];
}

- (void)getAllPinsForLatitude:(double)latitude
                    longitude:(double)longitude
                       userID:(NSInteger)userID
                 completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"map/getallpins/%f/%f/%d",latitude,longitude,userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getPinDetailForID:(NSInteger)pinID
             completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"map/getpindetail/%zd",pinID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getPinChatDetailForID:(NSInteger)pinID
                       userID:(NSInteger)userID
                 completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"map/pinchat/getdetail/%zd/%zd",pinID,userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)likePinChatWithID:(NSInteger)pinchatID userID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/pinchat/like";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"id": @(pinchatID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)dislikePinChatWithID:(NSInteger)pinchatID userID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/pinchat/dislike";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"id": @(pinchatID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)ratingForPin:(NSInteger)userid
                      pinID:(NSInteger)pinID
                    rating:(NSInteger)rating
               completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/rating";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"rating": @(rating),
                             @"pin_id": @(pinID)};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)deletePin:(NSInteger)pinID userID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"map/removepin";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"pinid": @(pinID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Localchat
- (void)createNewLocalchatForUser:(NSInteger)userid
                          message:(NSString *)message
                            photo:(UIImage *)photo
                         latitude:(double)latitude
                        longitude:(double)longitude
                     completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"localchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)createReplyLocalchatForUser:(NSInteger)userid
                            replyID:(NSInteger)replyID
                            message:(NSString *)message
                            photo:(UIImage *)photo
                         latitude:(double)latitude
                        longitude:(double)longitude
                     completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"localchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"reply_id": @(replyID),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)createReplyLocalchatForUserWithVideo:(NSInteger)userid
                            replyID:(NSInteger)replyID
                            message:(NSString *)message
                               video:(NSData *)video
                              photo:(UIImage *)photo
                           latitude:(double)latitude
                          longitude:(double)longitude
                       completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"localchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"reply_id": @(replyID),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTMultipartRequestWithApiCall:apiCall params:params video:video callBack:completition];
}

- (void)getAllLocalChatsLatitude:(double)latitude
                       longitude:(double)longitude
                      withUserID:(NSInteger)userID
                    completition:(CompletitionBlock)completition
{
    [self getAllLocalChatsLatitude:latitude longitude:longitude isLocal:YES withUserID:userID completition:completition];
}

- (void)getAllLocalChatsLatitude:(double)latitude
                       longitude:(double)longitude
                         isLocal:(BOOL)isLocal
                      withUserID:(NSInteger)userID
                    completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"localchat/getall/%f/%f/%@/%d",latitude,longitude,(isLocal ? @"local" : @"stadium"),userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)reportChatWithID:(NSInteger)chatID withChatType:(NSString *)chat_type forUserID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/sendreport";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"contentid": @(chatID),
                             @"type": chat_type};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)likeChatWithID:(NSInteger)chatID forUserID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"localchat/like";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"id": @(chatID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)dislikeChatWithID:(NSInteger)chatID forUserID:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"localchat/dislike";
    
    NSDictionary *params = @{@"userid": @(userID),
                             @"id": @(chatID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Ticket
- (void)createNewTicketForUser:(NSInteger)userid
                         title:(NSString *)title
                        detail:(NSString *)detail
                          tags:(NSArray *)tags
                      quantity:(NSInteger)quantity
                       section:(NSInteger)section
                         price:(CGFloat)price
                      delivery:(NSString *)delivery
                         phone:(NSString *)phone
                      latitude:(double)latitude
                     longitude:(double)longitude
                  completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"ticket/new";
    NSDictionary *params = @{@"userid": @(userid),
                             @"title": title,
                             @"detail": detail,
                             @"tags": tags ? [tags tagsString] : @"",
                             @"quantity": @(quantity),
                             @"section": @(section),
                             @"price": @(price),
                             @"delivery": delivery,
                             @"phone": phone ? phone : @"",
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getTicketDetail:(NSInteger)ticketID completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"ticket/getDetail/%zd",ticketID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getAllTicketsForLatitude:(double)latidute longitude:(double)longitude completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"ticket/getall/%f/%f",latidute,longitude];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Converstation

// conversation
- (void)createNewConversationForUser:(NSInteger)userid
                              public:(id)publicValue
                               title:(NSString *)title
                              detail:(NSString *)detail
                               photo:(UIImage *)photo
                                tags:(NSArray *)tags
                            latitude:(double)latitude
                           longitude:(double)longitude
                        completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"conversation/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"public": publicValue,
                             @"title": title,
                             @"detail": detail,
                             @"photo": photoString,
                             @"tags": tags ? [tags tagsString] : @"",
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)createNewCommentForConversationWithUser:(NSInteger)userid
                                 conversationID:(NSInteger)conversation_id
                                        message:(NSString *)message
                                          photo:(UIImage *)photo
                                       latitude:(double)latitude
                                      longitude:(double)longitude
                                   completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"conversation/comment/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"conversation_id": @(conversation_id),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getAllConversationsCompletition:(CompletitionBlock)completition
{
    NSString *apiCall = @"conversation/getAll";
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}


- (void)getConversationDetail:(NSInteger)conversationID completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"conversation/getDetail/%zd",conversationID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Stadium

- (void)getallStadiumForLatitude:(double)latitude
                       longitude:(double)longitude
                    completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"map/getallstadium/%f/%f",latitude,longitude];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - City

- (void)getallCities:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"map/getallcities"];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Payment methods

- (void)addCard:(NSInteger)userid
          token:(NSString *)token
   completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updatecctoken";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"token": token};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)payTip:(NSInteger)userid
      reviewer:(NSInteger)reviewer
        chatId:(NSInteger)chatId
        amount:(float)amount
  completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/paytip";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"reviewer": @(reviewer),
                             @"pin_chat_id": @(chatId),
                             @"amount": @(amount)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)sendMoney:(NSInteger)senderID
      receiver:(NSInteger)receiverID
        amount:(float)amount
        isGroup:(NSString *)isGroup
  completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/sendmoney";
    
    NSDictionary *params = @{@"senderid": @(senderID),
                             @"receiverid": @(receiverID),
                             @"group": isGroup,
                             @"amount": @(amount)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Favorite methods

- (void)getAllFavoritePins:(NSInteger)userID
                 completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getallfavoritepins/%ld", (long)userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Reviews

- (void)getAllReviewsPins:(NSInteger)userID
              completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getallreviews/%ld", (long)userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)addFavorite:(NSInteger)userid
        pin_id:(NSInteger)pin_id
  completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/addfavorite";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"pin_id": @(pin_id)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)removeFavorite:(NSInteger)userid
             pin_id:(NSInteger)pin_id
       completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/removefavorite";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"pin_id": @(pin_id)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}


#pragma mark - Friend List

- (void)addFriend:(NSInteger)userid
             phone:(NSString *)phone
       completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/addfriend";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"phone": phone};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getFriendList:(NSInteger)userID withNumbers:(NSString *)phoneNumbers
              completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getfriendlist/%ld", (long)userID];
    
    NSDictionary *params = @{@"numbers": phoneNumbers};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getFriendList:(NSInteger)userID completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getfriendlist/%ld", (long)userID];
   [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getAddedList:(NSString *)phone completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getaddedlist"];
    NSDictionary *params = @{@"number": phone};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)sendMeetMeRequest:(NSInteger)userid
            phone:(NSString *)phone
                 pfUserID:(NSInteger)PFUserID
               meetMeText:(NSString *)message
     completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"invite/meetme";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"pfuserid": @(PFUserID),
                             @"phone": phone,
                             @"message": message};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)sharePin:(NSInteger)userid
                    phone:(NSString *)phone
                groupID:(NSInteger)groupID
                 pfUserID:(NSInteger)PFUserID
               pinID:(NSInteger)pinID
             completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"share/pin";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"groupid": @(groupID),
                             @"pfuserid": @(PFUserID),
                             @"phone": phone,
                             @"pinid": @(pinID)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)sendGroupInvite:(NSInteger)groupID
             userID:(NSInteger)userID
           phone:(NSString *)phone
        pfUserID:(NSInteger)PFUserID
       shareText:(NSString *)message
    completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"invite/group";
    
    NSDictionary *params = @{@"groupid": @(groupID),
                             @"userid": @(userID),
                             @"pfuserid": @(PFUserID),
                             @"phone": phone,
                             @"message": message};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Messages


- (void)getInbox:(NSInteger)userID
                completition:(CompletitionBlock)completition {
    
    NSString *apiCall = [NSString stringWithFormat:@"user/getinbox/%ld", (long)userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
    
}


- (void)getAllDirectMessages:(NSInteger)senderID
                withReceiver:(NSInteger)receiverID
                fromLastID:(NSInteger)lastID
                completition:(CompletitionBlock)completition {
    
    NSString *apiCall = [NSString stringWithFormat:@"user/getdirectmessages/%ld/%ld/%ld", (long)senderID, (long)receiverID, (long)lastID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
    
}


- (void)createNewMessage:(NSInteger)senderID
                receiver:(NSInteger)receiverID
                 message:(NSString *)message
                latitude:(double)latitude
               longitude:(double)longitude
                photo:(UIImage *)photo
                sticker:(NSString *)sticker
            completition:(CompletitionBlock)completition {
    
    NSString *apiCall = @"user/newmessage";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"sender_id": @(senderID),
                             @"receiver_id": @(receiverID),
                             @"message": message,
                             @"photo": photoString,
                             @"sticker": sticker,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)addUserGroup:(NSInteger)userid
            users:(NSString *)users
     completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"usergroup/addnew";
    
    NSDictionary *params = @{@"sender": @(userid),
                             @"receivers": users};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getUserGroupMessages:(NSInteger)senderID
                withGroup:(NSInteger)groupID
                  fromLastID:(NSInteger)lastID
                completition:(CompletitionBlock)completition {
    
    NSString *apiCall = [NSString stringWithFormat:@"usergroup/getmessages/%ld/%ld/%ld", (long)senderID, (long)groupID, (long)lastID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
    
}

- (void)createNewMessageForGroup:(NSInteger)senderID
                group:(NSInteger)groupID
                 message:(NSString *)message
                latitude:(double)latitude
               longitude:(double)longitude
                   photo:(UIImage *)photo
                   sticker:(NSString *)sticker
            completition:(CompletitionBlock)completition {
    
    NSString *apiCall = @"usergroup/newmessage";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"sender_id": @(senderID),
                             @"user_group_id": @(groupID),
                             @"message": message,
                             @"photo": photoString,
                             @"sticker": sticker,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Groups

- (void)checkGroupName:(NSInteger)userid
              group:(NSString *)groupname
       completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/checkgroupname";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"groupname": groupname};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)addFanGroup:(NSInteger)userid
              group:(NSString *)groupname
               team:(NSString *)team
               contacts:(NSString *)contacts
          receivers:(NSString *)receivers
              photo:(UIImage *)photo
        completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/addnewfangroup";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"groupname": groupname,
                             @"team": team,
                             @"contacts": contacts,
                             @"receivers": receivers,
                             @"photo": photoString};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)groupMemebership:(NSInteger)userID
              membership:(NSString *)membership
               groupID:(NSInteger)groupID
       completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/group/membership";
    NSDictionary *params = @{@"userid": @(userID),
                             @"membership": membership,
                             @"groupid": @(groupID)};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getMyGroups:(NSInteger)userID compeletion:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/mygroups/%ld",(long)userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getGroupMembers:(NSInteger)groupID compeletion:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/groupmembers/%ld",(long)groupID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getAllGroups:(CompletitionBlock)completition
{
    NSString *apiCall = @"settings/getallgroups";
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)getSuggestedGroups:(CompletitionBlock)completition
{
    NSString *apiCall = @"settings/suggestedgroups";
    
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)updateUserGroupsForUser:(NSInteger)userID tags:(NSArray *)tags completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/updategroups";
    NSDictionary *params = @{@"userid": @(userID),
                             @"groups": tags ? [tags tagsString] : @""};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

- (void)getGroupChatForGroupID:(NSInteger)groupID
                      withUserID:(NSInteger)userID
                    completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"groupchat/%ld/%ld",(long)groupID,(long)userID];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

- (void)createNewGroupMessage:(NSInteger)userid
                          groupID:(NSInteger)groupid
                          message:(NSString *)message
                            photo:(UIImage *)photo
                         latitude:(double)latitude
                        longitude:(double)longitude
                     completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"groupchat/new";
    NSString *photoString = photo ? [photo base64String] : @"";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"groupid": @(groupid),
                             @"message": message,
                             @"photo": photoString,
                             @"latitude": @(latitude),
                             @"longitude": @(longitude)};
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Event List

- (void)getCloseByEventsPins:(NSInteger)userID withLatitude:(float)latitude andLongitude:(float)longitude completition:(CompletitionBlock)completition
{
    NSString *apiCall = [NSString stringWithFormat:@"user/getclosebyevents/%ld/%f/%f", (long)userID, latitude, longitude];
    [self commonGETRequestWithApiCall:apiCall callBack:completition];
}

#pragma mark - Helpers

- (void)sendTextMessage:(NSInteger)userid
               phone:(NSString *)phone
              message:(NSString *)message
        completition:(CompletitionBlock)completition
{
    NSString *apiCall = @"user/sendtextmessage";
    
    NSDictionary *params = @{@"userid": @(userid),
                             @"phone": phone,
                             @"message": message};
    
    [self commonPOSTRequestWithApiCall:apiCall params:params callBack:completition];
}

#pragma mark - Private methods

- (void)commonGETRequestWithApiCall:(NSString *)apiCall callBack:(CompletitionBlock)completition
{
    AFHTTPRequestOperationManager *manager = [self defaultManager];
    
    NSString *getRequest = [self apiURLForCall:apiCall];
    NSLog(@"%@", getRequest);
    [manager GET:getRequest parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completition) {
            completition(YES,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"API Manager Error: %@",[error localizedDescription]);
        if (completition) {
            completition(NO, error);
        }
    }];
}

- (void)commonPOSTMultipartRequestWithApiCall:(NSString *)apiCall
                              params:(NSDictionary *)params
                                video:(NSData *)video
                            callBack:(CompletitionBlock)completition
{
    AFHTTPRequestOperationManager *manager = [self defaultManager];
    
    NSString *postRequest = [self apiURLForCall:apiCall];
    
    [manager POST:postRequest parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:video
                                    name:@"video"
                                fileName:@"pf_movie.mov" mimeType:@"quicktime/mov"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completition) {
            completition(YES,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"API Manager Error: %@",[error localizedDescription]);
        if (completition) {
            completition(NO, error);
        }
    }];
}

- (void)commonPOSTRequestWithApiCall:(NSString *)apiCall
                              params:(NSDictionary *)params
                            callBack:(CompletitionBlock)completition
{
    AFHTTPRequestOperationManager *manager = [self defaultManager];
    
    NSString *postRequest = [self apiURLForCall:apiCall];
    
    [manager POST:postRequest parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completition) {
            completition(YES,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"API Manager Error: %@",[error localizedDescription]);
        if (completition) {
            completition(NO, error);
        }
    }];
}

- (void)commonPUTRequestWithApiCall:(NSString *)apiCall
                             params:(NSDictionary *)params
                           callBack:(CompletitionBlock)completition
{
    AFHTTPRequestOperationManager *manager = [self defaultManager];
    NSString *request = [self apiURLForCall:apiCall];
    [manager PUT:request parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completition) {
            completition(YES,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"API Manager Error: %@",[error localizedDescription]);
        if (completition) {
            completition(NO, error);
        }
    }];
}

- (void)commonDELETERequestWithApiCall:(NSString *)apiCall
                              callBack:(CompletitionBlock)completition
{
    AFHTTPRequestOperationManager *manager = [self defaultManager];
    NSString *request = [self apiURLForCall:apiCall];
    [manager DELETE:request parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completition) {
            completition(YES,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"API Manager Error: %@",[error localizedDescription]);
        if (completition) {
            completition(NO, error);
        }
    }];
}

- (AFHTTPRequestOperationManager *)defaultManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
//    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [manager.requestSerializer setValue:HTTP_HEADER_AUTH_KEY forHTTPHeaderField:kAuthKey];


    
    return manager;
}

- (NSString *)apiURLForCall:(NSString *)apiCall
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/%@",BASE_URL,apiCall];
    return urlString;
}

@end
