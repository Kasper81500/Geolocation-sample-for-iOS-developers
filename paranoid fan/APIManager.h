//
//  APIManager.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletitionBlock)(BOOL success, id result);

@interface APIManager : NSObject

// users
- (void)signupWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password dob:(NSString *)dob completition:(CompletitionBlock)completition;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password completition:(CompletitionBlock)completition;
- (void)verifyPhone:(NSString *)phone forUserID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)confirmPhone:(NSString *)code forUserID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)verifyResend:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)updateProfilePhoto:(UIImage *)photo forUser:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)updateLocationForUser:(NSInteger)userID latitude:(double)latitude longitude:(double)longitude completition:(CompletitionBlock)completition;
- (void)updateMapPhoto:(UIImage *)photo forUser:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)updateFacebookForUser:(NSInteger)userID facebookID:(NSString *)facebookID access_token:(NSString *)access_token completition:(CompletitionBlock)completition;
- (void)updateTwitterForUser:(NSInteger)userID twitterUser:(NSString *)twitterUser access_token:(NSString *)access_token completition:(CompletitionBlock)completition;
- (void)updateProfileForUser:(NSInteger)userID newName:(NSString *)newName email:(NSString *)email dob:(NSString *)dob completition:(CompletitionBlock)completition;
- (void)updateUserTagsForUser:(NSInteger)userID tags:(NSArray *)tags completition:(CompletitionBlock)completition;
- (void)addDevice:(NSString *)device_token forUser:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)getAllUsersForUser:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)getUserInfoByID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)forgotPasswordWithEmail:(NSString *)email completition:(CompletitionBlock)completition;
- (void)changeUserPasswordWithUserID:(NSInteger)userID oldPassword:(NSString *)oldPassword toPassword:(NSString *)newPassword completition:(CompletitionBlock)completition;
- (void)getLeaderboard:(CompletitionBlock)completition;

// setttings
- (void)getAllTeams:(CompletitionBlock)completition;
- (void)getSuggestedTeams:(CompletitionBlock)completition;

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
         completition:(CompletitionBlock)completition;

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
                   completition:(CompletitionBlock)completition;

- (void)pinchatNewForUser:(NSInteger)userid
                    pinID:(NSInteger)pinID
                  message:(NSString *)message
                    photo:(UIImage *)photo
                 latitude:(double)latitude
                longitude:(double)longitude
             completition:(CompletitionBlock)completition;

- (void)pinchatReplyForUser:(NSInteger)userid
                    replyID:(NSInteger)replyID
                      pinID:(NSInteger)pinID
                    message:(NSString *)message
                      photo:(UIImage *)photo
                   latitude:(double)latitude
                  longitude:(double)longitude
               completition:(CompletitionBlock)completition;

- (void)pinchatReplyForUser:(NSInteger)userid
                    replyID:(NSInteger)replyID
                      pinID:(NSInteger)pinID
                    message:(NSString *)message
                      photo:(UIImage *)photo
                      video:(NSData *)video
                   latitude:(double)latitude
                  longitude:(double)longitude
               completition:(CompletitionBlock)completition;


- (void)getAllPinsForLatitude:(double)latitude
                    longitude:(double)longitude
                    userID:(NSInteger)userID
                 completition:(CompletitionBlock)completition;

- (void)getPinDetailForID:(NSInteger)pinID
             completition:(CompletitionBlock)completition;

- (void)getPinChatDetailForID:(NSInteger)pinID
                       userID:(NSInteger)userID
                 completition:(CompletitionBlock)completition;

- (void)likePinChatWithID:(NSInteger)pinchatID userID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)dislikePinChatWithID:(NSInteger)pinchatID userID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)ratingForPin:(NSInteger)userid
               pinID:(NSInteger)pinID
              rating:(NSInteger)rating
        completition:(CompletitionBlock)completition;
- (void)deletePin:(NSInteger)pinID userID:(NSInteger)userID completition:(CompletitionBlock)completition;

// localchat
- (void)createNewLocalchatForUser:(NSInteger)userid
                          message:(NSString *)message
                            photo:(UIImage *)photo
                         latitude:(double)latitude
                        longitude:(double)longitude
                     completition:(CompletitionBlock)completition;

