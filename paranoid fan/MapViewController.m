//
//  MapViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "MapViewController.h"
#import "MBProgressHUD.h"
#import "MapPoint.h"
#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "SettingViewController.h"
#import "ChatViewController.h"
#import <CoreData/CoreData.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomTableViewCell.h"
#import "PopupTableViewCell.h"
#import "Engine.h"
#import "User.h"
#import "Pin.h"
#import "Ticket.h"
#import "Team.h"
#import "PinChatItem.h"
#import "UserAnnotation.h"
#import "PinAnnotation.h"
#import "UIImageView+AFNetworking.h"
#import "PinsDropTableViewController.h"
#import "GridMenuViewController.h"
#import "CreatePinViewController.h"
#import "PinDetailsViewController.h"
#import "FriendListViewController.h"
#import "FavoriteListViewController.h"
#import "ProfileViewController.h"
#import "Constants.h"
#import "TicketAnnotaion.h"
#import "BuyTicketDetailViewController.h"
#import "UIViewController+Popup.h"
#import "Stadium.h"
#import "StadiumAnnotation.h"
#import "LeaderboardViewController.h"
#import "EventListViewController.h"
#import "InboxViewController.h"
#import "MyGroupsViewController.h"
#import "UserPopupView.h"
#import <SDWebImageManager.h>
#import <Google/Analytics.h>
#import <GIBadgeView.h>


typedef void (^LoadingCompletitionBlock)(void);



#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define kSeguePinsDropDown @"pinsDropDownSegue"
#define kSegueSocialMenu    @"socialMenu"
#define kSegueVenusMenu     @"venusMenu"
#define kSegueConnectMenu   @"connectMenu"
#define kSegueCreateNewPin  @"createNewPin"
#define kSeguePinDetails    @"pinDetail"
#define kSegueTickets       @"tickets"
#define kSegueTicketDetail  @"ticketDetail"
#define kSegueAddressBook   @"addressBook"
#define kSegueLeaderboard   @"leaderboard"
#define kSegueMeetMe        @"meetme"
#define kSegueFavoriteList  @"favoriteList"
#define kSegueEventList  @"eventList"
#define kSegueMyGroups @"mygroupsVC"

#define kSBIndentifierFriendList  @"friendList"
#define kSBIndentifierProfileView  @"profileView"


#define kSnippetCurrentUser     @"CURRENT_USER"
#define kSnippetUser            @"USER"
#define kSnippetStadium         @"STADIUM"
#define kSnippetCity            @"CITY"
#define kSnippetPin             @"PIN"
#define kSnippetTicket          @"TICKET"

#define kMinZoomLevelForMarkers     6

@interface MapViewController ()<UITextFieldDelegate, PinsDropDownDelegate, GridMenuViewControllerDelegate, CreatePinViewControllerDelegate, InboxViewControllerDelegate, PinDetailsViewControllerDelegate> {
    NSString *strCountryName;
    NSString *strAddress;
    CLLocation *currentLocation;
    int zoomLevel;
}

@property (weak, nonatomic) IBOutlet UserPopupView *viewForPopupMan;

@property (weak, nonatomic) IBOutlet UIView *viewForPopup;
@property (weak, nonatomic) IBOutlet UITextField *tfDestination;
@property (weak, nonatomic) IBOutlet GMSMapView *viewMap;
@property (nonatomic, strong) NSArray *googleResult;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *viewSocial;
@property (weak, nonatomic) IBOutlet UIView *viewVenus;
@property (weak, nonatomic) IBOutlet UIView *viewConnect;
@property (weak, nonatomic) IBOutlet UIView *viewForAnchor;
@property (weak, nonatomic) IBOutlet UIView *viewForMeetMe;
@property (weak, nonatomic) IBOutlet UIView *viewForFavList;

@property (weak, nonatomic) IBOutlet UIButton *btnWithTicket;

@property (weak, nonatomic) IBOutlet UIView *pinsDropTableContainer;
@property (weak, nonatomic) PinsDropTableViewController *pinsDropTableVC;

@property (weak, nonatomic) UserAnnotation *currentUserAnnotation;
@property (strong, nonatomic) Pin *selectedPin;
@property (strong, nonatomic) Ticket *selectedTicket;
@property (strong, nonatomic) NSString *selectedPinType;
@property (strong, nonatomic) UIImage *createdChatPhoto;
@property (strong, nonatomic) NSString *menuType;


@property (nonatomic) BOOL searchActive;
@property (nonatomic) BOOL isShoudShowPopup;
@property (weak, nonatomic) IBOutlet UIView *commonPopupView;
@property (weak, nonatomic) IBOutlet UIView *ticketPopupView;
@property (weak, nonatomic) IBOutlet UIView *ticketDetailPopupView;

@property (weak, nonatomic) UIViewController *currentPopup;
@property (weak, nonatomic) UINavigationController *ticketNavigationController;
@property (strong, nonatomic) UIImage *selectedPinImage;

@property (strong, nonatomic) NSMutableSet *allPins;
@property (strong, nonatomic) NSMutableSet *allTickets;
@property (strong, nonatomic) NSMutableSet *allStadiums;
@property (strong, nonatomic) NSMutableSet *allCities;
@property (strong, nonatomic) NSMutableSet *allUsers;
@property (strong, nonatomic) NSMutableArray *allBarsPins;
@property (strong, nonatomic) NSMutableArray *allFansPins;
@property (strong, nonatomic) NSMutableArray *allTeams;
@property (strong, nonatomic) NSMutableArray *allMapMarkers;
@property (strong, nonatomic) NSSet *searchedMapObjects;
@property (strong, nonatomic) NSString *searchedSnippet;

@property (weak, nonatomic) UIButton *selectedBottomMenuButton;

@property (weak, nonatomic) IBOutlet UIButton *userScoreButton;

@property (strong, nonatomic) GMSMarker *currentUserMarker;

@property (weak, nonatomic) IBOutlet UILabel *lblFans;
@property (weak, nonatomic) IBOutlet UILabel *lblEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnEventsCount;
@property (weak, nonatomic) IBOutlet UIImageView *compass;
@property (weak, nonatomic) IBOutlet UIButton *btnInbox;
@property (nonatomic) GIBadgeView *badge;

// loading flags
@property (nonatomic) BOOL isUsersLoading;
@property (nonatomic) BOOL isPinsLoading;
@property (nonatomic) BOOL isTicketLoading;
@property (nonatomic) BOOL isStadiumLoading;
@property (nonatomic) BOOL isTeamsLoading;
@property (nonatomic) BOOL isCityLoading;
@property (nonatomic) BOOL isMoveToCoordinate;

@end

@implementation MapViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Map View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allMapMarkers = [NSMutableArray array];
    
    [self.lblFans setText:[NSString stringWithFormat:@"%d fans nearby", [self randomNumberBetween:100 maxNumber:350]]];
    [self.lblEvents setText:[NSString stringWithFormat:@"%d social events", [self randomNumberBetween:10 maxNumber:35]]];
    
    self.commonPopupView.hidden = YES;
    self.viewForPopupMan.hidden  = YES;
    self.pinsDropTableContainer.hidden = YES;
    //[self.pinsDropTableContainer setFrame:CGRectMake(100, 50, 150, 300)];
    zoomLevel = 12;
        
    double latitude = [Engine sharedEngine].settingManager.user.currentLatitude;
    double longitude = [Engine sharedEngine].settingManager.user.currentLongitude;
    BOOL isUserHasLocation = YES;
    
    if (latitude == 0 && longitude == 0) {
        isUserHasLocation = NO;
        latitude = 32.712679;
        longitude = -96.686155;
        zoomLevel = 6;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:zoomLevel];
    zoomLevel = 12;
    
    self.viewMap.camera = camera;
    self.viewMap.mapType = kGMSTypeNormal;
    self.viewMap.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    [self.locationManager startUpdatingHeading];
    
 //   NSLog(@"headingAvailable: %d", (int)[CLLocationManager headingAvailable]);
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = self;
    [self.viewForPopupMan addGestureRecognizer:tapGestureRecognizer];
    
    [self showInstructions];
    [self setupSearchField];
    [self setCurrentUserScore];
    _searchActive = FALSE;
    
    UIButton *btn = (UIButton *) [self.view viewWithTag:430];
    btn.layer.cornerRadius = 3.0;
    
    btn = (UIButton *) [self.view viewWithTag:278];
    btn.layer.cornerRadius = 3.0;
    
    btn = (UIButton *) [self.view viewWithTag:432];
    btn.layer.cornerRadius = 3.0;
    
    btn = (UIButton *) [self.view viewWithTag:275];
    btn.layer.cornerRadius = 3.0;
    
    btn = (UIButton *) [self.view viewWithTag:276];
    btn.layer.cornerRadius = 3.0;
    
    btn = (UIButton *) [self.view viewWithTag:277];
    btn.layer.cornerRadius = 3.0;
    
    self.compass.layer.cornerRadius = 20.0;
    
    _badge = [GIBadgeView new];
    [self.btnInbox addSubview:_badge];
