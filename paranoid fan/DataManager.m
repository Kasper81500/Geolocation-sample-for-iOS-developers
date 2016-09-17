//
//  DataManager.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/2/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "DataManager.h"
#import "Engine.h"
#import "NSDictionary+Safe.h"
#import "SettingsManager.h"
#import <MapKit/MapKit.h>
#import "User.h"
#import "Pin.h"
#import "PinChatItem.h"
#import "UIImage+Base64.h"
#import "LocalChat.h"
#import "Team.h"
#import "Ticket.h"
#import "Stadium.h"
#import "City.h"
#import "Message.h"
#import "Group.h"

@implementation DataManager

- (BOOL)isUserLogin
{
    BOOL isLogin = [[[Engine sharedEngine] settingManager] user] != nil;
    
    if (isLogin)
        [self addDeviceIDForUser:([[[Engine sharedEngine] settingManager] user].userId)];
    
    return isLogin;
}

- (void)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password withCallBack:(DataResultBlock)callBack
{
    if (!email || !password) {
        if (callBack) {
            callBack(NO,nil,@"Fill email and password fields");
        }
        return;
    }
    
    [[[Engine sharedEngine] apiManager] loginWithEmail:email password:password completition:^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                NSLog(@"result %@",result);
                
                BOOL status = [[result safeObjectForKey:@"status"] boolValue];
                BOOL exist = [[result safeObjectForKey:@"exist"] boolValue];
                
                NSString *message = [result safeObjectForKey:@"message"];
                
                if (status && exist) {
                    NSInteger userID = [[[result safeObjectForKey:@"data"] safeObjectForKey:@"userid"] integerValue];
                    [[NSUserDefaults standardUserDefaults] setObject:[[result safeObjectForKey:@"data"] safeObjectForKey:@"phone_verified"] forKey:@"phone_verified"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    callBack(YES,@(userID),nil);
                    [self setupLoggedInUser:userID];
                } else {
                    callBack(NO,nil,message);
                }
            } else {
                callBack(NO,nil,result);
            }
        }
    }];
}


- (void)signupUserWithEmail:(NSString *)email name:(NSString *)name andPassword:(NSString *)password birdthday:(NSDate *)dob withCallBack:(DataResultBlock)callBack
{
    if (!email || !password || !name) {
        if (callBack) {
            callBack(NO,nil,@"Name, email and password fields are required");
        }
        
        return;
    }
    
    
    NSString *dobString = @"";
    
    if (dob) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd/"]; //yyyy-mm-dd
        dobString = [dateFormat stringFromDate:dob];
    }
    
    [[[Engine sharedEngine] apiManager] signupWithUserName:name email:email password:password dob:dobString completition:^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                NSLog(@"result %@",result);
                
                BOOL status = [[result safeObjectForKey:@"status"] boolValue];
                BOOL exist = [[result safeObjectForKey:@"exist"] boolValue];
                
                NSString *message = [result safeObjectForKey:@"message"];
                
                if (status && !exist) {
                    NSInteger userID = [[[result safeObjectForKey:@"data"] safeObjectForKey:@"userid"] integerValue];
                    callBack(YES,@(userID),nil);                    
                    [self setupLoggedInUser:userID];
                } else {
                    callBack(NO,nil,message);
                }
            } else {
                callBack(NO,nil,result);
            }
        }
    }];
}


- (void)verifyPhone:(NSString *)phone withCallBack:(DataResultBlock)callBack
{
    if (!phone) {
        if (callBack) {
            callBack(NO,nil,@"Phone no. is required");
        }
        return;
    }
    
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [[[Engine sharedEngine] apiManager] verifyPhone:phone forUserID:userID completition:completition];
}

- (void)confirmPhone:(NSString *)code withCallBack:(DataResultBlock)callBack
{
    if (!code) {
        if (callBack) {
            callBack(NO,nil,@"Verification code is required");
        }
        return;
    }
    
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [[[Engine sharedEngine] apiManager] confirmPhone:code forUserID:userID completition:completition];
}

- (void)verifyResend:(DataResultBlock)callBack
{
    
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [[[Engine sharedEngine] apiManager] verifyResend:userID completition:completition];
}

- (void)updateUserAvatar:(UIImage *)avatar withCallBack:(DataResultBlock)callBack
{
    if (!avatar) {
        if (callBack) {
            callBack(NO,nil,nil);
        }
        return;
    }
    
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] updateProfilePhoto:avatar forUser:userID completition:completition];
}

