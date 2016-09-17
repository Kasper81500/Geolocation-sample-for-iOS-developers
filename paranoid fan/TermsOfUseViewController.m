//
//  TermsOfUseViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/21/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "TermsOfUseViewController.h"
#import <GrowingTextViewHandler.h>
#import <Google/Analytics.h>

@interface TermsOfUseViewController ()

@property (strong, nonatomic) GrowingTextViewHandler *handler;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation TermsOfUseViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Terms Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [[GrowingTextViewHandler alloc] initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TermsOfUse" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.handler setText:content withAnimation:NO];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