//    if (isUserHasLocation) {
//        currentLocation = [[[Engine sharedEngine] settingManager].user getLocation];
//        
//        [self getAllPins:nil];
//        [self getAllTickets:nil];
//    }
//    
//    [self getAllUsers:nil];
//    [self getAllStadium:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self subscribeForNotifications:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingHeading];
    [self subscribeForNotifications:NO];
}

- (void)subscribeForNotifications:(BOOL)isSubscribe
{
    if (isSubscribe) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideTicketPopup:)
                                                     name:kNotificationHideTicketController
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideAnyPopup:)
                                                     name:kNotificationHidePopup
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationShowPinPopup object:nil];
        
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showPinDetail:)
                                                     name:kNotificationShowPinPopup
                                                   object:nil];
    }
}

#pragma mark - Setup method

- (void) showInstructions {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"kNewSignup"] isEqualToString:@"true"]) {
        
        [self removeInitialPopup];
        
        CGRect screenBounds = self.view.frame;
        screenBounds.size.height -= 56;

        UIView *instructView = [[UIView alloc] initWithFrame:screenBounds];
        [instructView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"instructions"]]];
        instructView.tag = 499;
        
        UITapGestureRecognizer *touchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeInitialPopup)];
        touchTap.delegate = self;
        [instructView addGestureRecognizer:touchTap];
        
        [self.view insertSubview:instructView aboveSubview:self.viewMap];
        [[self.view viewWithTag:274] setHidden:TRUE];
        [[self.view viewWithTag:275] setHidden:TRUE];
        [[self.view viewWithTag:276] setHidden:TRUE];
        [[self.view viewWithTag:277] setHidden:TRUE];
        [[self.view viewWithTag:278] setHidden:TRUE];
        [[self.view viewWithTag:279] setHidden:TRUE];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kNewSignup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
        [self showLoadingView];
}

- (void)setupSearchField
{
    [self.tfDestination addTarget:self action:@selector(searchRequestChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.tfDestination addTarget:self action:@selector(searchRequestBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    self.viewForPopupMan.hidden = YES;
    [self removePopup];
}


- (void)showLoadingView
{
    /*
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:progressHUB];
    progressHUB.tag = 100;
  //  progressHUB.mode = MBProgressHUDModeCustomView;
    UIView *customView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView *loadingImg = [[UIImageView alloc] init];
    UIImage *animatedPin = [UIImage animatedImageNamed:@"img-" duration:0.75];
    loadingImg.image = animatedPin;
    
    [customView addSubview:loadingImg];
    progressHUB.customView = customView;
    
    [progressHUB show:YES];
     */
    
    //Create the first status image and the indicator view
    UIImage *statusImage = [UIImage imageNamed:@"loading-1"];
    UIImageView *activityImageView = [[UIImageView alloc]
                                      initWithImage:statusImage];
    activityImageView.tag = 100;
    
    
    //Add more images which will be used for the animation
    activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"loading-1"],
                                         [UIImage imageNamed:@"loading-2"],
                                         [UIImage imageNamed:@"loading-3"],
                                         [UIImage imageNamed:@"loading-4"],
                                         nil];
    
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    activityImageView.animationDuration = 0.75;
    
    
    //Position the activity image view somewhere in
    //the middle of your current view
    activityImageView.frame = CGRectMake(
                                         0,
                                         0,
                                         statusImage.size.width, 
                                         statusImage.size.height);
    
    //Start the animation
    [activityImageView startAnimating];
    
    
    //Add your custom activity indicator to your current view
    [self.view addSubview:activityImageView];
}

- (void)hideLoadingView
{
    /*
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.navigationController.view viewWithTag:100];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
     */
    
    UIImageView *animatedView = (UIImageView *)[self.view viewWithTag:100];
    
    if (animatedView) {
        
        [animatedView removeFromSuperview];
    }
}

//#pragma mark - Map delgate
//
//- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
//{
//    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
//    [self removePopup];
//}

#pragma mark - IBActions

- (IBAction)clickSocial:(UIButton *)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self selectBottomButton:sender.selected == NO ? sender : nil];
    
    _menuType = kSegueSocialMenu;
    [self openPopupForView:self.viewSocial withSegueID:kSegueSocialMenu];
}

- (IBAction)clickVenus:(UIButton *)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self selectBottomButton:sender.selected == NO ? sender : nil];
    
    _menuType = kSegueVenusMenu;
    [self openPopupForView:self.viewVenus withSegueID:kSegueVenusMenu];
}
- (IBAction)clickConnect:(UIButton *)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self selectBottomButton:sender.selected == NO ? sender : nil];
    
    _menuType = kSegueConnectMenu;
    [self openPopupForView:self.viewConnect withSegueID:kSegueConnectMenu];
}

- (IBAction)clickChat:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self selectBottomButton:nil];
    [self removePopup];
    [self openLocalchatForStadium:nil];
}

- (IBAction)clickSetting:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self selectBottomButton:nil];
    [self removePopup];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"settingVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)clickBtnWithTicket:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    if (self.ticketPopupView.subviews.count > 0) {
        [self.ticketNavigationController removeFromParentViewController];
        [self.view sendSubviewToBack:self.ticketPopupView];
    } else {
        [self removePopup];
        self.isShoudShowPopup = YES;
        [self performSegueWithIdentifier:kSegueTickets sender:self];
    }
}

- (IBAction)clickSearchBtn:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    NSLog(@"Search clicked");
    [self.tfDestination resignFirstResponder];
    //searchBar.showsCancelButton = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.tfDestination.text forKey:@"address"];
    [params setObject:@"true" forKey:@"sensor"];
    
    [self showLoadingView];
    
    [DataHandler runApi:API_ROOT Params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideLoadingView];
        NSString *status = [responseObject valueForKeyPath:@"status"];
        if ([status isEqualToString:@"OK"]) {
            self.googleResult = [responseObject valueForKeyPath:@"results"];
            // show annotation on map with information obtained.
            NSMutableArray *array;
            CLLocationCoordinate2D coord;
            NSDictionary *addressDictionary;
            array = [[NSMutableArray alloc] init];
            for (id result in self.googleResult) {
                coord = [self coordinateFromJSON:result];
                addressDictionary = [self addressDictionaryFromJSON:result];
            }
            
            
            NSLog(@"%f %f", coord.latitude, coord.longitude);
            NSLog(@"%@", addressDictionary);
            
            MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:coord];
//            [self.viewMap addAnnotation:mapPoint];
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.1;
            span.longitudeDelta = 0.1;
            CLLocationCoordinate2D location;
            location.latitude = coord.latitude;
            location.longitude = coord.longitude;
            
            region.span = span;
            region.center = location;
//            [self.viewMap setRegion:region animated:YES];
            
            strCountryName = [addressDictionary objectForKey:@"Country"];
            strAddress = [addressDictionary objectForKey:@"FormattedAddressLines"];
            
            
            
        }else{
            self.tfDestination.text = @"";
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self hideLoadingView];
        self.tfDestination.text = @"";
        
    }];

}

- (IBAction)clickBtnCan:(id)sender {
}

- (IBAction)clickCommonPopupCloseBtn:(id)sender {
    NSLog(@"clicking here");
    [self removePopup];
}


