//
//  DataManager.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

typedef void (^DataResultBlock)(BOOL success, id result, NSString *errorInfo);

@class CLLocation;
@class Pin;

@interface DataManager : NSObject

- (BOOL)isUserLogin;
- (void)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password withCallBack:(DataResultBlock)callBack;
- (void)signupUserWithEmail:(NSString *)email name:(NSString *)name andPassword:(NSString *)password birdthday:(NSDate *)dob withCallBack:(DataResultBlock)callBack;
- (void)verifyPhone:(NSString *)phone withCallBack:(DataResultBlock)callBack;
- (void)confirmPhone:(NSString *)code withCallBack:(DataResultBlock)callBack;
- (void)verifyResend:(DataResultBlock)callBack;
- (void)updateUserAvatar:(UIImage *)avatar withCallBack:(DataResultBlock)callBack;
- (void)updateUserMapAvatar:(UIImage *)avatar withCallBack:(DataResultBlock)callBack;
- (void)updateUserMapAvatar:(UIImage *)avatar withUserID:(NSInteger)userID withCallBack:(DataResultBlock)callBack;
- (void)updateuserLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;
- (void)updateUserTags:(NSArray *)tags withCallBack:(DataResultBlock)callBack;
- (void)getAllUsersWithCallBack:(DataResultBlock)callBack;
- (void)getUserInfoByID:(NSInteger)userID withCallBack:(DataResultBlock)callBack;
- (void)updateCurrentUserInfoWithCallBack:(DataResultBlock)callBack;
- (void)forgotPasswordWithEmail:(NSString *)email withCallBack:(DataResultBlock)callBack;
- (void)updateUserProfileWithName:(NSString *)name email:(NSString *)email andDob:(NSDate *)dob withCallBack:(DataResultBlock)callBack;
- (void)updateUserPassword:(NSString *)password toPassword:(NSString *)newPassword withCallBack:(DataResultBlock)callBack;
- (void)getLeaderboardWithCallBack:(DataResultBlock)callBack;

// pins
- (void)getAllPinsForLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;
- (void)getAllChatItemsForPinID:(NSInteger)pinID withCallBack:(DataResultBlock)callBack;
- (void)addPinWithPinType:(NSString *)pinType
                    title:(NSString *)title
                   detail:(NSString *)detail
                    photo:(UIImage *)photo
                     tags:(NSArray *)tags
                 location:(CLLocation *)location
                twittedID:(NSString *)twitterID
                     fbID:(NSString *)fbID
             withCallBack:(DataResultBlock)callBack;

- (void)addPinWithRatingPinType:(NSString *)pinType
                          title:(NSString *)title
                         rating:(NSInteger)rating
                         detail:(NSString *)detail
                          photo:(UIImage *)photo
                           tags:(NSArray *)tags
                       latitude:(double)latitude
                      longitude:(double)longitude
                        address:(NSString *)address
                       dateTime:(NSString *)dateTime
                         groups:(NSString *)groups
                      receivers:(NSString *)receivers
                      twittedID:(NSString *)twitterID
                           fbID:(NSString *)fbID
                   withCallBack:(DataResultBlock)callBack;

- (void)addChatItemForPin:(Pin *)pin
              withMessage:(NSString *)message
                    photo:(UIImage *)photo
              andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;

- (void)addChatItemForPin:(Pin *)pin withReplyID:(NSInteger)replyID withMessage:(NSString *)message photo:(UIImage *)photo andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;

- (void)addChatItemForPin:(Pin *)pin withReplyID:(NSInteger)replyID withMessage:(NSString *)message photo:(UIImage *)photo withVideo:(NSData *)video andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;

- (void)likePinChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack;
- (void)dislikePinChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack;
- (void)saveRatingForPin:(Pin *)pin withRating:(NSInteger)rating withCallBack:(DataResultBlock)callBack;
- (void)deletePin:(NSInteger)pinID withCallBack:(DataResultBlock)callBack;

// localchat
- (void)getLocalchatForLocation:(CLLocation *)location  withCallBack:(DataResultBlock)callBack;
- (void)getStadiumChatForLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack;
- (void)createNewLocalchatForLocation:(CLLocation *)location
                              message:(NSString *)message
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack;
- (void)createNewLocalchatForLocation:(CLLocation *)location
                          withReplyID:(NSInteger)replyID
                              message:(NSString *)message
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack;
- (void)createNewLocalchatForLocationWithVideo:(CLLocation *)location
                          withReplyID:(NSInteger)replyID
                              message:(NSString *)message
                                 video:(NSData *)video
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack;


- (void)reportChatWithID:(NSInteger)chatID forChatType:(NSString *)chatType withCallBack:(DataResultBlock)callBack;
- (void)likeLocalChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack;
- (void)dislikeLocalChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack;

// team
- (void)getAllTeamsWithCallBack:(DataResultBlock)callBack;
- (void)getSuggestedTeamsWithCallBack:(DataResultBlock)callBack;

