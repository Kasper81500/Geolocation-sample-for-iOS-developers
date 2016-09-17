//
//  TransferFundsViewController.m
//  Paranoid Fan
//
//  Created by Adeel Asim on 6/29/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import "TransferFundsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Engine.h"
#import "MBProgressHUD.h"
#import "UIViewController+Popup.h"
#import "User.h"
#import "AddCardViewController.h"


@interface TransferFundsViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *profileAvatar;
@property (nonatomic, strong) IBOutlet UILabel *profileName;
@property (nonatomic, strong) IBOutlet UITextField *txtAmount;
@property (nonatomic, strong) IBOutlet UILabel *tipInfo;

@end

@implementation TransferFundsViewController

@synthesize receiverID, fullname, avatar, isGroup;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.txtAmount.leftView = paddingView;
    self.txtAmount.leftViewMode = UITextFieldViewModeAlways;
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *doItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone)];
    [toolBar setItems:@[doItem]];
    
    _txtAmount.inputAccessoryView = toolBar;
    
    self.profileName.text = fullname;
    
    if (!isGroup)
        self.profileAvatar.image = avatar;
    else
        self.profileAvatar.image = [UIImage imageNamed:@"Groups"];
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:@"We will charge your card. If you need to add a card go here."];
    // Sets the font color of last four characters to blue.
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor blueColor] range: NSMakeRange(55, 5)];
    self.tipInfo.attributedText = stringText;
    self.tipInfo.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCard)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.tipInfo addGestureRecognizer:tapGestureRecognizer];
}

- (IBAction)sendFunds  {
    
    if (![_txtAmount.text isEqualToString:@""] && [self.txtAmount.text floatValue] > 4.99) {
        
        NSString *amt = _txtAmount.text;
        
        NSLog(@"Amount: %@", amt);
        
        NSString *group = isGroup ? @"Yes" : @"No";
        
        User *user = [Engine sharedEngine].settingManager.user;
        
        NSLog(@"%u", user.ccAdded);
        
        if (user.ccAdded || [[[NSUserDefaults standardUserDefaults] objectForKey:@"ccAdded"] isEqualToString:@"true"]) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[[Engine sharedEngine] dataManager] sendMoney:receiverID amount:[amt floatValue] isGroup:group withCallBack:
             ^(BOOL success, id result, NSString *errorInfo) {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 if (success) {
                     NSLog(@"%@", result);
                     //[self showSuccessMessage:@"Tip has been paid!"];
                     [self showSuccessTipScreen];
                     
                 } else {
                     [self showErrorMessage:errorInfo];
                 }
             }];
            
        }
        else {
            
            NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:@"We will charge your card. If you need to add a card go here."];
            // Sets the font color of last four characters to blue.
            [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor redColor] range: NSMakeRange(0, 60)];
            self.tipInfo.attributedText = stringText;
        }
        
    }
    else {
        [self showErrorMessage:@"You must enter an amount, minimum $5!"];
    }
    
    
}

- (void) showSuccessTipScreen {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    UIView *successScreen = [[UIView alloc] initWithFrame:frame];
    successScreen.tag = 777;
    successScreen.backgroundColor = [UIColor whiteColor];
    
    UIImageView *checkMark = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2)-56, 100, 111, 114)];
    [checkMark setImage:[UIImage imageNamed:@"checkmark"]];
    
    UILabel *lblThanks = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, frame.size.width, 50)];
    lblThanks.numberOfLines = 3;
    lblThanks.font = [UIFont fontWithName:@"Roboto-Bold" size:18];
    [lblThanks setText:[NSString stringWithFormat:@"Amount Sent! \n%@ thanks you", fullname]];
    [lblThanks setTextAlignment:NSTextAlignmentCenter];
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height-60, frame.size.width, 60)];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeThanksPopup) forControlEvents:UIControlEventTouchUpInside];
    [btnClose setBackgroundColor:[UIColor colorWithRed:27.0/255.0 green:153.0/255.0 blue:214.0/255.0 alpha:1.0]];
    
    [successScreen addSubview:checkMark];
    [successScreen addSubview:lblThanks];
    [successScreen addSubview:btnClose];
    
    [self.view addSubview:successScreen];
}

- (void) closeThanksPopup {
    
    [self.navigationController popViewControllerAnimated:YES];
    [[self.view viewWithTag:777] removeFromSuperview];
}

- (IBAction)close {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addCard {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddCardViewController *addCardVC = [storyboard instantiateViewControllerWithIdentifier:@"addCardVC"];
    [self.navigationController pushViewController:addCardVC animated:YES];
}

- (void) doDone {
    
    [_txtAmount resignFirstResponder];
    NSLog(@"hererer");
}


@end