- (void)searchRequestChanged:(UITextField *)textFiled
{
    if (textFiled.text.length > 0) {
        
        if ([self.view viewWithTag:555] == nil) {
            
            UIView *topWhite = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
            topWhite.tag = 555;
            topWhite.backgroundColor = [UIColor whiteColor];
            [self.view insertSubview:topWhite aboveSubview:self.viewMap];
        }
        
        self.pinsDropTableContainer.hidden = NO;
        self.pinsDropTableContainer.backgroundColor = [UIColor clearColor];
        
    }
    else {
        
        if ([self.view viewWithTag:555] != nil)
            [[self.view viewWithTag:555] removeFromSuperview];
            
        self.pinsDropTableContainer.hidden = YES;
        self.pinsDropTableContainer.backgroundColor = [UIColor clearColor];
    }
    
    if (self.pinsDropTableVC) {
        self.pinsDropTableVC.searchString = textFiled.text;
    }
}

- (void)searchRequestBeginEditing:(UITextField *)textFiled
{
    if (textFiled.text.length > 0) {
    /*
        if ([self.view viewWithTag:555] == nil) {
            
            UIView *topWhite = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
            topWhite.tag = 555;
            topWhite.backgroundColor = [UIColor whiteColor];
            [self.view insertSubview:topWhite aboveSubview:self.viewMap];
        }*/
        
        self.pinsDropTableContainer.hidden = NO;
        self.pinsDropTableContainer.backgroundColor = [UIColor clearColor];
    }
    else {
      /*
        if ([self.view viewWithTag:555] != nil)
            [[self.view viewWithTag:555] removeFromSuperview];
*/
        
        self.pinsDropTableContainer.hidden = YES;
        self.pinsDropTableContainer.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark uisearchbar delegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
}

- (CLLocationCoordinate2D)coordinateFromJSON:(id)JSON
{
    NSDictionary *location = [[JSON valueForKey:@"geometry"] valueForKey:@"location"];
    NSNumber *lat = [location valueForKey:@"lat"];
    NSNumber *lng = [location valueForKey:@"lng"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    return coord;
}

- (NSDictionary *)addressDictionaryFromJSON:(id)JSON
{
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    addressDictionary[@"FormattedAddressLines"] = (NSString *)[JSON valueForKey:@"formatted_address"];
    for (id component in [JSON valueForKey:@"address_components"]) {
        NSArray *types = [component valueForKey:@"types"];
        id longName = [component valueForKey:@"long_name"];
        id shortName = [component valueForKey:@"short_name"];
        for (NSString *type in types) {
            if ([type isEqualToString:@"postal_code"]) {
                addressDictionary[@"ZIP"] = longName;
            }
            else if ([type isEqualToString:@"country"]) {
                addressDictionary[@"Country"] = longName;
                addressDictionary[@"CountryCode"] = shortName;
            }
            else if ([type isEqualToString:@"administrative_area_level_1"]) {
                addressDictionary[@"State"] = longName;
            }
            else if ([type isEqualToString:@"administrative_area_level_2"]) {
                addressDictionary[@"SubAdministrativeArea"] = longName;
            }
            else if ([type isEqualToString:@"locality"]) {
                addressDictionary[@"City"] = longName;
            }
            else if ([type isEqualToString:@"sublocality"]) {
                addressDictionary[@"SubLocality"] = longName;
            }
            else if ([type isEqualToString:@"establishment"]) {
                addressDictionary[@"Name"] = longName;
            }
            else if ([type isEqualToString:@"route"]) {
                addressDictionary[@"Thoroughfare"] = longName;
            }
            else if ([type isEqualToString:@"street_number"]) {
                addressDictionary[@"SubThoroughfare"] = longName;
            }
        }
    }
    return addressDictionary;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.tfDestination) {
        [self removePopup];
        [self performSegueWithIdentifier:kSeguePinsDropDown sender:self];
        self.pinsDropTableContainer.hidden = NO;
        [self.view bringSubviewToFront:self.pinsDropTableContainer];
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.tfDestination) {
        self.pinsDropTableContainer.hidden = YES;
        [self.pinsDropTableVC.view removeFromSuperview];
        [self.pinsDropTableVC removeFromParentViewController];
        [self.view sendSubviewToBack:self.pinsDropTableContainer];
//        [[self.view viewWithTag:555] removeFromSuperview];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.tfDestination) {
        textField.text = nil;
        _searchActive = FALSE;
        
        if (!self.isMoveToCoordinate) {
            
            [_viewMap clear];
            self.currentUserMarker = nil;
            [self updateAnnotationForCurrentUser];
            [self updateMapMarkersWithCoordBounds:[self currentCoordinateBounds]];
            [self ZoomOut:nil];
        
        }
        
        [[self.view viewWithTag:555] removeFromSuperview];

    }
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
    NSLog(@"Zoom leve: %f", mapView.camera.zoom);
    
    if (mapView.camera.zoom <= kMinZoomLevelForMarkers) {
        
        zoomLevel = kMinZoomLevelForMarkers;
        [self.viewMap animateToZoom:zoomLevel];
    }
        
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    GMSCoordinateBounds *coordsBounds = [self currentCoordinateBounds];
    NSLog(@"map moving");
    
    if (!_searchActive)
        [self removeUnvisibleMarkers:coordsBounds];
    
    if (_searchActive) {
        [self refreshMapMarkersWithCoordBounds:coordsBounds withSet:_searchedMapObjects withSnippet:_searchedSnippet clearPins:FALSE];
    }
    else {
        [self updateMapMarkersWithCoordBounds:coordsBounds];
    }
}



- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"Tapping on marker %@", marker.snippet);
    
    if ([marker.snippet isEqualToString:kSnippetPin])
        [self openPinDetail:marker.userData];
    else if ([marker.snippet isEqualToString:kSnippetTicket])
        [self openTicketDetails:marker.userData];
    else if ([marker.snippet isEqualToString:kSnippetStadium])
        [self loadLoadchatsForStadium:marker.userData];
//    else if ([marker.snippet isEqualToString:kSnippetUser])
//        [self openUserDetailPopup:marker.userData];

    
    return TRUE;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



#pragma mark CLLocationDelegate Methods
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!:(");
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    [Engine sharedEngine].settingManager.user.currentLatitude = newLocation.coordinate.latitude;
    [Engine sharedEngine].settingManager.user.currentLongitude = newLocation.coordinate.longitude;
    [[Engine sharedEngine].settingManager saveUser];
    
    GMSCoordinateBounds *coordsBounds = [self currentCoordinateBounds];

    [self updateAnnotationForCurrentUser];
    
    LoadingCompletitionBlock loadTeams = ^{
        if (self.allTeams.count == 0 && !self.isTeamsLoading) {
            NSLog(@"get all teams");
            [self getAllTeams:nil];
        }
        else
            NSLog(@"teams not loading");
    };
    
    LoadingCompletitionBlock loadStadiums = ^{
        if (self.allStadiums.count == 0 && !self.isStadiumLoading) {
            NSLog(@"get all stadiums");
            [self getAllStadium:coordsBounds completition:nil];
        } else {
            loadTeams();
        }
    };
    
    LoadingCompletitionBlock loadCities = ^{
        if (self.allCities.count == 0 && !self.isCityLoading) {
            NSLog(@"get all cities");
            [self getAllCities:coordsBounds completition:nil];
        } else {
            loadStadiums();
        }
    };
 /*
    LoadingCompletitionBlock loadUsers = ^{
        if (self.allUsers.count == 0 && !self.isUsersLoading) {
            NSLog(@"get all users");
            [self getAllUsers:coordsBounds completition:loadStadiums];
        } else {
            loadCities();
        }
    };
  */
  /*
    LoadingCompletitionBlock loadTickers = ^{
        if (self.allTickets.count == 0 && !self.isTicketLoading) {
            NSLog(@"get all tickets");
            [self getAllTickets:coordsBounds completition:loadUsers];
        } else {
            loadUsers();
        }
    };
    */
    LoadingCompletitionBlock loadPins = ^{
        if (self.allPins.count == 0 && !self.isPinsLoading) {
            NSLog(@"get all pins");
            //[self getAllPins:coordsBounds completition:loadCities];
        } else {
            //loadCities();
        }
    };
    
    loadPins();
    
  /*  NSMutableArray *allSearchItems = [NSMutableArray arrayWithArray:[self.allPins allObjects]];
    NSMutableArray *allBars = [[NSMutableArray alloc] init];
    
    for (int i=0; i<allSearchItems.count; i++) {
        
        Pin *bar_pin = (Pin *)[allSearchItems objectAtIndex:i];
        if ([[bar_pin getMarkerType] isEqualToString:@"Beer"]) {

            if (![bar_pin.mapPinTags isEqualToString:@""] && ![bar_pin.mapPinTags isEqualToString:@"(null)"] && bar_pin.mapPinTags != nil && ![bar_pin.mapPinTags isEqual:[NSNull null]])
                bar_pin.mapPinTitle = [NSString stringWithFormat:@"%@ Bars", bar_pin.mapPinTags];
            
            if (![allBars containsObject:bar_pin])
                [allBars addObject:bar_pin];
        }
    }
    
    self.allBarsPins = [NSMutableSet setWithArray:allBars];
   */
    
    [[[Engine sharedEngine] dataManager] updateuserLocation:currentLocation withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSArray *info_array = [result componentsSeparatedByString:@";"];
            NSString *event_count = info_array[0];
            NSString *unread_count = info_array[1];
            
            [self.btnEventsCount setTitle:event_count forState:UIControlStateNormal];
            self.badge.badgeValue = [unread_count integerValue];
        }
    }];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    float heading = newHeading.magneticHeading; //in degrees
    float headingDegrees = (heading*M_PI/180); //assuming needle points to top of iphone. convert to radians
    self.compass.transform = CGAffineTransformMakeRotation(headingDegrees);
}