- (void)updateUserMapAvatar:(UIImage *)avatar withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [self updateUserMapAvatar:avatar withUserID:userID withCallBack:callBack];
}

- (void)updateUserMapAvatar:(UIImage *)avatar withUserID:(NSInteger)userID withCallBack:(DataResultBlock)callBack
{
    if (!avatar) {
        if (callBack) {
            callBack(NO,nil,nil);
        }
        return;
    }
    
    CompletitionBlock completition = [self commonSimpleParserWithMessageAndURLWithCallBack:callBack];

    [[[Engine sharedEngine] apiManager] updateMapPhoto:avatar forUser:userID completition:completition];
}

- (void)updateuserLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    if (!location) {
        if (callBack) {
            callBack(NO,nil,nil);
        }
        return;
    }
    
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageAndURLWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] updateLocationForUser:userID
                                                     latitude:location.coordinate.latitude
                                                    longitude:location.coordinate.longitude
                                                 completition:completition];
}

- (void)updateUserTags:(NSArray *)tags withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] updateUserTagsForUser:userID tags:tags completition:completition];
}

- (void)getAllUsersWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [[[Engine sharedEngine] apiManager] getAllUsersForUser:userID completition:completition];
}

- (void)getUserInfoByID:(NSInteger)userID withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:NO withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getUserInfoByID:userID completition:completition];
}

- (void)updateCurrentUserInfoWithCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    [self getUserInfoByID:userID withCallBack:callBack];
}

- (void)forgotPasswordWithEmail:(NSString *)email withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    [[[Engine sharedEngine] apiManager] forgotPasswordWithEmail:email completition:completition];
}

- (void)updateUserProfileWithName:(NSString *)name email:(NSString *)email andDob:(NSDate *)dob withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    
    [[[Engine sharedEngine] apiManager] updateProfileForUser:userID
                                                     newName:name
                                                       email:email
                                                         dob:[self dobStringFromDate:dob]
                                                completition:completition];
}

- (void)updateUserPassword:(NSString *)password toPassword:(NSString *)newPassword withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    
    [[[Engine sharedEngine] apiManager] changeUserPasswordWithUserID:userID
                                                         oldPassword:password
                                                          toPassword:newPassword
                                                        completition:completition];    
}

- (void)getLeaderboardWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getLeaderboard:completition];
}

#pragma mark - Map methods

- (void)getAllPinsForLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllPinsForLatitude:location.coordinate.latitude
                                                    longitude:location.coordinate.longitude
                                                       userID:userID
                                                 completition:completition];
}

- (void)getAllChatItemsForPinID:(NSInteger)pinID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[PinChatItem class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getPinChatDetailForID:pinID userID:userID completition:completition];
}

- (void)addPinWithPinType:(NSString *)pinType
                    title:(NSString *)title
                   detail:(NSString *)detail
                    photo:(UIImage *)photo
                     tags:(NSArray *)tags
                 location:(CLLocation *)location
                twittedID:(NSString *)twitterID
                     fbID:(NSString *)fbID
             withCallBack:(DataResultBlock)callBack;
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:NO withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addPinForUser:userID
                                                  pin:pinType
                                                title:title
                                               detail:detail
                                                photo:photo
                                                 tags:tags
                                             latitude:location.coordinate.latitude
                                            longitude:location.coordinate.longitude
                                        twitterPostId:twitterID
                                             fbPostId:fbID
                                         completition:completition];
}

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
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:NO withCallBack:callBack];
    
    
    [[[Engine sharedEngine] apiManager] addPinWithRatingForUser:userID
                                                  pin:pinType
                                                 rating:rating
                                                title:title
                                               detail:detail
                                                photo:photo
                                                 tags:tags
                                             latitude:latitude
                                            longitude:longitude
                                            address:address
                                           dateTime:dateTime
                                             groups:groups
                                          receivers:receivers
                                        twitterPostId:twitterID
                                             fbPostId:fbID
                                         completition:completition];
    
}

- (void)addChatItemForPin:(Pin *)pin withMessage:(NSString *)message photo:(UIImage *)photo andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[PinChatItem class] isList:NO withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] pinchatNewForUser:userID
                                                    pinID:pin.pinID
                                                  message:message
                                                    photo:photo
                                                 latitude:location.coordinate.latitude
                                                longitude:location.coordinate.longitude
                                             completition:completition];
}

