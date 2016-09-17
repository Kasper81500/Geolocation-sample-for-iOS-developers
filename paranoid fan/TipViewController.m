//
//  TipViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/5/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "TipViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Engine.h"
#import "MBProgressHUD.h"
#import "UIViewController+Popup.h"
#import "User.h"
#import "AddCardViewController.h"

@interface TipViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *profileAvatar;
@property (nonatomic, strong) IBOutlet UILabel *profileName;
@property (nonatomic, strong) IBOutlet UILabel *heartCount;
@property (nonatomic, strong) IBOutlet UIButton *btnAmount;
@property (nonatomic, strong) IBOutlet UITextField *txtAmount;
@property (nonatomic, strong) IBOutlet UILabel *tipInfo;
@property (nonatomic, strong) IBOutlet UILabel *hereLink;
@property (nonatomic, retain) UIPickerView *picker;
@property (nonatomic, strong) NSArray *pickerData;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtAmountheightConstraint;

@end

@implementation TipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pickerData = @[@"$5", @"$10", @"$15", @"$20", @"$25", @"$50", @"Other"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.txtAmount.leftView = paddingView;
    self.txtAmount.leftViewMode = UITextFieldViewModeAlways;
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *doItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone)];
    [toolBar setItems:@[doItem]];
    
    
    _txtAmount.inputAccessoryView = toolBar;
    
    self.profileName.text = self.pinChatItem.profileName;
    self.txtAmount.hidden = YES;
    self.heartCount.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Heart"]];
    self.heartCount.text = [NSString stringWithFormat:@"%ld", self.pinChatItem.likeCount];
    [_profileAvatar setImageWithURL:[NSURL URLWithString:self.pinChatItem.avatar]];
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:@"We will charge your card. If you need to add a card go here."];
    // Sets the font color of last four characters to blue.
    [stringText addAttribute: NSForegroundColorAttributeName value: [UIColor blueColor] range: NSMakeRange(55, 5)];
    self.tipInfo.attributedText = stringText;
    self.tipInfo.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCard)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.tipInfo addGestureRecognizer:tapGestureRecognizer];
    
    [self setTipInfoLocation];
    
}

- (void) setTipInfoLocation {
    
    if ([_txtAmount isHidden]) {
        
        _txtAmountheightConstraint.constant = 0;
    }
    else {
        
        _txtAmountheightConstraint.constant = 40;
    }
}

- (IBAction)sendTip  {
    
    if (![_txtAmount.text isEqualToString:@""] || (![_btnAmount.titleLabel.text isEqualToString:@"Select an amount"] && ![_btnAmount.titleLabel.text isEqualToString:@"Other"])) {
        
        NSString *amt = @"";
        
        if (![_btnAmount.titleLabel.text isEqualToString:@"Other"] && ![_btnAmount.titleLabel.text isEqualToString:@"Select an amount"])
            amt = [_btnAmount.titleLabel.text substringFromIndex:1];
        else
            amt = _txtAmount.text;
        
        NSLog(@"Amount: %@", amt);
        
        User *user = [Engine sharedEngine].settingManager.user;
        
        NSLog(@"%u", user.ccAdded);
        
        if (user.ccAdded || [[[NSUserDefaults standardUserDefaults] objectForKey:@"ccAdded"] isEqualToString:@"true"]) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[[Engine sharedEngine] dataManager] payTip:self.pinChatItem.userId tipAmount:[amt floatValue] forChatID:self.pinChatItem.pinChatId
                                           withCallBack:
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
        [self showErrorMessage:@"You must select an amount!"];
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
    [lblThanks setText:[NSString stringWithFormat:@"Tip Sent! \n%@ thanks you", self.pinChatItem.profileName]];
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
    
    [self performSegueWithIdentifier:@"addCard" sender:self];
}


#pragma mark - Picker View related Funcs

- (IBAction) openTipAmountSelection {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(doneClicked)];
    toolBar.items = @[flex, barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height, screenWidth, 200)];
    _picker.delegate = self;
    _picker.dataSource = self;
    _picker.showsSelectionIndicator = YES;
    
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - (toolBar.frame.size.height + _picker.frame.size.height), screenWidth, toolBar.frame.size.height + _picker.frame.size.height)];
    inputView.tag = 333;
    inputView.backgroundColor = [UIColor whiteColor];
    [inputView addSubview:_picker];
    [inputView addSubview:toolBar];
    
    [self.view addSubview:inputView];
}

- (void)doneClicked {
    
    NSInteger row = [_picker selectedRowInComponent:0];
    self.btnAmount.titleLabel.text = [_pickerData objectAtIndex:row];
    
    if ([[_pickerData objectAtIndex:row] isEqualToString:@"Other"])
        self.txtAmount.hidden = NO;
    else {
        self.txtAmount.text = @"";
        self.txtAmount.hidden = YES;
    }
    
    [self setTipInfoLocation];
    
    [[self.view viewWithTag:333] removeFromSuperview];
}

- (void) doDone {
  
    [_txtAmount resignFirstResponder];
    NSLog(@"hererer");
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"addCard"]) {
        
        AddCardViewController *addCardVC = (AddCardViewController *) [segue destinationViewController];
        addCardVC.onBoarding = @"false";
    }
}


@end