#pragma mark - Users
- (void)getAllUsers:(GMSCoordinateBounds *) coordBounds completition:(LoadingCompletitionBlock)completition
{
    self.isUsersLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllUsersWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSSet *newUsers = [NSSet setWithArray:result];
            
            if (!self.allUsers) {
                self.allUsers = [NSMutableSet setWithSet:newUsers];
            } else {
                [self.allUsers unionSet:newUsers];
            }
           
            [self updateMapObjects:self.allUsers withSnippet:kSnippetUser inCoordBounds:coordBounds];
            
            if (completition) {
                completition();
            }
        } else {
            [self showErrorMessage:errorInfo];
            if (completition) {
                completition();
            }
        }
        self.isUsersLoading = NO;
    }];
}

- (void)updateAnnotationForCurrentUser
{
    User *currentUser = [[[Engine sharedEngine] settingManager] user];
    
    if (currentUser) {
        if (!self.currentUserMarker) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(currentUser.currentLatitude, currentUser.currentLongitude);
            marker.userData = currentUser;
            marker.snippet = kSnippetCurrentUser;
            
            UIImage *animatedPin = [UIImage animatedImageNamed:@"img-" duration:0.75];
            marker.icon = animatedPin;
            marker.map = self.viewMap;
            
            self.currentUserMarker = marker;
        } else {
            [CATransaction begin];
            [CATransaction setAnimationDuration:2.0];
            self.currentUserMarker.position = [currentUser getLocation].coordinate;
            [CATransaction commit];
        }
    }
    else
        NSLog(@"No User");
}

- (void)openUserDetailPopup:(User *)user
{
    self.viewForPopupMan.hidden = NO;
    self.viewForPopupMan.user = user;
}

- (void)setCurrentUserScore
{
    NSInteger score = [Engine sharedEngine].settingManager.user.profilePoints;
    [self.userScoreButton setTitle:[NSString stringWithFormat:@"%zd",score] forState:UIControlStateNormal];
}

#pragma mark - Pins

- (void)getAllPins:(GMSCoordinateBounds *) coordBounds completition:(LoadingCompletitionBlock)completition
{
//    [self showLoadingView];
    self.isPinsLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllPinsForLocation:currentLocation withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSSet *newPins = [NSSet setWithArray:result];
            
            if (!self.allPins) {
                self.allPins = [NSMutableSet setWithSet:newPins];
            } else {
                [self.allPins unionSet:newPins];
            }
            
            [self updateMapObjects:self.allPins withSnippet:kSnippetPin inCoordBounds:coordBounds];
            
            if (completition) {
                completition();
            }
            
        } else {
            [self showErrorMessage:errorInfo];
            
            if (completition) {
                completition();
            }
        }
        self.isPinsLoading = NO;
    }];
}

- (void)addPinMarkerToMap:(Pin *)pin
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(pin.mapPinLatitude, pin.mapPinLongitude);
    marker.userData = pin;
    marker.snippet = kSnippetPin;
    
    UIImage* image = [pin pinImage];
    marker.icon = image;
    
    marker.map = self.viewMap;
}

- (NSString *)pinTypeForButtonTag:(NSInteger)tag
{
    NSInteger index = tag - 1;
    NSArray *pinTypes = @[@"Tailgate",
                          @"Partying",
                          @"Game Showing",
                          @"Playing",
                          @"Watch Party",
                          @"Celebrity",
                          @"Music",
                          @"Meetup",
                          @"Treasure",
                          @"Food & Drinks",
                          @"Medical Care",
                          @"Apparel",
                          @"Police",
                          @"Parking",
                          @"Beer",
                          @"Taxi",
                          @"Broadcast",
                          @"Rickshaw",
                          @"Restroom",
                          @"Entry Exit",
                          @"Note",
                          @"Uber",
                          @"Parking Full",
                          @"Parking Available",
                          @"Ticket",
                          @"Zombie"];
    
    if (index >= 0 && index < pinTypes.count) {
        NSString *pinType = [pinTypes objectAtIndex:index];
        return pinType;
    }
    
    return nil;
}

- (void)openPinDetail:(Pin *)pin
{
    NSLog(@"Openning pin");
    self.selectedPin = pin;
    
    [self openPopupForView:self.viewForPopup withSegueID:kSeguePinDetails];
}

- (void)showPinDetail:(NSNotification *)notification
{
    NSLog(@"Openning pin");
    NSDictionary* userInfo = notification.userInfo;
    Pin *pin = (Pin *)userInfo[@"pin"];
    self.selectedPin = pin;
    
    [self openPopupForView:self.viewForPopup withSegueID:kSeguePinDetails];
}


- (void)getSearchPins:(GMSCoordinateBounds *) coordBounds team:(NSString *)team pintype:(NSString *)pinType completition:(LoadingCompletitionBlock)completition
{
    
     [self updateMapObjectsWithSearchPins:self.allPins withSnippet:kSnippetPin inCoordBounds:coordBounds withPinType:pinType ofTeam:team];
}

- (void)getAllFans:(GMSCoordinateBounds *)coordBounds team:(NSString *)team completition:(LoadingCompletitionBlock)completition
{
    [self updateMapObjectsWithFans:self.allUsers withSnippet:kSnippetUser inCoordBounds:coordBounds ofFans:team];
}

#pragma mark - Tickets

- (void)getAllTickets:(GMSCoordinateBounds *) coordBounds completition:(LoadingCompletitionBlock)completition
{
    self.isTicketLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllTicketsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSSet *newTickets = [NSSet setWithArray:result];
            
            if (!self.allTickets) {
                self.allTickets = [NSMutableSet setWithSet:newTickets];
            } else {
                [self.allTickets unionSet:newTickets];
            }
            
            [self updateMapObjects:self.allTickets withSnippet:kSnippetTicket inCoordBounds:coordBounds];
            
            if (completition) {
                completition();
            }
            
        } else {
            [self showErrorMessage:errorInfo];
            
            if (completition) {
                completition();
            }
        }
        self.isTicketLoading = NO;
    }];
}

- (void)openTicketDetails:(Ticket *)ticket
{
    [self removePopup];
    self.isShoudShowPopup = YES;
    self.selectedTicket = ticket;
    
    [self performSegueWithIdentifier:kSegueTicketDetail sender:self];
}

#pragma mark - Stadium