- (void)addChatItemForPin:(Pin *)pin withReplyID:(NSInteger)replyID withMessage:(NSString *)message photo:(UIImage *)photo andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[PinChatItem class] isList:NO withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] pinchatReplyForUser:userID
                                                    replyID:replyID
                                                      pinID:pin.pinID
                                                  message:message
                                                    photo:photo
                                                 latitude:location.coordinate.latitude
                                                longitude:location.coordinate.longitude
                                             completition:completition];
}


- (void)addChatItemForPin:(Pin *)pin withReplyID:(NSInteger)replyID withMessage:(NSString *)message photo:(UIImage *)photo withVideo:(NSData *)video andLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[PinChatItem class] isList:NO withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] pinchatReplyForUser:userID
                                                    replyID:replyID
                                                      pinID:pin.pinID
                                                    message:message
                                                      photo:photo
                                                      video:video
                                                   latitude:location.coordinate.latitude
                                                  longitude:location.coordinate.longitude
                                               completition:completition];
}


- (void)likePinChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] likePinChatWithID:chatID userID:userID completition:completition];
}

- (void)dislikePinChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] dislikePinChatWithID:chatID userID:userID completition:completition];
}


- (void)saveRatingForPin:(Pin *)pin withRating:(NSInteger)rating withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager]   ratingForPin:userID
                                                      pinID:pin.pinID
                                                    rating:rating
                                               completition:completition];
}

- (void)deletePin:(NSInteger)pinID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] deletePin:pinID userID:userID completition:completition];
}

#pragma mark - Localchat

- (void)getLocalchatForLocation:(CLLocation *)location  withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getAllLocalChatsLatitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude
                                                      withUserID:userID
                                                    completition:completition];
}

- (void)getStadiumChatForLocation:(CLLocation *)location withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getAllLocalChatsLatitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude
                                                         isLocal:NO
                                                      withUserID:userID
                                                    completition:completition];
}

- (void)createNewLocalchatForLocation:(CLLocation *)location
                              message:(NSString *)message
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createNewLocalchatForUser:userID
                                                          message:message
                                                            photo:photo
                                                         latitude:location.coordinate.latitude
                                                        longitude:location.coordinate.longitude
                                                     completition:completition];
}

- (void)createNewLocalchatForLocation:(CLLocation *)location
                                withReplyID:(NSInteger)replyID
                              message:(NSString *)message
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createReplyLocalchatForUser:userID
                                                          replyID:replyID
                                                          message:message
                                                            photo:photo
                                                         latitude:location.coordinate.latitude
                                                        longitude:location.coordinate.longitude
                                                     completition:completition];
}

- (void)createNewLocalchatForLocationWithVideo:(CLLocation *)location
                          withReplyID:(NSInteger)replyID
                              message:(NSString *)message
                                 video:(NSData *)video
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createReplyLocalchatForUserWithVideo:userID
                                                            replyID:replyID
                                                            message:message
                                                               video:video
                                                              photo:photo
                                                           latitude:location.coordinate.latitude
                                                          longitude:location.coordinate.longitude
                                                       completition:completition];
}


- (void)reportChatWithID:(NSInteger)chatID forChatType:(NSString *)chatType withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    [[[Engine sharedEngine] apiManager] reportChatWithID:chatID withChatType:chatType forUserID:userID completition:completition];
}

- (void)likeLocalChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    [[[Engine sharedEngine] apiManager] likeChatWithID:chatID forUserID:userID completition:completition];
}

- (void)dislikeLocalChatWithID:(NSInteger)chatID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    [[[Engine sharedEngine] apiManager] dislikeChatWithID:chatID forUserID:userID completition:completition];
}

#pragma mark - Teams

- (void)getAllTeamsWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForListOfModel:[Team class] withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllTeams:completition];
}

- (void)getSuggestedTeamsWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForListOfModel:[Team class] withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getSuggestedTeams:completition];
}