- (void)createReplyLocalchatForUser:(NSInteger)userid
                            replyID:(NSInteger)replyID
                            message:(NSString *)message
                              photo:(UIImage *)photo
                           latitude:(double)latitude
                          longitude:(double)longitude
                       completition:(CompletitionBlock)completition;

- (void)createReplyLocalchatForUserWithVideo:(NSInteger)userid
                            replyID:(NSInteger)replyID
                            message:(NSString *)message
                               video:(NSData *)video
                              photo:(UIImage *)photo
                           latitude:(double)latitude
                          longitude:(double)longitude
                       completition:(CompletitionBlock)completition;

- (void)getAllLocalChatsLatitude:(double)latitude
                       longitude:(double)longitude
                      withUserID:(NSInteger)userID
                    completition:(CompletitionBlock)completition;

- (void)getAllLocalChatsLatitude:(double)latitude
                       longitude:(double)longitude
                         isLocal:(BOOL)isLocal
                      withUserID:(NSInteger)userID
                    completition:(CompletitionBlock)completition;

- (void)reportChatWithID:(NSInteger)chatID withChatType:(NSString *)chat_type forUserID:(NSInteger)userID completition:(CompletitionBlock)completition;

- (void)likeChatWithID:(NSInteger)chatID forUserID:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)dislikeChatWithID:(NSInteger)chatID forUserID:(NSInteger)userID completition:(CompletitionBlock)completition;

// ticket
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
                  completition:(CompletitionBlock)completition;

- (void)getTicketDetail:(NSInteger)ticketID completition:(CompletitionBlock)completition;

- (void)getAllTicketsForLatitude:(double)latidute longitude:(double)longitude completition:(CompletitionBlock)completition;

// conversation
- (void)createNewConversationForUser:(NSInteger)userid
                              public:(NSString *)publicValue
                               title:(NSString *)title
                              detail:(NSString *)detail
                               photo:(UIImage *)photo
                                tags:(NSArray *)tags
                            latitude:(double)latitude
                           longitude:(double)longitude
                        completition:(CompletitionBlock)completition;

- (void)createNewCommentForConversationWithUser:(NSInteger)userid
                                 conversationID:(NSInteger)conversation_id
                                        message:(NSString *)message
                                          photo:(UIImage *)photo
                                       latitude:(double)latitude
                                      longitude:(double)longitude
                                   completition:(CompletitionBlock)completition;

- (void)getAllConversationsCompletition:(CompletitionBlock)completition;

- (void)getConversationDetail:(NSInteger)conversationID completition:(CompletitionBlock)completition;


// stadium
- (void)getallStadiumForLatitude:(double)latitude
                       longitude:(double)longitude
                    completition:(CompletitionBlock)completition;

// City
- (void)getallCities:(CompletitionBlock)completition;

// Pay Tip

- (void)addCard:(NSInteger)userid
          token:(NSString *)token
   completition:(CompletitionBlock)completition;

- (void)payTip:(NSInteger)userid
      reviewer:(NSInteger)reviewer
        chatId:(NSInteger)chatId
        amount:(float)amount
  completition:(CompletitionBlock)completition;

- (void)sendMoney:(NSInteger)senderID
         receiver:(NSInteger)receiverID
           amount:(float)amount
          isGroup:(NSString *)isGroup
     completition:(CompletitionBlock)completition;

// Favorites

- (void)getAllFavoritePins:(NSInteger)userID
              completition:(CompletitionBlock)completition;
- (void)addFavorite:(NSInteger)userid
             pin_id:(NSInteger)pin_id completition:(CompletitionBlock)completition;
- (void)removeFavorite:(NSInteger)userid
                pin_id:(NSInteger)pin_id completition:(CompletitionBlock)completition;

// Reviews

- (void)getAllReviewsPins:(NSInteger)userID
             completition:(CompletitionBlock)completition;


// Friend List
- (void)addFriend:(NSInteger)userid
            phone:(NSString *)phone
     completition:(CompletitionBlock)completition;