- (void)getAllStadium:(GMSCoordinateBounds *) coordBounds completition:(LoadingCompletitionBlock)completition
{
    self.isStadiumLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllStadiumsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSSet *newStadiums = [NSSet setWithArray:result];
            
            if (!self.allStadiums) {
                self.allStadiums = [NSMutableSet setWithSet:newStadiums];
            } else {
                [self.allStadiums unionSet:newStadiums];
            }
            
            [self updateMapObjects:self.allStadiums withSnippet:kSnippetStadium inCoordBounds:coordBounds];
            
            if (completition) {
                completition();
            }
        } else {
            [self showErrorMessage:errorInfo];
            
            if (completition) {
                completition();
            }
        }
        self.isStadiumLoading = NO;
    }];    
}

- (void)loadLoadchatsForStadium:(Stadium *)stadium
{
    [self openLocalchatForStadium:stadium];
}

#pragma mark - City

- (void)getAllCities:(GMSCoordinateBounds *) coordBounds completition:(LoadingCompletitionBlock)completition
{
    self.isCityLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllCitiesWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSSet *newCities = [NSSet setWithArray:result];
            
            if (!self.allCities) {
                self.allCities = [NSMutableSet setWithSet:newCities];
            } else {
                [self.allCities unionSet:newCities];
            }
            
            if (completition) {
                completition();
            }
        } else {
            [self showErrorMessage:errorInfo];
            
            if (completition) {
                completition();
            }
        }
        self.isCityLoading = NO;
    }];
}

#pragma mark - Teams

- (void)getAllTeams:(LoadingCompletitionBlock)completition
{
    
    NSMutableArray *listTeams = [[NSMutableArray alloc] init];
    self.allBarsPins = [[NSMutableArray alloc] init];
    
    self.isTeamsLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"ALL Teams teams %@",result);
            
            NSMutableArray *teams = [result mutableCopy];
            
            for (int i=0; i < [teams count]; i++) {
                
                Team *t = (Team *)[teams objectAtIndex:i];
                t.type = @"Beer";
                [self.allBarsPins addObject:t];
            }
          /*
            NSMutableArray *teamsBeer = [result mutableCopy];
            
            for (int i=0; i < [teamsBeer count]; i++) {
                
                Team *t = (Team *)[teamsBeer objectAtIndex:i];
                t.type = @"Beer";
                [listTeams addObject:t];
                
            }
           
            NSMutableArray *teamsParty = [result mutableCopy];
            
            for (int i=0; i < [teamsParty count]; i++) {
                
                Team *t = (Team *)[teamsParty objectAtIndex:i];
                t.type = @"Watch Party";
                [listTeams addObject:t];
            }
           */
        }
        
        self.isTeamsLoading = NO;
        
    }];
  
  /*  self.isTeamsLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {

            NSMutableArray *teamsBeer = (NSMutableArray *)result;

            for (int i=0; i < [teamsBeer count]; i++) {
                
                Team *t = (Team *)[teamsBeer objectAtIndex:i];
                t.type = @"Beer";
                [self.allBarsPins addObject:t];
                
            }
        }
        
        self.isTeamsLoading = NO;
    }];
   */
    
    
    self.isTeamsLoading = YES;
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {

            NSMutableArray *teamsParty = (NSMutableArray *)result;
            
            for (int i=0; i < [teamsParty count]; i++) {
                
                Team *t = (Team *)[teamsParty objectAtIndex:i];
                t.type = @"Watch Party";
                [listTeams addObject:t];
            }
        }
        
        [self hideLoadingView];
        self.isTeamsLoading = NO;
    }];
    
    self.allTeams = listTeams;
    
}

#pragma mark - Navigations

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kSeguePinsDropDown]) {
        if ([self.tfDestination isFirstResponder]) {
            return YES;
        }
        return NO;
    } else {
        NSArray *popupsSegues = @[kSegueSocialMenu, kSegueVenusMenu, kSegueConnectMenu, kSegueCreateNewPin, kSeguePinDetails, kSegueTickets, kSegueTicketDetail];
        if ([popupsSegues containsObject:identifier]) {
            if (self.isShoudShowPopup) {
                self.isShoudShowPopup = NO;
                return YES;
            } else {
                return NO;
            }
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueLeaderboard]) {
      //  LeaderboardViewController *nextVC = (LeaderboardViewController *)segue.destinationViewController;
      //  nextVC.users = [self.allUsers allObjects];
    } else if ([segue.identifier isEqualToString:kSeguePinsDropDown]) {
        self.pinsDropTableVC = segue.destinationViewController;
        self.pinsDropTableVC.pinsDelegate = self;
        
        NSMutableArray *allSearchItems = [NSMutableArray arrayWithArray:[self.allStadiums allObjects]];
        [allSearchItems addObjectsFromArray:[self.allCities allObjects]];
        [allSearchItems addObjectsFromArray:self.allBarsPins];
        [allSearchItems addObjectsFromArray:self.allTeams];
        
        self.pinsDropTableVC.citiesItems = [NSMutableArray arrayWithArray:[self.allCities allObjects]];
        self.pinsDropTableVC.venueItems = [NSMutableArray arrayWithArray:[self.allStadiums allObjects]];
        self.pinsDropTableVC.barsItems =  self.allBarsPins;
        self.pinsDropTableVC.socialItems = self.allTeams;
        

        self.pinsDropTableVC.items = allSearchItems;
        
    } else if ([segue.identifier isEqualToString:kSegueTickets]) {
        self.ticketNavigationController = segue.destinationViewController;
        self.ticketPopupView.hidden = NO;
        [self.view bringSubviewToFront:self.ticketPopupView];
        
    } else if ([segue.identifier isEqualToString:kSegueTicketDetail]) {
        self.ticketNavigationController = segue.destinationViewController;
        
        UIViewController *visibleController = [self.ticketNavigationController visibleViewController];
        
        if ([visibleController isKindOfClass:[BuyTicketDetailViewController class]]) {
            BuyTicketDetailViewController *ticketDetailVC = (BuyTicketDetailViewController *)visibleController;
            ticketDetailVC.ticket = self.selectedTicket;
        }
        
        self.ticketDetailPopupView.hidden = NO;
        [self.view bringSubviewToFront:self.ticketDetailPopupView];
        
    } else {
        NSArray *popupsSegues = @[kSegueSocialMenu, kSegueVenusMenu, kSegueConnectMenu, kSegueCreateNewPin, kSeguePinDetails, kSegueTicketDetail];
        if ([popupsSegues containsObject:segue.identifier]) {
            [self removePopup];
            
            if ([segue.identifier isEqualToString:kSegueCreateNewPin]) {
                CreatePinViewController *popupVC = segue.destinationViewController;
                popupVC.pinType = self.selectedPinType;
                popupVC.pinImage = self.selectedPinImage;
                popupVC.menuType = self.menuType;
                popupVC.delegate = self;

            } else if ([segue.identifier isEqualToString:kSeguePinDetails]) {
                PinDetailsViewController *popup = segue.destinationViewController;
                popup.delegate = self;
                popup.pin = self.selectedPin;
                
            }  else {
                GridMenuViewController *popupVC = segue.destinationViewController;
                popupVC.delegate = self;                
            }
            
            self.currentPopup = segue.destinationViewController;
            self.commonPopupView.hidden = NO;
        }
    }
}

#pragma mark - Favorite List

- (IBAction)openFavoriteList:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoriteListViewController *favoriteVC = [storyboard instantiateViewControllerWithIdentifier:@"favoriteList"];
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

#pragma mark - PinsDropDownDelegate

