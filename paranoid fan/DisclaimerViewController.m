//
//  DisclaimerViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/10/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "DisclaimerViewController.h"
#import <GrowingTextViewHandler.h>
#import <Google/Analytics.h>

@interface DisclaimerViewController ()

@property (strong, nonatomic) GrowingTextViewHandler *handler;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation DisclaimerViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Disclaimer Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [[GrowingTextViewHandler alloc] initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
    
    NSString *text = @"You’re about to join a social network for sports fans where you make new friends, share experiences and get engaged into your community.\nOur app is driven by user geo-location and collaboration, as such we depend on you to help us build our community. By clicking ACCEPT you confirm that:\n You have read and agree to the Terms of Use and Privacy Policy (the “agreements”) which can be found in the settings section of the app."
    "\nThe use of the Service is subject to the Agreements and indicates your consent to them.  This summary is not meant to replace them.  It is intended for convenience purposes only. YOUR USE OF THIS REAL TIME LOCATION APPLICATION IS AT YOUR SOLE RISK."
    "\n\nIT WILL TRACK YOUR LOCATION AND ALLOW OTHER PUBLIC (NON-FRIEND) USERS TO DO THE SAME. IF YOU FEEL UNCOMFORTABLE WITH THIS CAPABILITY, WE ASK THAT YOU EITHER DISABLE THE TRACKING OR REMOVE\nTHE APP FROM YOUR DEVICE.  You agree to Paranoid Fan receiving from your mobile device detailed location and other pertinent information, for example in the form of GPS signals and other information.  Paranoid Fan uses this information to the offer the Service to you, to improve the quality of the service it offers.  In particular, Paranoid Fan uses this data to aggregate, build and refine a sports-orientated interest graph.\r\n\r\nAlways be careful when making engaging others and/or new friends on our application.  You can always contact us at help@paranoidfan.com if you find yourself in an awkward or sticky situation.\n\n"
        "You hereby confirm that you own all exclusive rights at any data and content that you provide to the Service and may assign in license such rights.  You keep all title and rights to the content, but you grant Paranoid Fan a worldwide, free, non-exclusive, irrevocable, sublicensable, transferable and perpetual license to use, copy, distribute, create derivative works o, public display, public perform and exploit in any other manner the content.  Subject the aforementioned, Paranoid Fan keeps title and all rights to the Service’s database which you may use for non-commercial and private purposes only. Paranoid Fan is offered for free with the hope that you use our application to help us build a community.  However, Paranoid Fan or its employees, directors, shareholders, advisors, or anyone on its behalf shall not be liable to you or to any third party, for any reason whatsoever, as result with the use of the company’s product or service.  You hereby irrevocably release all of the above from an liability of any kind, for any consequence arising from the use of this application or service, including for any loss, loss of profit, damage of reputation, fee, expense or damage, direct or indirect, financial or non-financial.\n";
    [self.handler setText:text withAnimation:NO];
    
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
