//
//  AvatarViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "AvatarViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MCRotatingCarousel.h"
#import "MapViewController.h"
#import "ContactsViewController.h"
#import "Engine.h"
#import "UIViewController+Popup.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>

@interface AvatarViewController ()<MCRotatingCarouselDataSource, MCRotatingCarouselDelegate>
{
    MCRotatingCarousel *carousel;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentMF;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong) NSArray *items;
@property (nonatomic) NSInteger selectedViewIndex;

@end

@implementation AvatarViewController

#pragma mark - UIViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Avatar Selection Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_hideBackButton)
        _btnBack.hidden = YES;
    else
        _btnBack.hidden = NO;
    
    if (_showNextButton)
        _btnNext.hidden = NO;
    else
        _btnNext.hidden = YES;
    
    self.items = @[
                   @"black",
                   @"01_TEXAS-TECH",
                   @"02_ARKANSAS-RAZORBACKS",
                   @"03_WEST-VIRGINIA-MOUNTAINEERS",
                   @"04_TCU-FROGS",
                   @"05_TEXAS-LONGHORNS",
                   @"06_OKLAHOMA-SOONERS",
                   @"07_A&M-AGGIES",
                   @"08_KANSAS-JAYHAWKS",
                   @"09_KANSAS-STATE-WILDCATS",
                   @"10_BAYLOR-BEARS",
                   @"11_OKLAHOMA-STATE-COWBOYS",
                   @"12_OKLAHOMA-STATE-COWBOYS",
                   @"13_CSU-RAMS_03",
                   @"14_RICE-UNIVERSITY-OWLS",
                   @"15_FRESNO-STATE-BULLDOGS",
                   @"16_AIR-FORCE-FALCONS",
                   @"17_BOISE-STATE-BRONCOS",
                   @"18_IOWA-STATE-CYCLONES",
                   @"19_WYOMING-COWBOYS_03",
                   @"20__SAN-JOSE-STATE-SPARTANS",
                   @"21_SDSU-AZTECS",
                   @"22_HAWAII-RAINBOWS",
                   @"23_UTAH-STATE-AGGIES_03",
                   @"24_NEW-MEXICO-LOBOS",
                   @"25_UNLV-REBELS",
                   @"26_NEVADA-WOLFPACK",
                   ];
    self.segmentMF.selectedSegmentIndex = 0;
    
    self.segmentMF.clipsToBounds = YES;
    self.segmentMF.layer.cornerRadius = CGRectGetMidY(self.segmentMF.bounds);
    self.segmentMF.layer.borderWidth = 1.0;
    self.segmentMF.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.segmentMF setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    [self.segmentMF setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
    
    self.segmentMF.backgroundColor = UIColorFromHEX(0xB4E1F9);
    self.segmentMF.tintColor = UIColorFromHEX(0x00A3FF);
    
    
    
    CGRect rect = CGRectMake(20, 150, self.view.bounds.size.width - 40, self.view.bounds.size.height - 300);
    carousel = [[MCRotatingCarousel alloc]initWithFrame:rect];
    carousel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    carousel.pageControl.pageIndicatorTintColor = [UIColor cyanColor];
    carousel.sideScale = 0.5;
    [self.view addSubview:carousel];
    
    [self reloadData];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - IBActions

- (IBAction)clickBtnNext:(id)sender {
    
    UIImage *image = [self imageForIndex:_selectedViewIndex];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] updateUserAvatar:image
                                             withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 
                                                 if (success) {
                                                     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                     ContactsViewController *contactsVC = [storyboard instantiateViewControllerWithIdentifier:@"contactsView"];
                                                     [self.navigationController pushViewController:contactsVC animated:YES];
                                                 } else {
                                                     if (errorInfo) {
                                                         [self showErrorMessage:errorInfo];
                                                     }
                                                 }
                                             }];
}

- (IBAction)clickBtnBack:(id)sender {
    
    UIImage *image = [self imageForIndex:_selectedViewIndex];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[Engine sharedEngine] dataManager] updateUserAvatar:image
                                             withCallBack:^(BOOL success, id result, NSString *errorInfo) {
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 
                                                 if (success) {
                                                     [self.navigationController popViewControllerAnimated:YES];
                                                 } else {
                                                     if (errorInfo) {
                                                         [self showErrorMessage:errorInfo];
                                                     }
                                                 }
                                             }];
}