- (void)pinsTableView:(PinsDropTableViewController *)pinsTableVIew didSelectPin:(id<SearchItem>)pin
{
    [self.tfDestination resignFirstResponder];
    
    if ([self.view viewWithTag:555] != nil)
        [[self.view viewWithTag:555] removeFromSuperview];
    
    self.isMoveToCoordinate = FALSE;
    
    NSString *pintype = [pin getPinType];
    if ([pintype isEqualToString:@"Beer"]) {
        
        self.tfDestination.text = [NSString stringWithFormat:@"%@ Bars", [pin getSearchTitle]];
        GMSCoordinateBounds *coordsBounds = [self currentCoordinateBounds];
        [self getSearchPins:coordsBounds team:[pin getSearchTitle] pintype:pintype completition:nil];
    }
    else if ([pintype isEqualToString:@"Watch Party"]) {
        
        self.tfDestination.text = [NSString stringWithFormat:@"%@ Watch Party", [pin getSearchTitle]];
        GMSCoordinateBounds *coordsBounds = [self currentCoordinateBounds];
        [self getSearchPins:coordsBounds team:[pin getSearchTitle] pintype:pintype completition:nil];
    }
    else if ([pintype isEqualToString:@"Fan"]) {
        
        self.tfDestination.text = [NSString stringWithFormat:@"%@ Fans", [pin getSearchTitle]];
        GMSCoordinateBounds *coordsBounds = [self currentCoordinateBounds];
        [self getAllFans:coordsBounds team:[pin getSearchTitle] completition:nil];
    }
    else {
        
        self.isMoveToCoordinate = TRUE;
        
        if ([pintype isEqualToString:@"Stadium"])
            zoomLevel = 16;
        else if ([pintype isEqualToString:@"City"])
            zoomLevel = 13;
        
        self.tfDestination.text = [pin getSearchTitle];
        CLLocationCoordinate2D coord = [pin getLocation].coordinate;
        [self moveToCoordinate:coord];
        
    }
    
    
}

#pragma mark - PinDetailsViewControllerDelegate

- (void)removePin:(PinDetailsViewController *)pinDetailsVC withPin:(Pin *)pin {
    
    [self.allPins removeObject:pin];    
    for (int i=0; i<self.allMapMarkers.count; i++) {
        
        GMSMarker *selectedMarker = [self.allMapMarkers objectAtIndex:i];
        
        if (selectedMarker.position.latitude == [pin getLocationCoordinate].latitude && selectedMarker.position.longitude == [pin getLocationCoordinate].longitude) {
            NSLog(@"Got marker");
            [self.allMapMarkers removeObjectAtIndex:i];
            selectedMarker.map = nil;
        }
    }
    
    [self removePopup];
}

#pragma mark - GridMenuViewControllerDelegate

- (void)gridMenu:(GridMenuViewController *)gridMenuVC didTapOnButton:(UIButton *)sender
{
    NSInteger btnID = [sender tag];
    
    [self selectBottomButton:nil];
    
    self.selectedPinImage = [sender backgroundImageForState:UIControlStateNormal];
    self.selectedPinType = [self pinTypeForButtonTag:btnID];
    
    if (self.selectedPinType) {
        self.viewForPopupMan.hidden = NO;
        self.commonPopupView.hidden = NO;
        [self openPopupForView:self.viewForAnchor withSegueID:kSegueCreateNewPin];
    }    
}

- (void)gridMenu:(GridMenuViewController *)gridMenuVC didTapOnUniqueButton:(UIButton *)button withID:(NSString *)uniqueID
{
    NSLog(@"Segue is: %@", uniqueID);
    if ([uniqueID isEqualToString:kLeaderboard]) {
        [self performSegueWithIdentifier:kSegueLeaderboard sender:self];
    } else if ([uniqueID isEqualToString:kMeetMe]) {
        [self selectBottomButton:nil];
        [self openFullScreenPopupForView:self.viewForMeetMe];
    } else if ([uniqueID isEqualToString:kSBIndentifierFriendList]) {
        [self selectBottomButton:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FriendListViewController *friendVC = [storyboard instantiateViewControllerWithIdentifier:kSBIndentifierFriendList];
        friendVC.fromFriendList = YES;
        [self.navigationController pushViewController:friendVC animated:NO];
    } else if ([uniqueID isEqualToString:kSBIndentifierProfileView]) {
        [self selectBottomButton:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:kSBIndentifierProfileView];
        [self.navigationController pushViewController:profileVC animated:NO];
    } else if ([uniqueID isEqualToString:kMyGroups]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyGroupsViewController *mygroupsVC = [storyboard instantiateViewControllerWithIdentifier:kMyGroups];
        [self.navigationController pushViewController:mygroupsVC animated:NO];
    }
}

- (void)gridMenuDidTapBackground:(GridMenuViewController *)gridMenuVC
{
    [self removePopup];
    
    self.selectedBottomMenuButton.selected = NO;
    self.selectedBottomMenuButton = nil;
}

#pragma mark - CreatePinViewControllerDelegate

- (void)createPinViewController:(CreatePinViewController *)pinVC didAddPin:(Pin *)pin
{
    [self removePopup];
    [self.allPins addObject:pin];
    
    [self updateMapObjects:self.allPins withSnippet:kSnippetPin inCoordBounds:[self currentCoordinateBounds]];
}

- (void)createPinViewControllerFailureToAddPin:(CreatePinViewController *)pinVC
{
    [self removePopup];
    
    [self showErrorMessage:@"Sorry, can't create this pin"];
}

- (void)createPinViewController:(CreatePinViewController *)pinVC wantShareViaFB:(BOOL)isFB viaTwitter:(BOOL)isTwitter withPin:(Pin *)pin
{
    if (isFB) {
        [[[Engine sharedEngine] shareManager] postToFacebookWithPin:pin callback:^(BOOL success, NSString *errorMessage) {
            if (!success && errorMessage) {
                [self showErrorMessage:errorMessage];
            }
        }];
    }
    
    if (isTwitter) {
        
        if (![[[Engine sharedEngine] shareManager] isTwitterConnected]) {
            
            [[[Engine sharedEngine] shareManager] requireTwitterPermisionsWithCallBack:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    [[[Engine sharedEngine] shareManager] isTwitterConnected];
                } else if (errorMessage) {
                    [self showErrorMessage:errorMessage];
                }
            }];
            
        } else {
            
            [[[Engine sharedEngine] shareManager] postToTwitterWithPin:pin callback:^(BOOL success, NSString *errorMessage) {
                if (!success && errorMessage) {
                    [self showErrorMessage:errorMessage];
                }
            }];
        }
    }
}

- (void)createPinViewController:(CreatePinViewController *)pinVC wantInviteFriends:(NSArray *)usersToInvite withPin:(Pin *)pin
{
    if (usersToInvite.count > 0) {
        [[[Engine sharedEngine] shareManager] inviteUsers:usersToInvite forPin:pin fromController:self];
    }
}

#pragma mark - Inbox Delegate

-(void)inboxViewController:(InboxViewController *)inboxViewController withLatitude:(double)latitude withLongitude:(double)longitude {
    
    NSLog(@"Loc coord: %f, %f", latitude, longitude);
    zoomLevel = 18;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    [self moveToCoordinate:location];
}


#pragma mark - Helpers

- (void)moveToCoordinate:(CLLocationCoordinate2D)coordinate
{

    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:zoomLevel];
    [self.viewMap animateToBearing:0];
    [self.viewMap animateWithCameraUpdate:updatedCamera];
}

- (void) removeInitialPopup {
    
    [[self.view viewWithTag:776] removeFromSuperview];
    [[self.view viewWithTag:777] removeFromSuperview];
    [[self.view viewWithTag:499] removeFromSuperview];
    
    [[self.view viewWithTag:274] setHidden:FALSE];
    [[self.view viewWithTag:275] setHidden:FALSE];
    [[self.view viewWithTag:276] setHidden:FALSE];
    [[self.view viewWithTag:277] setHidden:FALSE];
    [[self.view viewWithTag:278] setHidden:FALSE];
    [[self.view viewWithTag:279] setHidden:FALSE];
}

- (void)removePopup
{
    self.viewForPopupMan.hidden = YES;
    [self hideFullScreenPopupForView:self.viewForMeetMe];
    
    if (!self.viewForFavList.hidden)
        [self hideFullScreenPopupForView:self.viewForFavList];
    
    if (self.currentPopup) {
        [self.currentPopup.view removeFromSuperview];
        [self.currentPopup removeFromParentViewController];
        self.commonPopupView.hidden = YES;
    }
}