- (void)getFriendList:(NSInteger)userID completition:(CompletitionBlock)completition;
- (void)getFriendList:(NSInteger)userID withNumbers:(NSString *)phoneNumbers
         completition:(CompletitionBlock)completition;
- (void)getAddedList:(NSString *)phone completition:(CompletitionBlock)completition;
- (void)sendMeetMeRequest:(NSInteger)userid
                    phone:(NSString *)phone
                 pfUserID:(NSInteger)PFUserID
               meetMeText:(NSString *)message
             completition:(CompletitionBlock)completition;
- (void)sharePin:(NSInteger)userid
           phone:(NSString *)phone
         groupID:(NSInteger)groupID
        pfUserID:(NSInteger)PFUserID
           pinID:(NSInteger)pinID
    completition:(CompletitionBlock)completition;
- (void)sendGroupInvite:(NSInteger)groupID
                 userID:(NSInteger)userID
                  phone:(NSString *)phone
               pfUserID:(NSInteger)PFUserID
              shareText:(NSString *)message
           completition:(CompletitionBlock)completition;

//Messages

- (void)getInbox:(NSInteger)userID
    completition:(CompletitionBlock)completition;

- (void)getAllDirectMessages:(NSInteger)senderID
                       withReceiver:(NSInteger)receiverID
                    fromLastID:(NSInteger)lastID
                    completition:(CompletitionBlock)completition;

- (void)createNewMessage:(NSInteger)senderID
                        receiver:(NSInteger)receiverID
                          message:(NSString *)message
                         latitude:(double)latitude
                        longitude:(double)longitude
                        photo:(UIImage *)photo
                         sticker:(NSString *)sticker
                     completition:(CompletitionBlock)completition;

- (void)addUserGroup:(NSInteger)userid
               users:(NSString *)users
        completition:(CompletitionBlock)completition;

- (void)getUserGroupMessages:(NSInteger)senderID
                   withGroup:(NSInteger)groupID
                  fromLastID:(NSInteger)lastID
                completition:(CompletitionBlock)completition;

- (void)createNewMessageForGroup:(NSInteger)senderID
                           group:(NSInteger)groupID
                         message:(NSString *)message
                        latitude:(double)latitude
                       longitude:(double)longitude
                           photo:(UIImage *)photo
                        sticker:(NSString *)sticker
                    completition:(CompletitionBlock)completition;
//Groups

- (void)checkGroupName:(NSInteger)userid
                 group:(NSString *)groupname
          completition:(CompletitionBlock)completition;

- (void)addFanGroup:(NSInteger)userid
              group:(NSString *)groupname
               team:(NSString *)team
           contacts:(NSString *)contacts
          receivers:(NSString *)receivers
              photo:(UIImage *)photo
       completition:(CompletitionBlock)completition;
- (void)groupMemebership:(NSInteger)userID
              membership:(NSString *)membership
                 groupID:(NSInteger)groupID
            completition:(CompletitionBlock)completition;
- (void)getMyGroups:(NSInteger)userID compeletion:(CompletitionBlock)completition;
- (void)getGroupMembers:(NSInteger)groupID compeletion:(CompletitionBlock)completition;
- (void)getAllGroups:(CompletitionBlock)completition;
- (void)getSuggestedGroups:(CompletitionBlock)completition;
- (void)updateUserGroupsForUser:(NSInteger)userID tags:(NSArray *)tags completition:(CompletitionBlock)completition;
- (void)getGroupChatForGroupID:(NSInteger)groupID
                    withUserID:(NSInteger)userID
                  completition:(CompletitionBlock)completition;
- (void)createNewGroupMessage:(NSInteger)userid
                      groupID:(NSInteger)groupid
                      message:(NSString *)message
                        photo:(UIImage *)photo
                     latitude:(double)latitude
                    longitude:(double)longitude
                 completition:(CompletitionBlock)completition;

// Event List
- (void)getCloseByEventsPins:(NSInteger)userID withLatitude:(float)latitude andLongitude:(float)longitude completition:(CompletitionBlock)completition;

// Helper

- (void)sendTextMessage:(NSInteger)userid
                  phone:(NSString *)phone
                message:(NSString *)message
           completition:(CompletitionBlock)completition;

@end

