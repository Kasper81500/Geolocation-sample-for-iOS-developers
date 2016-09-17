//
//  AppDelegate.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <EasyFacebook.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>
#import <Google/Analytics.h>
#import <Stripe/Stripe.h>
#import "InboxViewController.h"

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[GMSServices provideAPIKey:@"AIzaSyCaAot0k40dx5bYTaaS_58UUxIaynWBMWg"];
    [GMSServices provideAPIKey:@"AIzaSyD7Z1R58A-Mrc5vIfNBgGsU6odPmn97jnM"];
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"ARpvlYyrgGQNvyav6piNq8KP1U3QQUUjrHudhWXAz2xSkBjIfFC2CgVfTi44pqtROQoOzvSGY7rndEZL"}];
    
    //[Stripe setDefaultPublishableKey:@"pk_test_fN0yN8yaj1jUed67VVzbR1Td"];
    [Stripe setDefaultPublishableKey:@"pk_live_1Lq0LHNkajVWOzvOmLVvnJlx"];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSString *deviceToken = [devToken description];
    
    deviceToken = [[[deviceToken
                     stringByReplacingOccurrencesOfString:@"<"withString:@""]
                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];

    [self setDeviceToken:deviceToken]; // custom method
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    int badgeCount = [[[userInfo objectForKey:@"aps"] objectForKey: @"badge"] intValue] + 1;
    
   // NSString *alert  = [[userInfo objectForKey:@"aps"] objectForKey: @"alert"];
    
    if (IS_OS_8_OR_LATER) {
        
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (currentSettings.types == UIUserNotificationTypeBadge)
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
    }
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
  /*
    if ([alert containsString:@"new message"]) {
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InboxViewController *inboxVC = [storyboard instantiateViewControllerWithIdentifier:@"inboxView"];
        [navigationController pushViewController:inboxVC animated:NO];
    }
   */
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled1 = [EasyFacebook handleOpenURL:url sourceApplication:sourceApplication];
    //  BOOL wasHandled2 = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    //  BOOL wasHandled3 = [TumblrAPI handleURL:url];
    
    return wasHandled1;
    //  return (wasHandled1 || wasHandled2 || wasHandled3);
}

#pragma mark - Notifications

- (void) setDeviceToken:(NSString *) deviceToken {
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:@"user_device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