- (void)openPopupForView:(UIView *)view withSegueID:(NSString *)segueID
{
    NSLog(self.commonPopupView.hidden ? @"Yes" : @"No");
    if (self.currentPopup && view.subviews.count > 0) {
        [self removePopup];
    } else {
        self.isShoudShowPopup = YES;
        [self.commonPopupView bringSubviewToFront:view];
        [self.view bringSubviewToFront:self.commonPopupView];
        [self.commonPopupView bringSubviewToFront:[self.commonPopupView viewWithTag:87]];
        [self performSegueWithIdentifier:segueID sender:self];
    }
}

- (void)openFullScreenPopupForView:(UIView *)view
{
    view.hidden = NO;
    [self.view bringSubviewToFront:view];
}

- (void)hideFullScreenPopupForView:(UIView *)view
{
    view.hidden = YES;
    [self.view sendSubviewToBack:view];
}

- (void)openLocalchatForStadium:(Stadium *)stadium
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"chatVC"];
    VC.stadium = stadium;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)selectBottomButton:(UIButton *)button
{
    self.selectedBottomMenuButton.selected = NO;
    
    if (button) {
        self.selectedBottomMenuButton = button;
        self.selectedBottomMenuButton.selected = YES;
    } else {
        self.selectedBottomMenuButton = nil;
    }
}

- (void)setImageForMarker:(GMSMarker *)marker iconURL:(NSString *)iconURL
{
    if (iconURL.length > 0) {
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:iconURL];
        
        if (cachedImage) {
            UIImage *icon = [self imageWithImage:cachedImage scaledToSize:CGSizeMake(30, 30)];
            marker.icon = icon;
            return;
        }
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:iconURL]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:nil
                                                            completed:
         ^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
             if (image && finished) {
                 UIImage *icon = [self imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
                 [[SDImageCache sharedImageCache] storeImage:icon forKey:iconURL toDisk:YES];
                 marker.icon = icon;
             }
         }];
    }
}

- (void)removeUnvisibleMarkers:(GMSCoordinateBounds *) coordBounds
{
    NSArray *tmpArray = [self.allMapMarkers copy];
    
    CGFloat currentZoomLevel = self.viewMap.camera.zoom;
   // BOOL isToFarForMarker = currentZoomLevel <= kMinZoomLevelForMarkers;
    
    for (GMSMarker *marker in tmpArray) {
        BOOL isOutside = ![coordBounds containsCoordinate:marker.position];
        BOOL isStadium = [marker.snippet isEqualToString:kSnippetStadium];
        BOOL isUser = [marker.snippet isEqualToString:kSnippetUser];
        BOOL isPin = [marker.snippet isEqualToString:kSnippetPin];
        
        
        if (isOutside && !isStadium) {
            
            marker.map = nil;
            [self.allMapMarkers removeObject:marker];
        }
        else if (currentZoomLevel < 7 && isUser) {
          
            marker.map = nil;
            [self.allMapMarkers removeObject:marker];
        }
        else if (isPin) {
            
            id<MapMarkerItem> mapObject = marker.userData;
            
            if (currentZoomLevel < 9) {
                
                    marker.map = nil;
                    [self.allMapMarkers removeObject:marker];
            }
            else {
                
                NSString *markerType = [mapObject getMarkerType];
                
                if (currentZoomLevel < 14 && ([markerType isEqualToString:@"Rickshaw"] || [markerType isEqualToString:@"Taxi"] || [markerType isEqualToString:@"Medical Care"] || [markerType isEqualToString:@"Meetup"] || [markerType isEqualToString:@"Playing"])) {
                    
                        marker.map = nil;
                        [self.allMapMarkers removeObject:marker];
                }
                
                if (currentZoomLevel < 16 && ([markerType isEqualToString:@"Police"] || [markerType isEqualToString:@"Ticket"] || [markerType isEqualToString:@"Parking"] || [markerType isEqualToString:@"Restroom"] || [markerType isEqualToString:@"Food & Drinks"] || [markerType isEqualToString:@"Apparel"] || [markerType isEqualToString:@"Entry Exit"])) {
                    
                        marker.map = nil;
                        [self.allMapMarkers removeObject:marker];
                }
            }
            
        }
        
        /*else if (isOutside || (isToFarForMarker && !isStadium)) {
            marker.map = nil;
            [self.allMapMarkers removeObject:marker];
        }*/
    }
}

- (void)updateMapObjects:(NSSet *)mapObjects withSnippet:(NSString *)snippet inCoordBounds:(GMSCoordinateBounds *)coordBounds
{
    BOOL isStadium = [snippet isEqualToString:kSnippetStadium];
    BOOL isPin = [snippet isEqualToString:kSnippetPin];
    BOOL isUser = [snippet isEqualToString:kSnippetUser];
    BOOL isAvailableZoomLevel = self.viewMap.camera.zoom >= kMinZoomLevelForMarkers;
    CGFloat currentZoomLevel = self.viewMap.camera.zoom;
    
    if (!isAvailableZoomLevel && !isStadium) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.snippet == %@",snippet];
        NSArray *markers = [self.allMapMarkers filteredArrayUsingPredicate:predicate];
        NSArray *markersDataObjects = [markers valueForKey:@"userData"];
        
        int userCount = 0;
        
        for (id<MapMarkerItem> mapObject in mapObjects) {
            if (![markersDataObjects containsObject:mapObject]) {
                if ([coordBounds containsCoordinate:[mapObject getMapLocation].coordinate]) {
                    if (isStadium) {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            GMSMarker *marker = [GMSMarker markerWithPosition:[mapObject getMapLocation].coordinate];
                            
                            marker.userData = mapObject;
                            marker.snippet = snippet;
                            
                            UIImage *icon = [mapObject getMarkerIcon];
                            CGSize iconSize = CGSizeMake(45, 45);
                            
                            UIImage *icon25 = [self imageWithImage:icon scaledToSize:iconSize];
                            marker.icon = icon25;
                            
                            marker.map = self.viewMap;
                            
                            [self.allMapMarkers addObject:marker];
                        });
                    }
                    else if (isPin) {
                        
                        NSString *markerType = [mapObject getMarkerType];
                        
                        if (currentZoomLevel > 15 && ([markerType isEqualToString:@"Police"] || [markerType isEqualToString:@"Ticket"] || [markerType isEqualToString:@"Parking"] || [markerType isEqualToString:@"Restroom"] || [markerType isEqualToString:@"Food & Drinks"] || [markerType isEqualToString:@"Apparel"] || [markerType isEqualToString:@"Entry Exit"])) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                GMSMarker *marker = [GMSMarker markerWithPosition:[mapObject getMapLocation].coordinate];
                                
                                marker.userData = mapObject;
                                marker.snippet = snippet;
                                
                                UIImage *icon = [mapObject getMarkerIcon];
                                CGSize iconSize = CGSizeMake(45, 45);
                                
                                UIImage *icon25 = [self imageWithImage:icon scaledToSize:iconSize];
                                marker.icon = icon25;
                                
                                marker.map = self.viewMap;
                                
                                [self.allMapMarkers addObject:marker];
                            });
                        }
                        
                        if (currentZoomLevel > 13 && ([markerType isEqualToString:@"Rickshaw"] || [markerType isEqualToString:@"Taxi"] || [markerType isEqualToString:@"Medical Care"] || [markerType isEqualToString:@"Meetup"] || [markerType isEqualToString:@"Playing"])) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                GMSMarker *marker = [GMSMarker markerWithPosition:[mapObject getMapLocation].coordinate];
                                
                                marker.userData = mapObject;
                                marker.snippet = snippet;
                                
                                UIImage *icon = [mapObject getMarkerIcon];
                                CGSize iconSize = CGSizeMake(45, 45);
                                
                                UIImage *icon25 = [self imageWithImage:icon scaledToSize:iconSize];
                                marker.icon = icon25;
                                
                                marker.map = self.viewMap;
                                
                                [self.allMapMarkers addObject:marker];
                            });
                        }
                        
                        if ((currentZoomLevel > 8 || _searchActive) && ([markerType isEqualToString:@"Beer"] || [markerType isEqualToString:@"Tailgate"] || [markerType isEqualToString:@"Partying"] || [markerType isEqualToString:@"Game Showing"] || [markerType isEqualToString:@"Watch Party"] || [markerType isEqualToString:@"Celebrity"] || [markerType isEqualToString:@"Music"] || [markerType isEqualToString:@"Treasure"] || [markerType isEqualToString:@"Broadcast"])) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                GMSMarker *marker = [GMSMarker markerWithPosition:[mapObject getMapLocation].coordinate];
                                
                                marker.userData = mapObject;
                                marker.snippet = snippet;
                                
                                UIImage *icon = [mapObject getMarkerIcon];
                                CGSize iconSize = CGSizeMake(40, 40);
                              
                                if ([markerType isEqualToString:@"Beer"]) {
                                    
                                    //if (icon != [UIImage imageNamed:markerType])
                                        iconSize = CGSizeMake(30, 30);
                                }
                                
                                UIImage *icon25 = [self imageWithImage:icon scaledToSize:iconSize];
                                marker.icon = icon25;
                                
                                marker.map = self.viewMap;
                                
                                [self.allMapMarkers addObject:marker];
                            });
                        }
                    }
                    else if (isUser && userCount < 10) {
                        
                        if (currentZoomLevel > kMinZoomLevelForMarkers || _searchActive) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                GMSMarker *marker = [GMSMarker markerWithPosition:[mapObject getMapLocation].coordinate];
                                
                                marker.userData = mapObject;
                                marker.snippet = snippet;
                                
                                UIImage *icon = [mapObject getMarkerIcon];
                                CGSize iconSize = CGSizeMake(30, 30);
                                
                                UIImage *icon25 = [self imageWithImage:icon scaledToSize:iconSize];
                                marker.icon = icon25;
                                
                                NSString *iconURL = [mapObject getMarkerIconURL];
                                if (iconURL) {
                                    [self setImageForMarker:marker iconURL:iconURL];
                                }
                                
                                marker.map = self.viewMap;
                                
                                [self.allMapMarkers addObject:marker];
                            });
                            
                            userCount++;
                            
                        }
                       
                    }
                    
                }
            }
        }
    });
}


