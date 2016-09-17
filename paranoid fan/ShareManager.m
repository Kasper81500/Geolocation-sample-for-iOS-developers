//
//  ShareManager.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/8/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ShareManager.h"
#import <EasyFacebook.h>
#import <EasyTwitter.h>
#import "NSArray+JSON.h"
#import <MessageUI/MessageUI.h>
#import <APContact.h>

// help link https://github.com/pjebs/EasySocial

@interface ShareManager()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, copy) Callback fbLoginCallback;
@property (nonatomic, weak) UIViewController *parentController;

@end

@implementation ShareManager

- (void)requireTwitterPermisionsWithCallBack:(Callback)callback
{
    [[EasyTwitter sharedEasyTwitterClient] requestPermissionForAppToUseTwitterSuccess:^(BOOL granted, BOOL accountsFound, NSArray *accounts) {
        if (granted) {
            
            [self disconnectTwitter];
            
            [EasyTwitter sharedEasyTwitterClient].account = [accounts firstObject];
            
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:[accounts firstObject]];
            
            [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"twitter_account"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                   message:[NSString stringWithFormat:@"@%@ is connected now.", [EasyTwitter sharedEasyTwitterClient].account.username]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [warningAlert show];
            
            callback(YES,nil);
        }
        else if (granted && !accountsFound) {
            
            if (callback) {
                callback(NO, @"No Account found, add twitter account first in settings.");
            }
        }
        else {
            if (callback) {
                callback(NO, @"Access denied");
            }
        }
    } failure:^(NSError *error) {
        callback(NO, error.localizedDescription);
    }];
}

- (void)requireFBPermisionsWithCallBack:(Callback)callback
{
    if (![[EasyFacebook sharedEasyFacebookClient] isLoggedIn]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbUserLoggedIn:) name:EasyFacebookLoggedInNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbUserLoginCancelled:) name:EasyFacebookUserCancelledLoginNotification object:nil];
        
        if (callback) {
            self.fbLoginCallback = [callback copy];
        }
        
        [[EasyFacebook sharedEasyFacebookClient] openSession];
    } else {
        if (callback) {
            callback(YES, nil);
        }
    }
}

- (BOOL)isFacebookConnected
{
    return [[EasyFacebook sharedEasyFacebookClient] isLoggedIn];
}

- (BOOL)isTwitterConnected
{
    if ([[EasyTwitter sharedEasyTwitterClient] account]) {
        return YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitter_account"] != nil) {
        
        NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitter_account"];
        ACAccount *account = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        [EasyTwitter sharedEasyTwitterClient].account = account;
        
        return YES;
    }
    
    
    return NO;
}

- (void)disconnectFacebook
{
    [[EasyFacebook sharedEasyFacebookClient] closeSession];
}

- (void)disconnectTwitter
{
    [EasyTwitter sharedEasyTwitterClient].account = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"twitter_account"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)postToFacebookWithPin:(Pin *)pin callback:(Callback)callback
{
    if ([[EasyFacebook sharedEasyFacebookClient] isPublishPermissionsAvailableQuickCheck]) {
        
        NSString *testMessage = [self shareMessageForPin:pin witTextLengthLimit:-1];
        NSDictionary *params = @{@"link" : @"pfan.co",
                                 @"name" : @"paranoidfan",
                                 @"message" : testMessage
                                 };
        
        [[EasyFacebook sharedEasyFacebookClient] publishStoryWithParams:params completion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"FB posted");
                if (callback) {
                    callback(YES, nil);
                }
            } else {
                NSLog(@"Error: %@",error.localizedDescription);
                if (callback) {
                    callback(NO, error.localizedDescription);
                }
            }
        }];
    } 
}

- (void)postToTwitterWithPin:(Pin *)pin callback:(Callback)callback
{
    NSString *tweet = [self tweetForPin:pin];
    
    [[EasyTwitter sharedEasyTwitterClient] sendTweetWithMessage:tweet
                                                twitterResponse:
     ^(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (callback) {
             if (!error) {
                 callback(YES, nil);
             } else {
                 callback(NO, error.localizedDescription);
             }
         }
     } failure: ^(EasyTwitterIssues issue) {
         if (callback) {
             callback(NO, [self twitterErrorMessageForIssue:issue]);
         }
     }];
}

- (void)postToTwitterWithMessage:(NSString *)message photoURLString:(NSString *)photoURLString callback:(Callback)callback
{
    [[EasyTwitter sharedEasyTwitterClient] sendTweetWithMessage:message
                                                       imageURL:[NSURL URLWithString:photoURLString]
                                                twitterResponse:^(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (callback) {
             if (!error) {
                 callback(YES, nil);
             } else {
                 callback(NO, error.localizedDescription);
             }
         }
     } failure:^(EasyTwitterIssues issue) {
         if (callback) {
             callback(NO, [self twitterErrorMessageForIssue:issue]);
         }
     }];
}

- (void)inviteUsers:(NSArray *)users forPin:(Pin *)pin fromController:(UIViewController *)controller
{
    NSString *urlString = [self urlForLocation:[pin getLocation]];
    NSString *message = [NSString stringWithFormat:@"Hi! I'm using the Paranoid Fan app to invite you to meet me at this location: %@", urlString];    
    
    [self inviteUsers:users withText:message andSubject:@"Paranoid Fan - Meet me" fromController:controller];
}