// ticket
- (void)addNewTicketWithTitle:(NSString *)title
                       detail:(NSString *)detail
                         tags:(NSArray *)tags
                     quantity:(NSInteger)quantity
                      section:(NSInteger)section
                        price:(CGFloat)price
                     delivery:(BOOL)isPerson
                        phone:(NSString *)phone
                 withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [Engine sharedEngine].settingManager.user.userId;
    CLLocation *location = [[Engine sharedEngine].settingManager.user getLocation];
    
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createNewTicketForUser:userID
                                                         title:title
                                                        detail:detail
                                                          tags:tags
                                                      quantity:quantity
                                                       section:section
                                                         price:price
                                                      delivery:isPerson ? @"In Person" : @"Electronic"
                                                         phone:phone
                                                      latitude:location.coordinate.latitude
                                                     longitude:location.coordinate.longitude
                                                  completition:completition];
}

- (void)getAllTicketsWithCallBack:(DataResultBlock)callBack
{
    CLLocation *location = [[Engine sharedEngine].settingManager.user getLocation];
    
    CompletitionBlock completition = [self commonParserForModel:[Ticket class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getAllTicketsForLatitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude
                                                    completition:completition];    
}

- (void)getAllStadiumsWithCallBack:(DataResultBlock)callBack
{
    CLLocation *location = [[Engine sharedEngine].settingManager.user getLocation];
    
    CompletitionBlock completition = [self commonParserForModel:[Stadium class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getallStadiumForLatitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude
                                                    completition:completition];
}


- (void)getAllCitiesWithCallBack:(DataResultBlock)callBack
{
    
    CompletitionBlock completition = [self commonParserForModel:[City class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getallCities:completition];
}


#pragma mark - Payments methods

- (void)addCard:(NSString *)token withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addCard:userID token:token completition:completition];
    
}

- (void)payTip:(NSInteger)reviewer tipAmount:(float)amount forChatID:(NSInteger)chatId withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSLog(@"Amt: %f", amount);
    [[[Engine sharedEngine] apiManager] payTip:userID reviewer:reviewer chatId:chatId amount:amount completition:completition];
    
}

- (void)sendMoney:(NSInteger)receiverID amount:(float)amount isGroup:(NSString *)isGroup withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    NSLog(@"Amt: %f", amount);
    [[[Engine sharedEngine] apiManager] sendMoney:userID receiver:receiverID amount:amount isGroup:isGroup completition:completition];
    
}


#pragma mark - Favorite methods

- (void)getAllFavoritePins:(NSInteger)profileID withCallback:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllFavoritePins:profileID completition:completition];
}

- (void)addFavorite:(NSInteger)pin_id withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addFavorite:userID pin_id:pin_id completition:completition];
    
}


- (void)removeFavorite:(NSInteger)pin_id withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] removeFavorite:userID pin_id:pin_id completition:completition];
    
}

#pragma mark - Reviews

- (void)getAllReviewsPins:(NSInteger)profileID withCallback:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllReviewsPins:profileID completition:completition];
}

#pragma mark - Friend List methods

- (void)getFriendList:(NSString *)phoneNumbers withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getFriendList:userID withNumbers:phoneNumbers completition:completition];
}

- (void)getFriendList:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getFriendList:userID completition:completition];
}

- (void)getAddedList:(NSString *)userPhone withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAddedList:userPhone completition:completition];
}

- (void)addFriend:(NSString *)phone withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addFriend:userID phone:phone completition:completition];
    
}

- (void)sendMeetMeRequest:(NSString *)phone withPFID:(NSInteger)PFUserID meetMeText:(NSString *)message withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] sendMeetMeRequest:userID phone:phone pfUserID:PFUserID meetMeText:message completition:completition];
}

- (void)sharePin:(NSString *)phone withGroupID:(NSInteger)groupID withPFID:(NSInteger)PFUserID withPin:(NSInteger)pinID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] sharePin:userID phone:phone groupID:groupID pfUserID:PFUserID pinID:pinID completition:completition];
}

- (void)sendGroupInvite:(NSInteger)groupID withPhone:(NSString *)phone withPFID:(NSInteger)PFUserID shareText:(NSString *)message withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] sendGroupInvite:groupID userID:userID phone:phone pfUserID:PFUserID shareText:message completition:completition];
}

#pragma mark - Messages

