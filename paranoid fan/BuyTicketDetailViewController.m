//
//  BuyTicketDetailViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BuyTicketDetailViewController.h"
#import "SKTagView.h"
#import "Ticket.h"
#import "NSArray+JSON.h"
#import "Constants.h"

@interface BuyTicketDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *sectionLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfTicketsLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *deliveryLabel;

@property (nonatomic, weak) IBOutlet UIView *contactView;
@property (nonatomic, weak) IBOutlet UIButton *contactButton;

@property (nonatomic, weak) IBOutlet SKTagView *teamsView;

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@end

@implementation BuyTicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.ticket.title;
    self.distanceLabel.text = self.ticket.distance;
    self.sectionLabel.text = [NSString stringWithFormat:@"%zd",self.ticket.section];
    self.numberOfTicketsLabel.text = [NSString stringWithFormat:@"%zd",self.ticket.quantity];
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f",self.ticket.price];
    CGFloat total = self.ticket.quantity * self.ticket.price;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"$%.2f",total];
    self.deliveryLabel.text = self.ticket.delivery;

    self.contactButton.hidden = NO;
    self.contactView.hidden = YES;
    
    [self setupTeamTagView];
    [self setupMyTags];
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    _payPalConfiguration.acceptCreditCards = YES;
    _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self.teamsView updateConstraintsIfNeeded];
    
    [self.view updateConstraintsIfNeeded];
}

#pragma mark - Actions

- (IBAction)contactFormOpen:(UIButton *)sender
{
    self.contactButton.hidden = YES;
    self.contactView.hidden = NO;
}

- (IBAction)callSeller:(UIButton *)sender
{
    
}

- (IBAction)emailSeller:(UIButton *)sender
{
    
}

- (IBAction)orderTicket:(UIButton *)sender
{
 
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    // Amount, currency, and description
    payment.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%f", self.ticket.price]];
    payment.currencyCode = @"USD";
    payment.shortDescription = self.ticket.title;
    
    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture.
    // To perform Authorization only, and defer Capture to your server,
    // use PayPalPaymentIntentAuthorize.
    // To place an Order, and defer both Authorization and Capture to
    // your server, use PayPalPaymentIntentOrder.
    // (PayPalPaymentIntentOrder is valid only for PayPal payments, not credit card payments.)
    payment.intent = PayPalPaymentIntentSale;
    
    // Check whether payment is processable.
    if (!payment.processable) {
        NSLog(@"Not processing");
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    
    // Create a PayPalPaymentViewController.
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:self.payPalConfiguration
                                                                        delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self presentViewController:paymentViewController animated:YES completion:nil];

}

- (IBAction)cancelClicked:(id)sender
{
    [self hideSelf];
}

#pragma mark - Tags

- (void)setupTeamTagView
{
    [self commonSetupForTagView:self.teamsView];

}

- (void)setupMyTags
{
    NSArray *myTags = [NSArray arrayFromTags:self.ticket.tags];
    [self addTags:myTags forView:self.teamsView];
}

- (void)commonSetupForTagView:(SKTagView *)tagView
{
    tagView.backgroundColor = [UIColor clearColor];
    tagView.padding    = UIEdgeInsetsMake(5, 10, 5, 10);
    tagView.insets    = 5;
    tagView.lineSpace = 4;
}

#pragma mark - Tags Manager

- (void)addTags:(NSArray *)tags forView:(SKTagView *)tagView
{
    for (NSString *tagString in tags) {
        [self addTag:tagString forView:tagView];
    }
}

- (void)addTag:(NSString *)tagString forView:(SKTagView *)tagView
{
    UIColor *blueBackgroundColor = rgbColor(25.0, 139.0, 185.0);
    
    SKTag *tag = [SKTag tagWithText:tagString];
    tag.textColor = UIColor.whiteColor;
    tag.bgColor = blueBackgroundColor;
    tag.cornerRadius = 0;
    tag.fontSize = 15;
    tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
    
    [tagView addTag:tag];
}


#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:confirmation options:0 error:&error];

    NSLog(@"%@", json);
    
    [self performSegueWithIdentifier:@"successBuy" sender:self];
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}


@end
