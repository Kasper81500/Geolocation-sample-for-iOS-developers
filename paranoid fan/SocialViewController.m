//
//  SocialViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SocialViewController.h"
#import "AvatarViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "SettingViewController.h"
#import <Google/Analytics.h>

#define kIsSocialScreenVisible  @"kIsSocialScreenVisible"
#define kIsSkipButtonHidden     @"kIsSkipButtonHidden"
#define kIsPrevScreenSettings        @"kIsPrevScreenSettings"

@interface SocialViewController ()

@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;

@end

@implementation SocialViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Social View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.skipButton.hidden = self.isHideSkipButton;
    
    self.facebookButton.selected = [[[Engine sharedEngine] shareManager] isFacebookConnected];
    self.twitterButton.selected = [[[Engine sharedEngine] shareManager] isTwitterConnected];
    
    [[NSUserDefaults standardUserDefaults] setBool:self.isHideSkipButton forKey:kIsSkipButtonHidden];
    
    NSLog(@"controllers %@",self.navigationController.viewControllers);

    NSInteger count = self.navigationController.viewControllers.count;
    if (count > 1) {
        UIViewController *prevViewController = self.navigationController.viewControllers[count - 2];
        if ([prevViewController isKindOfClass:[SettingViewController class]]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsPrevScreenSettings];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsSocialScreenVisible];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsSocialScreenVisible];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsPrevScreenSettings];
    
    [super viewDidDisappear:animated];
}

- (IBAction)clickBtnFB:(id)sender {
    if (![[[Engine sharedEngine] shareManager] isFacebookConnected]) {        
        [[[Engine sharedEngine] shareManager] requireFBPermisionsWithCallBack:^(BOOL success, NSString *errorMessage) {
            if (success) {
                self.facebookButton.selected = [[[Engine sharedEngine] shareManager] isFacebookConnected];
            } else if (errorMessage) {
                [self showErrorMessage:errorMessage];
            }
        }];
    } else {
        [[[Engine sharedEngine] shareManager] disconnectFacebook];
        self.facebookButton.selected = NO;
    }
}

- (IBAction)clickBtnTwitter:(id)sender {
    if (![[[Engine sharedEngine] shareManager] isTwitterConnected]) {
        [[[Engine sharedEngine] shareManager] requireTwitterPermisionsWithCallBack:^(BOOL success, NSString *errorMessage) {
            if (success) {
                self.twitterButton.selected = [[[Engine sharedEngine] shareManager] isTwitterConnected];
            } else if (errorMessage) {
                [self showErrorMessage:errorMessage];
            }
        }];
    } else {
        [[[Engine sharedEngine] shareManager] disconnectTwitter];
        self.twitterButton.selected = NO;
    }
}


- (IBAction)clickBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBtnSkip:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AvatarViewController *avatarVC = [storyboard instantiateViewControllerWithIdentifier:@"avatarVC"];
    [self.navigationController pushViewController:avatarVC animated:YES];
}

#pragma mark - Public methods

+ (BOOL)wasVisisbleBeforeTerminated
{
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:kIsSocialScreenVisible];
    return value;
}

+ (BOOL)wasSkipButtonHidden
{
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:kIsSkipButtonHidden];
    return value;
}

+ (BOOL)wasPrevScreenSettings
{
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:kIsPrevScreenSettings];
    return value;
}


@end
