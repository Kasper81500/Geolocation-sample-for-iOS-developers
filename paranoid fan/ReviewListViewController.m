//
//  ReviewListViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/28/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "ReviewListViewController.h"
#import "FavoriteTableViewCell.h"
#import "MapViewController.h"
#import "Pin.h"
#import "Engine.h"
#import "User.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>


@interface ReviewListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) NSMutableSet *allPins;
@property (strong, nonatomic) NSArray *pins;


@end

@implementation ReviewListViewController

@synthesize profileID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.hidden = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSInteger user_profile_id = 0;
    
    if (profileID == nil)
        user_profile_id = [[[Engine sharedEngine] settingManager] userID];
    else
        user_profile_id = [profileID integerValue];
    
    [[[Engine sharedEngine] dataManager] getAllFavoritePins:user_profile_id withCallback:^(BOOL success, id result, NSString *errorInfo) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            
            NSSet *favPins = [NSSet setWithArray:result];
            self.allPins = [NSMutableSet setWithSet:favPins];
            self.pins = [self.allPins allObjects];
            self.tblView.hidden = NO;
            [self.tblView reloadData];
            
        }
    }];
}


- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) popToMap {
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[MapViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"favoriteCell";
    
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    Pin *pin = self.pins[indexPath.row];
    cell.pin = pin;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Pin *showPin = self.pins[indexPath.row];
    
    NSDictionary* userInfo = @{@"pin": showPin};
    [[NSNotificationCenter defaultCenter]
                         postNotificationName:kNotificationShowPinPopup
                                                 object:self userInfo:userInfo];
    
    [self popToMap];
}

- (IBAction)showDirection:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    CLLocation *userLocation = [[[[Engine sharedEngine] settingManager] user] getLocation];
    CLLocationCoordinate2D pinCoords = [self.pins[indexPath.row] getLocationCoordinate];
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude, pinCoords.latitude, pinCoords.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString]];
}

- (IBAction)sharePin:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    CLLocationCoordinate2D pinCoords = [self.pins[indexPath.row] getLocationCoordinate];
    
    NSString *shareString = [NSString stringWithFormat:@"http://paranoidfan.com/meetme.php?type=%@&latittude=%f&longitude=%f", [[self.pins[indexPath.row] getPinType] stringByReplacingOccurrencesOfString:@" " withString:@"_"], pinCoords.latitude, pinCoords.longitude];
    
    NSURL *url = [[NSURL alloc] initWithString:shareString];
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:url];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         NSLog(@"completed.");
                     }];
    
}

@end