- (void)inviteUsers:(NSArray *)users withLocation:(CLLocation *)location customMessage:(NSString *)customMessage fromController:(UIViewController *)controller
{
    NSString *urlString = [self urlForLocation:location];
    NSString *message = [NSString stringWithFormat:@"%@ %@", customMessage ? customMessage : @"", urlString];
    
    [self inviteUsers:users withText:message andSubject:@"Paranoid Fan - Meet me" fromController:controller];
}

- (void)inviteUsers:(NSArray *)users withText:(NSString *)text andSubject:(NSString *)subject fromController:(UIViewController *)controller
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:@"Your device doesn't support SMS!"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
   
    NSMutableArray *recipents = [NSMutableArray array];
    for (APContact *contact in users) {
        [recipents addObject:contact.phones.firstObject.number];
    }
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:text];
//    [messageController setSubject:subject];

    [controller presentViewController:messageController animated:YES completion:nil];
    
    self.parentController = controller;
}

#pragma mark - Notifications

- (void)fbUserLoggedIn:(NSNotification *)notification
{
    if (self.fbLoginCallback) {
        self.fbLoginCallback(YES, nil);
    }
}

- (void)fbUserLoginCancelled:(NSNotification *)notification
{
    if (self.fbLoginCallback) {
        self.fbLoginCallback(NO, @"Login Cancelled");
    }
}

#pragma mark - SMS

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
    self.parentController = nil;
}



#pragma mark - Private methods

- (NSString *)tweetForPin:(Pin *)pin
{
    return [self shareMessageForPin:pin witTextLengthLimit:140];
}

- (NSString *)shareMessageForPin:(Pin *)pin witTextLengthLimit:(NSInteger)limit
{
  //  NSArray *tags = [NSArray arrayFromTags:pin.mapPinTags];
    
    // |MAPPING| I just dropped a a pin on the #paranoidfan map. #(TEAM1) #(TEAM2) pfan.co
    NSString *startMessage = @"|MAPPING| I just pinned ";
    NSString *endMessage = @" on the @paranoidfan map ";
    NSString *middleMessage = [pin.mapPinType lowercaseString];
    
    if ([middleMessage isEqualToString:@"partying"])
        middleMessage = @"a party";
    else if ([middleMessage isEqualToString:@"playing"])
        middleMessage = @"a social activity";
    else if ([middleMessage isEqualToString:@"celebrity"])
        middleMessage = @"a celebrity sighting";
    else if ([middleMessage isEqualToString:@"music"])
        middleMessage = @"music playing";
    else if ([middleMessage isEqualToString:@"Meetup"])
        middleMessage = @"a meetup";
    else if ([middleMessage isEqualToString:@"apparel"])
        middleMessage = @"an apparel shop";
    else if ([middleMessage isEqualToString:@"police"])
        middleMessage = @"a police sighting";
    else if ([middleMessage isEqualToString:@"ticket"])
        middleMessage = @"tickets";
    else if ([middleMessage isEqualToString:@"parking"])
        middleMessage = @"parking";
    else if ([middleMessage isEqualToString:@"beer"])
        middleMessage = @"beer";
    else if ([middleMessage isEqualToString:@"taxi"])
        middleMessage = @"a cab stand";
    else if ([middleMessage isEqualToString:@"entry exit"])
        middleMessage = @"a venue entry/exit";
    else if ([middleMessage isEqualToString:@"note"])
        middleMessage = @"a helpful note";
    else if ([middleMessage isEqualToString:@"food & drinks"])
        middleMessage = @"food and drinks";
    else
        middleMessage = [NSString stringWithFormat:@"a %@", middleMessage];
    
 /*   NSInteger tweetLimit = limit;
    NSInteger baseMessageLength = startMessage.length + endMessage.length;
    
    NSMutableString *tagsString = [NSMutableString string];
    
    for (NSString *tagName in tags) {
        NSString *hashTag = [@" #" stringByAppendingString:tagName];
        NSInteger currentMessageLength = baseMessageLength + tagsString.length + hashTag.length;
        
        if (tweetLimit == -1) {
            [tagsString appendString:hashTag];
        } else if (tweetLimit < currentMessageLength) {
            [tagsString appendString:hashTag];
        } else {
            break;
        }
    }
   */
    NSString *tweet = [NSString stringWithFormat:@"%@%@%@http://paranoidfan.com/meetme.php?latittude=%f&longitude=%f", startMessage, middleMessage, endMessage, pin.mapPinLatitude, pin.mapPinLongitude];
    return tweet;
}

- (NSString *)twitterErrorMessageForIssue:(EasyTwitterIssues)issue
{
    switch (issue) {
        case EasyTwitterNoAccountsFound: return @"Twitter: No Accounts Found";
        case EasyTwitterPermissionNotGranted: return @"Twitter: Permission Not Granted";
        case EasyTwitterNoAccountSet: return @"Twitter: No Account Set";
        case EasyTwitterUnknown: return @"Twitter: Unknown";
    }
    return nil;
}

- (NSString *)urlForLocation:(CLLocation *)location
{
    NSString *urlString = [NSString stringWithFormat:@" http://paranoidfan.com/meetme.php?latittude=%f&longitude=%f",location.coordinate.latitude,location.coordinate.longitude];
    return urlString;
}

@end