- (void)getInbox:(NSInteger)userID withCallBack:(DataResultBlock)callBack {
    
    CompletitionBlock completition = [self commonParserForModel:[Message class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getInbox:userID completition:completition];
}

- (void)getDirectMessages:(NSInteger)senderID toReceiver:(NSInteger)receiverID fromLastID:(NSInteger)lastID withCallBack:(DataResultBlock)callBack {
    
    CompletitionBlock completition = [self commonParserForModel:[Message class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllDirectMessages:senderID withReceiver:receiverID fromLastID:lastID completition:completition];
}

- (void)createNewMessage:(CLLocation *)location
                 message:(NSString *)message
                senderID:(NSInteger)senderID
              receiverID:(NSInteger)receiverID
                   photo:(UIImage *)photo
                   sticker:(NSString *)sticker
            withCallBack:(DataResultBlock)callBack {
    
    CompletitionBlock completition = [self commonParserForModel:[Message class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createNewMessage:senderID
                                        receiver:receiverID
                                              message:message
                                             latitude:location.coordinate.latitude
                                            longitude:location.coordinate.longitude
                                            photo:photo
                                            sticker:sticker
                                         completition:completition];
}

- (void)addUserGroup:(NSString *)users withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addUserGroup:userID users:users completition:completition];
    
}

- (void)getUserGroupMessages:(NSInteger)senderID toGroup:(NSInteger)groupID fromLastID:(NSInteger)lastID withCallBack:(DataResultBlock)callBack {
    
    CompletitionBlock completition = [self commonParserForModel:[Message class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getUserGroupMessages:senderID withGroup:groupID fromLastID:lastID completition:completition];
}

- (void)createNewMessageForGroup:(CLLocation *)location
                 message:(NSString *)message
                senderID:(NSInteger)senderID
              groupID:(NSInteger)groupID
                photo:(UIImage *)photo
                sticker:(NSString *)sticker
            withCallBack:(DataResultBlock)callBack {
    
    CompletitionBlock completition = [self commonParserForModel:[Message class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createNewMessageForGroup:senderID
                                                group:groupID
                                                 message:message
                                                latitude:location.coordinate.latitude
                                               longitude:location.coordinate.longitude
                                                   photo:photo
                                             sticker:sticker
                                            completition:completition];
}

#pragma mark - Groups

- (void)checkGroupName:(NSString *)groupname withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] checkGroupName:userID group:groupname completition:completition];
    
}

- (void)addFanGroup:(NSString *)groupname withTeam:(NSString *)team withContacts:(NSString *)contacts withReceivers:(NSString *)receivers andPhoto:(UIImage *)photo withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] addFanGroup:userID group:groupname team:team contacts:contacts receivers:receivers photo:photo completition:completition];
    
}

- (void)groupMembership:(NSString *)membership forGroupID:(NSInteger)groupID withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] groupMemebership:userID membership:membership groupID:groupID completition:completition];
    
}

- (void)getMyGroupsWithCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[Group class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getMyGroups:userID compeletion:completition];
}

- (void)getGroupMembersWithCallBack:(NSInteger)groupID withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForModel:[User class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getGroupMembers:groupID compeletion:completition];
}

- (void)getAllGroupsWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForListOfModel:[Group class] withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getAllGroups:completition];
}

- (void)getSuggestedGroupsWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completition = [self commonParserForListOfModel:[Group class] withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getSuggestedGroups:completition];
}

- (void)updateUserGroups:(NSArray *)tags withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] updateUserGroupsForUser:userID tags:tags completition:completition];
}

- (void)getGroupChatForGroupID:(NSInteger)groupID  withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class] isList:YES withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] getGroupChatForGroupID:groupID withUserID:userID completition:completition];
}

- (void)createNewGroupMessage:(CLLocation *)location
                          withGroupID:(NSInteger)groupID
                              message:(NSString *)message
                                photo:(UIImage *)photo
                         withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonParserForModel:[LocalChat class]
                                                         isList:NO
                                                   withCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager] createNewGroupMessage:userID groupID:groupID message:message photo:photo latitude:location.coordinate.latitude longitude:location.coordinate.longitude completition:completition];
}


#pragma mark - Events methods

- (void)getCloseByEventsPins:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CLLocation *location = [[[[Engine sharedEngine] settingManager] user] getLocation];
    
    CompletitionBlock completition = [self commonParserForModel:[Pin class] isList:YES withCallBack:callBack];
    [[[Engine sharedEngine] apiManager] getCloseByEventsPins:userID withLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude completition:completition];
}


#pragma mark - Helper Methods

- (void)sendTextMessage:(NSString *)phone withMessage:(NSString *)message withCallBack:(DataResultBlock)callBack
{
    NSInteger userID = [[[Engine sharedEngine] settingManager] userID];
    CompletitionBlock completition = [self commonSimpleParserWithMessageWithCallBack:callBack];
    
    [[[Engine sharedEngine] apiManager]  sendTextMessage:userID phone:phone message:message completition:completition];
}