- (void)updateMapObjectsWithSearchPins:(NSSet *)mapObjects withSnippet:(NSString *)snippet inCoordBounds:(GMSCoordinateBounds *)coordBounds withPinType:(NSString *)pinType ofTeam:(NSString *)team
{
    [self.allMapMarkers removeAllObjects];
    
    NSSet *searchedPins = [[NSSet alloc] init];
    NSMutableArray *matchedPins = [[NSMutableArray alloc] init];
    for (id<MapMarkerItem> mapObject in mapObjects) {
        if ([[mapObject getMarkerType] isEqualToString:pinType]) {
           // if ([coordBounds containsCoordinate:[mapObject getMapLocation].coordinate]) {
                Pin *pin = (Pin *)mapObject;
                NSLog(@"Tags: %@", [pin getSearchTags]);
                if ([[pin getSearchTags] containsString:team]) {
                    
                    [matchedPins addObject:pin];
                    
                    NSLog(@"Adding: %@",[pin getSearchTitle]);
                    
                }
                
                
           // }
        }
    }
    
    searchedPins = [NSSet setWithArray:matchedPins];
    
    [self refreshMapMarkersWithCoordBounds:coordBounds withSet:searchedPins withSnippet:snippet clearPins:TRUE];
}

- (void)updateMapObjectsWithFans:(NSSet *)mapObjects withSnippet:(NSString *)snippet inCoordBounds:(GMSCoordinateBounds *)coordBounds ofFans:(NSString *)team
{
    
    [self.allMapMarkers removeAllObjects];
    
    NSSet *searchedUsers = [[NSSet alloc] init];
    NSMutableArray *matchedUsers = [[NSMutableArray alloc] init];
    for (id<MapMarkerItem> mapObject in mapObjects) {
       // if ([coordBounds containsCoordinate:[mapObject getMapLocation].coordinate]) {
            User *user = (User *)mapObject;
            if ([[user getSearchTags] containsString:team]) {
                
                [matchedUsers addObject:user];
                
                NSLog(@"Adding: %@",[user getSearchTitle]);
                
            }
       // }
    }

    searchedUsers = [NSSet setWithArray:matchedUsers];
    
    [self refreshMapMarkersWithCoordBounds:coordBounds withSet:searchedUsers withSnippet:snippet clearPins:TRUE];
}

- (void)updateMapMarkersWithCoordBounds:(GMSCoordinateBounds *)coordBounds
{
    [self updateMapObjects:self.allPins withSnippet:kSnippetPin inCoordBounds:coordBounds];
    [self updateMapObjects:self.allUsers withSnippet:kSnippetUser inCoordBounds:coordBounds];
    [self updateMapObjects:self.allTickets withSnippet:kSnippetTicket inCoordBounds:coordBounds];
    [self updateMapObjects:self.allStadiums withSnippet:kSnippetStadium inCoordBounds:coordBounds];
}

- (void)refreshMapMarkersWithCoordBounds:(GMSCoordinateBounds *)coordBounds withSet:(NSSet *)mapObjects withSnippet:(NSString *)snippet clearPins:(BOOL)canClear
{
    if (canClear) {
        
        [self.viewMap clear];
        self.currentUserMarker = nil;
        [self updateAnnotationForCurrentUser];
    }
    
    if ([kSnippetPin isEqualToString:snippet])
        [self updateMapObjects:mapObjects withSnippet:kSnippetPin inCoordBounds:coordBounds];
    else if ([kSnippetUser isEqualToString:snippet])
        [self updateMapObjects:mapObjects withSnippet:kSnippetUser inCoordBounds:coordBounds];
    
    _searchActive = TRUE;
    _searchedMapObjects = mapObjects;
    _searchedSnippet = snippet;
    
}

- (GMSCoordinateBounds *)currentCoordinateBounds
{
    GMSVisibleRegion visibleRegion = self.viewMap.projection.visibleRegion;
    GMSCoordinateBounds *coordsBounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    
    return coordsBounds;
}


- (int)randomNumberBetween:(int)min maxNumber:(int)max
{
    return min + arc4random_uniform(max - min);
}


#pragma mark - Notifications

- (void)hideTicketPopup:(NSNotification *)notification
{
    if (self.ticketNavigationController) {
        [self.ticketNavigationController removeFromParentViewController];
        [self.ticketPopupView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.ticketDetailPopupView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.view sendSubviewToBack:self.ticketPopupView];
        [self.view sendSubviewToBack:self.ticketDetailPopupView];
    }
}

- (void)hideAnyPopup:(NSNotification *)notification
{
    [self removePopup];
}

#pragma mark - Map Actions

- (IBAction)ZoomIn:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    if (zoomLevel < 20) {
        
        zoomLevel = self.viewMap.camera.zoom;
        zoomLevel += 1;
        
        [self.viewMap animateToZoom:zoomLevel];
    }
}

- (IBAction)ZoomOut:(id)sender {
    
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    if (zoomLevel > kMinZoomLevelForMarkers) {
        
        zoomLevel = self.viewMap.camera.zoom;
        zoomLevel -= 1;
        
        [self.viewMap animateToZoom:zoomLevel];
    }
}

- (IBAction)CurrentLocation:(id)sender
{
    if ([self.view viewWithTag:777] != NULL)
        [self removeInitialPopup];
    
    [self moveToCoordinate:currentLocation.coordinate];
    zoomLevel = 12;
    [self.viewMap animateToZoom:zoomLevel];
}

- (IBAction)showInbox:(id)sender {
    
    self.badge.badgeValue = 0;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InboxViewController *inboxVC = [storyboard instantiateViewControllerWithIdentifier:@"inboxView"];
    inboxVC.inboxDelegate = self;
//    [self.navigationController presentViewController:inboxVC animated:YES completion:nil];
    [self.navigationController pushViewController:inboxVC animated:YES];
}


#pragma mark - Event List

- (IBAction)showCloseByEvents:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventListViewController *eventsVC = [storyboard instantiateViewControllerWithIdentifier:@"eventList"];
    [self.navigationController pushViewController:eventsVC animated:YES];
    
    //[self performSegueWithIdentifier:kSegueEventList sender:self];
}

@end
