//
//  ViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "ViewController.h"
#import "Engine.h"
#import "User.h"
#import "VerifyViewController.h"
#import "SocialViewController.h"
#import <Google/Analytics.h>

@interface ViewController ()

@end

@implementation ViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[[Engine sharedEngine] dataManager] isUserLogin]) {
        
        if ([SocialViewController wasVisisbleBeforeTerminated]) {
            [self loadSocialScreen];
        } else {
        
            [[[Engine sharedEngine] dataManager] updateCurrentUserInfoWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
                if (success) {
                    NSLog(@"Res: %@", result);
                    [[[Engine sharedEngine] settingManager] setUser:result];
                    
                    if ([[[[Engine sharedEngine] settingManager] user].phoneVerified isEqualToString:@"Yes"]) {

                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        UIViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];
                        [self.navigationController pushViewController:mapVC animated:NO];
                    }
                    else {
                    
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        VerifyViewController *verifyVC = [storyboard instantiateViewControllerWithIdentifier:@"enterNumber"];
                        [self.navigationController pushViewController:verifyVC animated:NO];
                    }
                }
            }];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickLogin:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)clickSignUp:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpViewController *signupVC = [storyboard instantiateViewControllerWithIdentifier:@"signupVC"];
    [self.navigationController pushViewController:signupVC animated:YES];
}

#pragma mark - Private methods

- (void)loadSocialScreen
{
    if ([SocialViewController wasPrevScreenSettings]) {
        [self loadSocialScreenFromMapScreen];
    } else {
        [self loadSocialScreenFromMapScreen];
    }
}

- (void)loadSocialScreenFromStartScreen
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *social = [storyboard instantiateViewControllerWithIdentifier:@"socialVC"];
    
    [self.navigationController pushViewController:social animated:NO];
    
}

- (void)loadSocialScreenFromMapScreen
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"mapviewVC"];    
    UIViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"settingVC"];
    UIViewController *socialVC = [storyboard instantiateViewControllerWithIdentifier:@"socialVC"];
    
    [self.navigationController pushViewController:mapVC animated:NO];
    [self.navigationController pushViewController:settingsVC animated:NO];
    [self.navigationController pushViewController:socialVC animated:NO];
}

@end
