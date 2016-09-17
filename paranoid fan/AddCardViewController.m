//
//  AddCardViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/9/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "AddCardViewController.h"
#import <Stripe/Stripe.h>
#import "Engine.h"
#import "MBProgressHUD.h"
#import "UIViewController+Popup.h"

@interface AddCardViewController ()

@property (nonatomic, strong) IBOutlet UITextField *nameOnCard;
@property (nonatomic, strong) IBOutlet UITextField *cardNum;
@property (nonatomic, strong) IBOutlet UITextField *cvc;
@property (nonatomic, strong) IBOutlet UILabel *expiry;
@property (nonatomic, retain) UIPickerView *picker;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) IBOutlet UIButton *btnBack;
@property (nonatomic, strong) IBOutlet UIButton *btnSkip;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

///Stripe
@property (retain, nonatomic) STPCardParams *cardParams;


@end

@implementation AddCardViewController

@synthesize onBoarding;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([onBoarding isEqualToString:@"false"]) {
        
        _btnBack.hidden = NO;
        _btnSkip.hidden = YES;
    }
    else {
        
        _btnSkip.hidden = NO;
        _btnBack.hidden = YES;
    }
    
    _pickerData = @[ @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"], @[@"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", @"2027", @"2028", @"2029", @"2030"]];
    
    self.expiry.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectExpiry)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.expiry addGestureRecognizer:tapGestureRecognizer];
    
    _nameOnCard.delegate = self;
    _cardNum.delegate = self;
    _cvc.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction) saveCard {
    
    self.cardParams = [[STPCardParams alloc] init];
    [self.cardParams setName:_nameOnCard.text];
    [self.cardParams setNumber:_cardNum.text];
    [self.cardParams setCvc:_cvc.text];
    [self.cardParams setExpMonth:[[_expiry.text substringWithRange:NSMakeRange(0, 2)] integerValue]];
    [self.cardParams setExpYear:[[_expiry.text substringWithRange:NSMakeRange(3, 4)] integerValue]];
    
    [[STPAPIClient sharedClient]
     createTokenWithCard:self.cardParams
     completion:^(STPToken *token, NSError *error) {
         if (error) {
             [self showErrorMessage:@"You card was declined, try adding another card."];
             NSLog(@"Error via Stripe %@", error);
         } else {
             [self createBackendChargeWithToken:token];
         }
     }];
}

- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) skip {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) selectExpiry {
    
    [_nameOnCard resignFirstResponder];
    [_cardNum resignFirstResponder];
    [_cvc resignFirstResponder];
    
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
    
    NSString *expireDate = @"";
    NSInteger row = [_picker selectedRowInComponent:0];
    expireDate = _pickerData[0][row];
    
    row = [_picker selectedRowInComponent:1];
    expireDate = [expireDate stringByAppendingFormat:@"/%@", _pickerData[1][row]];
    
    self.expiry.text = expireDate;
    self.expiry.textColor = [UIColor whiteColor];
    
    [[self.view viewWithTag:333] removeFromSuperview];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_pickerData[component] count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[component][row];
}

#pragma mark UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = -1*keyboardSize.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - Stripe

- (void)createBackendChargeWithToken:(STPToken *)token {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSLog(@"Got Stripe Token: %@", token.tokenId);
    
    [[[Engine sharedEngine] dataManager] addCard:token.tokenId
                                    withCallBack:
     ^(BOOL success, id result, NSString *errorInfo) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (success) {
             NSLog(@"%@", result);
             
             [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"ccAdded"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [self showSuccessMessage:@"Card has been added successfully!"];
             
             [self goBack];
             
         } else {
             [self showErrorMessage:errorInfo];
         }
     }];
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