// ticket
- (void)addNewTicketWithTitle:(NSString *)title
                       detail:(NSString *)detail
                         tags:(NSArray *)tags
                     quantity:(NSInteger)quantity
                      section:(NSInteger)section
                        price:(CGFloat)price
                     delivery:(BOOL)isPerson
                        phone:(NSString *)phone
                 withCallBack:(DataResultBlock)callBack;
- (void)getAllTicketsWithCallBack:(DataResultBlock)callBack;

// stadium
- (void)getAllStadiumsWithCallBack:(DataResultBlock)callBack;

// cities
- (void)getAllCitiesWithCallBack:(DataResultBlock)callBack;

// Payment

- (void)addCard:(NSString *)token withCallBack:(DataResultBlock)callBack;
- (void)payTip:(NSInteger)reviewer tipAmount:(float)amount forChatID:(NSInteger)chatId withCallBack:(DataResultBlock)callBack;
- (void)sendMoney:(NSInteger)receiverID amount:(float)amount isGroup:(NSString *)isGroup withCallBack:(DataResultBlock)callBack;

// Favorites
- (void)getAllFavoritePins:(NSInteger)profileID withCallback:(DataResultBlock)callBack;
- (void)addFavorite:(NSInteger)pin_id withCallBack:(DataResultBlock)callBack;
- (void)removeFavorite:(NSInteger)pin_id withCallBack:(DataResultBlock)callBack;

//Reviews

- (void)getAllReviewsPins:(NSInteger)profileID withCallback:(DataResultBlock)callBack;

// Friend List

- (void)getFriendList:(NSString *)phoneNumbers withCallBack:(DataResultBlock)callBack;
- (void)getFriendList:(DataResultBlock)callBack;
- (void)getAddedList:(NSString *)userPhone withCallBack:(DataResultBlock)callBack;
- (void)addFriend:(NSString *)phone withCallBack:(DataResultBlock)callBack;
- (void)sendMeetMeRequest:(NSString *)phone withPFID:(NSInteger)PFUserID meetMeText:(NSString *)message withCallBack:(DataResultBlock)callBack;
- (void)sharePin:(NSString *)phone withGroupID:(NSInteger)groupID withPFID:(NSInteger)PFUserID withPin:(NSInteger)pinID withCallBack:(DataResultBlock)callBack;
- (void)sendGroupInvite:(NSInteger)groupID withPhone:(NSString *)phone withPFID:(NSInteger)PFUserID shareText:(NSString *)message withCallBack:(DataResultBlock)callBack;

//Messages
- (void)getInbox:(NSInteger)userID withCallBack:(DataResultBlock)callBack;

- (void)getDirectMessages:(NSInteger)senderID toReceiver:(NSInteger)receiverID fromLastID:(NSInteger)lastID withCallBack:(DataResultBlock)callBack;

- (void)createNewMessage:(CLLocation *)location
                 message:(NSString *)message
                senderID:(NSInteger)senderID
              receiverID:(NSInteger)receiverID
                   photo:(UIImage *)photo
                   sticker:(NSString *)sticker
            withCallBack:(DataResultBlock)callBack;

- (void)addUserGroup:(NSString *)users withCallBack:(DataResultBlock)callBack;
- (void)getUserGroupMessages:(NSInteger)senderID toGroup:(NSInteger)groupID fromLastID:(NSInteger)lastID withCallBack:(DataResultBlock)callBack;

- (void)createNewMessageForGroup:(CLLocation *)location
                         message:(NSString *)message
                        senderID:(NSInteger)senderID
                         groupID:(NSInteger)groupID
                           photo:(UIImage *)photo
                         sticker:(NSString *)sticker
                    withCallBack:(DataResultBlock)callBack;

//Groups

- (void)checkGroupName:(NSString *)groupname withCallBack:(DataResultBlock)callBack;
- (void)addFanGroup:(NSString *)groupname withTeam:(NSString *)team withContacts:(NSString *)contacts withReceivers:(NSString *)receivers andPhoto:(UIImage *)photo withCallBack:(DataResultBlock)callBack;
- (void)groupMembership:(NSString *)membership forGroupID:(NSInteger)groupID withCallBack:(DataResultBlock)callBack;
- (void)getMyGroupsWithCallBack:(DataResultBlock)callBack;
- (void)getGroupMembersWithCallBack:(NSInteger)groupID withCallBack:(DataResultBlock)callBack;
- (void)getAllGroupsWithCallBack:(DataResultBlock)callBack;
- (void)getSuggestedGroupsWithCallBack:(DataResultBlock)callBack;
- (void)updateUserGroups:(NSArray *)tags withCallBack:(DataResultBlock)callBack;
- (void)getGroupChatForGroupID:(NSInteger)groupID  withCallBack:(DataResultBlock)callBack;
- (void)createNewGroupMessage:(CLLocation *)location
                  withGroupID:(NSInteger)groupID
                      message:(NSString *)message
                        photo:(UIImage *)photo
                 withCallBack:(DataResultBlock)callBack;

// Event List
- (void)getCloseByEventsPins:(DataResultBlock)callBack;

// Helper

- (void)sendTextMessage:(NSString *)phone withMessage:(NSString *)message withCallBack:(DataResultBlock)callBack;

- (void)logout;

@end