- (IBAction)clickBtnColor:(UIButton *)sender {
    for (int i = 11; i < 20; i ++ ) {
        UIButton *btn = (UIButton *) [self.view viewWithTag:i];
        btn.selected = NO;
    }
    
    sender.selected = YES;
    
    if (self.segmentMF.selectedSegmentIndex == 0) {
        
        
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.items];
        NSInteger nbtnID = [sender tag];
        NSString *str = @"";
        switch (nbtnID) {
            case 11:
                str = @"blue";
                break;
            case 12:
                str = @"dark_green";
                break;
            case 13:
                str = @"yellow";
                break;
            case 14:
                str = @"orange";
                break;
            case 15:
                str = @"maroon";
                break;
            case 16:
                str = @"red";
                break;
            case 17:
                str = @"purple";
                break;
            case 18:
                str = @"black";
                break;
            case 19:
                str = @"white";
                break;
                
                
            default:
                break;
        }
        [mArray replaceObjectAtIndex:0 withObject:str];
        self.items = mArray;
        [self reloadData];
    }
    
    if (self.segmentMF.selectedSegmentIndex == 1) {
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.items];
        NSInteger nbtnID = [sender tag];
        NSString *str = @"";
        switch (nbtnID) {
            case 11:
                str = @"girl_blue";
                break;
            case 12:
                str = @"girl_dark_green";
                break;
            case 13:
                str = @"girl_yellow";
                break;
            case 14:
                str = @"girl_orange";
                break;
            case 15:
                str = @"girl_maroon";
                break;
            case 16:
                str = @"girl_red";
                break;
            case 17:
                str = @"girl_purple";
                break;
            case 18:
                str = @"girl_black";
                break;
            case 19:
                str = @"girl_white";
                break;
                
                
            default:
                break;
        }
        [mArray replaceObjectAtIndex:0 withObject:str];
        self.items = mArray;
        [self reloadData];
    }
}
- (IBAction)SegmentChangeViewValueChanged:(id)sender {
    UISegmentedControl *SControl = sender;
    if (SControl.selectedSegmentIndex == 0) {
        self.items = @[
                       @"black",
                       @"01_TEXAS-TECH",
                       @"02_ARKANSAS-RAZORBACKS",
                       @"03_WEST-VIRGINIA-MOUNTAINEERS",
                       @"04_TCU-FROGS",
                       @"05_TEXAS-LONGHORNS",
                       @"06_OKLAHOMA-SOONERS",
                       @"07_A&M-AGGIES",
                       @"08_KANSAS-JAYHAWKS",
                       @"09_KANSAS-STATE-WILDCATS",
                       @"10_BAYLOR-BEARS",
                       @"11_OKLAHOMA-STATE-COWBOYS",
                       @"12_OKLAHOMA-STATE-COWBOYS",
                       @"13_CSU-RAMS_03",
                       @"14_RICE-UNIVERSITY-OWLS",
                       @"15_FRESNO-STATE-BULLDOGS",
                       @"16_AIR-FORCE-FALCONS",
                       @"17_BOISE-STATE-BRONCOS",
                       @"18_IOWA-STATE-CYCLONES",
                       @"19_WYOMING-COWBOYS_03",
                       @"20__SAN-JOSE-STATE-SPARTANS",
                       @"21_SDSU-AZTECS",
                       @"22_HAWAII-RAINBOWS",
                       @"23_UTAH-STATE-AGGIES_03",
                       @"24_NEW-MEXICO-LOBOS",
                       @"25_UNLV-REBELS",
                       @"26_NEVADA-WOLFPACK",
                      ];

    }else if (SControl.selectedSegmentIndex == 1){
        self.items = @[
                       @"girl_black",
                       @"A&M-AGGIES_03",
                       @"ARKANSAS-RAZORBACKS_03",
                       @"BAYLOR-BEARS_03",
                       @"BOISE-STATE-BRONCOS_03",
                       @"CSU-RAMS_03",
                       @"FRESNO-STATE-BULLDOGS_03",
                       @"HAWAII-RAINBOWS_03",
                       @"IOWA-STATE-CYCLONES_03",
                       @"KANSAS-JAYHAWKS_03",
                       @"KANSAS-STATE-WILDCATS_03",
                       @"NEVADA-WOLFPACK_03",
                       @"NEW-MEXICO-LOBOS_03",
                       @"OKLAHOMA-SOONERS_03",
                       @"OKLAHOMA-STATE-COWBOYS_02_03",
                       @"OKLAHOMA-STATE-COWBOYS_03",
                       @"RICE-UNIVERSITY-OWLS_03",
                       @"SAN-JOSE-STATE-SPARTANS_03",
                       @"SDSU-AZTECS_03",
                       @"TCU-FROGS_03",
                       @"TEXAS-LONGHORNS_03",
                       @"TEXAS-TECH_03",
                       @"UNLV-REBELS_03",
                       @"UTAH-STATE-AGGIES_03",
                       @"WEST-VIRGINIA-MOUNTAINEERS_03",
                       @"WYOMING-COWBOYS_03",
                       ];

    }
    [self reloadData];
}

#pragma mark - Helpers

- (void)reloadData
{
    _selectedViewIndex = 0;
    [carousel reloadData];
}

- (UIImage *)imageForIndex:(NSInteger)index
{
    NSString *strName = self.items[index];
    strName = [NSString stringWithFormat:@"%@.png", strName];
    UIImage *image = [UIImage imageNamed:strName];
    return image;
}

#pragma mark - MCRotatingCarouselDataSource
-(UIView *)rotatingCarousel:(MCRotatingCarousel *)carousel_ viewForItemAtIndex:(NSUInteger)index
{
    //Create your view here - it could be any kind of view, eg. a UIImageView.
    
    CGSize size = carousel_.bounds.size;
    size.width *= 0.6;
    size.height *= 0.6;
    

    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.image = [self imageForIndex:index];
 
    return view;
}

-(NSUInteger)numberOfItemsInRotatingCarousel:(MCRotatingCarousel *)carousel
{
    return self.items.count;
}

#pragma mark - MCRotatingCarouselDelegate
-(void)rotatingCarousel:(MCRotatingCarousel *)carousel didSelectView:(UIView *)view atIndex:(NSUInteger)index
{
    NSLog(@"did select item at index: %lu",(unsigned long)index);
    _selectedViewIndex = index;
}

- (void)rotatingCarousel:(MCRotatingCarousel *)carousel viewMovedToFront:(UIView *)view atIndex:(NSUInteger)index
{
    NSLog(@"did move to front at index: %lu",(unsigned long)index);
    _selectedViewIndex = index;
}


@end