- (void)logout
{
    [[[Engine sharedEngine] settingManager] setUser:nil];
}

#pragma mark - Private methods

- (void)addDeviceIDForUser:(NSInteger)userID
{
   // UIDevice *device = [UIDevice currentDevice];
   // NSString  *currentDeviceId = [[device identifierForVendor] UUIDString];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_device_token"];
    
    if (deviceToken != NULL && ![deviceToken isEqualToString:@""]) {
    
        [[[Engine sharedEngine] apiManager] addDevice:deviceToken forUser:userID completition:^(BOOL success, id result) {
            if (success) {
                NSLog(@"User device added to DB");
            } else {
                NSLog(@"User device didn't added to DB");
            }
        }];
    }
}

- (void)setupLoggedInUser:(NSInteger)userID
{
    [self addDeviceIDForUser:userID];
    [self getUserInfoByID:userID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            [[[Engine sharedEngine] settingManager] setUser:result];
        }
    }];
}

#pragma mark - Common parsing

- (CompletitionBlock)commonParserForModel:(Class<ModelParserProtocol>)class isList:(BOOL)isList withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completitionBlock = ^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                BOOL status = [[result safeObjectForKey:@"status"] boolValue];
                if (status) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        id dataJSON = [result safeObjectForKey:@"data"];
                        id returnResult = nil;
                        if (isList) {
                            
                            NSArray *listJSON = (NSArray *)dataJSON;
                            NSMutableArray *objectsList = [NSMutableArray array];
                            
                            for (NSDictionary *tmpJSON in listJSON) {
                                id object = [class objectFromJSON:tmpJSON];
                                [objectsList addObject:object];
                            }
                            returnResult = objectsList;
                        } else {
                            NSDictionary *modelJSON = (NSDictionary *)dataJSON;
                            returnResult = [class objectFromJSON:modelJSON];
                        }
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            callBack(YES, returnResult, nil);
                        });
                    });
                    
                } else {
                    NSString *message = [result safeObjectForKey:@"message"];
                    callBack(NO, nil, message);
                }
            }
        }
    };
    
    return completitionBlock;
}

- (CompletitionBlock)commonParserForListOfModel:(Class<ModelParserProtocol>)class withCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completitionBlock = ^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                NSLog(@"Got success");
                NSArray *listJSON = (NSArray *)result;
                NSMutableArray *objectsList = [NSMutableArray array];
                
                for (NSDictionary *tmpJSON in listJSON) {
                    id object = [class objectFromJSON:tmpJSON];
                    [objectsList addObject:object];
                }
                result = objectsList;
                
                callBack(YES, result, nil);
            } else {
                NSString *message = [result safeObjectForKey:@"message"];
                callBack(NO, nil, message);
            }
        }
    };
    
    return completitionBlock;
}

- (CompletitionBlock)commonSimpleParserWithMessageWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completitionBlock = ^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                NSLog(@"result %@",result);
                BOOL status = [[result safeObjectForKey:@"status"] boolValue];
                NSString *message = [result safeObjectForKey:@"message"];
                
                if (status) {
                    callBack(YES,message,nil);
                } else {
                    callBack(NO, nil, message);
                }
            } else {
                callBack(NO, nil, result);
            }
        }
    };
    
    return completitionBlock;
}

- (CompletitionBlock)commonSimpleParserWithMessageAndURLWithCallBack:(DataResultBlock)callBack
{
    CompletitionBlock completitionBlock = ^(BOOL success, id result) {
        if (callBack) {
            if (success) {
                NSLog(@"result %@",result);
                BOOL status = [[result safeObjectForKey:@"status"] boolValue];
                NSString *message = [result safeObjectForKey:@"message"];
                
                if (status) {
                    NSString *url = [result safeObjectForKey:@"data"];
                    callBack(YES, url, message);
                } else {
                    callBack(NO, nil, message);
                }
            } else {
                callBack(NO, nil, result);
            }
        }
    };
    
    return completitionBlock;
}

#pragma mark - Helpers 

- (NSString *)dobStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd/"]; //yyyy-mm-dd
    NSString *dobString = [dateFormat stringFromDate:date];
    return dobString;
}


@end
