//
//  ReviewOfferViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ReviewOfferViewController.h"
#import "SKTagView.h"
#import "Engine.h"
#import "Ticket.h"
#import "UIViewController+Popup.h"
#import "Constants.h"

#define kSeguePlaceOrder    @"placeOrder"

@interface ReviewOfferViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *sectionLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfTicketsLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *commonPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *deliveryLabel;

@property (nonatomic, weak) IBOutlet SKTagView *teamsView;

@end

@implementation ReviewOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.ticketTitle;
    self.sectionLabel.text = [NSString stringWithFormat:@"%d",self.section];
    self.numberOfTicketsLabel.text = [NSString stringWithFormat:@"%d",self.quantity];
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f",self.price];
    self.deliveryLabel.text = self.delivery ? @"In Person" : @"Electronic";
    
    self.commonPriceLabel.text = [NSString stringWithFormat:@"$%.2f",self.price * self.quantity];
    
    [self setupMyTagsView];
    [self setupMyTags];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.teamsView invalidateIntrinsicContentSize];
}

- (BOOL)isShouldHideOnTap
{
    return NO;
}

#pragma mark - Tags

- (void)setupMyTagsView
{
    [self commonSetupForTagView:self.teamsView];
}

- (void)setupMyTags
{
    [self addTags:self.tags forView:self.teamsView];
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


#pragma mark - IBActions

- (IBAction)placeOrder:(id)sender
{
    [[[Engine sharedEngine] dataManager] addNewTicketWithTitle:self.ticketTitle
                                                        detail:self.detail
                                                          tags:self.tags
                                                      quantity:self.quantity
                                                       section:self.section
                                                         price:self.price
                                                      delivery:self.delivery
                                                         phone:self.phone
                                                  withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
         if (success) {
             [self performSegueWithIdentifier:kSeguePlaceOrder sender:self];
         } else {
             NSString *message = errorInfo ? errorInfo : @"Sorry, something went wrong.";
             
             [self showErrorMessage:message];
         }
     }];
}

- (IBAction)clickCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
